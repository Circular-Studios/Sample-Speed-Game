module app;
import tictactoe;
import speed;
import speed.webconnection;

import std.stdio, std.array, std.conv, std.algorithm, std.concurrency;

Player me;
int numPlayers;
string versionNumber;

TicTacToe game;

struct Handshake {
	int currentNumPlayers;
	string currentVersion;
}

void turn( Connection conn )
{
	PlayerType winner;
	if( ( winner = game.getWinner ) != PlayerType.Empty )
	{
		writeln( winner, " has won the game!" );
		conn.close();
		return;
	}

	write("Where would you like to go?\nX: ");
	int x = readln()[0..$-1].to!int;
	write("Y: ");
	int y = readln()[0..$-1].to!int;
	
	Move m = Move(x, y, me.type);
	
	if( game.makeMove( m ) )
	{
		game.print();
		conn.send!Move( m, ConnectionType.TCP );
	}
	else writeln( "That's not a valid move" );

	if( ( winner = game.getWinner ) != PlayerType.Empty )
	{
		writeln( winner, " has won the game!" );
		conn.close();
	}
}

void main()
{
	numPlayers = 1;

	// instantiate ticTacToe
	game = new TicTacToe();

	write( "Enter IP address to connect to: " );
	string ipToConnect = readln();
	
	write( "Will you be hosting this match? (y/n) " );
	bool hosting = readln()[0] == 'y';

	bool hasLoggedIn;

	Player[] playerList;
	Tid spectaterListener;
	shared Player newPlayer;
	shared bool hasNewPlayer = false;

	if ( hosting )
	{
		playerList ~= Player( false, Connection.open( ipToConnect, hosting, ConnectionType.TCP), PlayerType.Empty );

		playerList[0].con.onRecieveData!Handshake ~= ( Handshake h )
		{
			if ( versionNumber == h.currentVersion ) 
			{
				numPlayers++;
				playerList[0].type = PlayerType.O;
				playerList[0].hasLoggedIn = true;
			} else {
				playerList[0].con = Connection.open( "host", true, ConnectionType.TCP );
			}

			playerList[0].con.send!Handshake( Handshake( numPlayers, versionNumber) );
			// spectators go here

			spectaterListener = spawn( ( ref shared bool hasNewPlayer, ref shared Player newPlayer )
			{
				import core.time;
				while( !receiveTimeout( dur!"msecs"( 0 ), ( string x ) { } ) )
				{
					newPlayer.hasLoggedIn = false;
					newPlayer.type = PlayerType.Spectator;

					newPlayer.con = cast(shared)Connection.open( "localhost", true, ConnectionType.TCP );
					hasNewPlayer = true;
				}
			}, hasNewPlayer, newPlayer );
		};

		me.type = PlayerType.X;
	} else {
		me.con = Connection.open( ipToConnect, hosting, ConnectionType.TCP );
		me.con.send!Handshake( Handshake( numPlayers, versionNumber ), ConnectionType.TCP );

		me.con.onRecieveData!Handshake ~= ( Handshake h )
		{
			if ( versionNumber != h.currentVersion )
			{
				me.con.close();
				writeln( "The person you were trying to connect to was on the wrong version.\nYour version: ", versionNumber, "\nTheirVersion: ", h.currentVersion );
			}

			if ( h.currentNumPlayers <= 2 )
			{
				me.type = PlayerType.O;
				turn( me.con );
			}
			else me.type = PlayerType.Spectator;

			hasLoggedIn = true;
		};
	}

	writeln( "Connected" );
	if( hosting )
	{
		playerList[0].con.onRecieveData!Move ~= ( Move m )
		{
			game.makeMove( m );
			game.print();
			turn( playerList[0].con );
		};
	}
	else
	{
		me.con.onRecieveData!Move ~= ( Move m )
		{
			game.makeMove( m );
			game.print();
			turn( me.con );
		};
	}
	if( hosting )
	{
		while( playerList.length > 0 )
		{
			if( hasNewPlayer )
			{
				playerList ~= cast(Player)newPlayer;
				hasNewPlayer = false;
			}

			foreach_reverse( i, player; playerList )
			{
				if( player.con.isOpen )
				{
					player.con.update();
				}
				else 
				{
					writeln( "playerList.length: ", playerList.length );

					playerList = playerList.remove( i );
					writeln( "Removing player" );
					writeln( "playerList.length: ", playerList.length );
				}
			}
		}

		spectaterListener.send( "DONE" );
	}
	else
	{
		while( me.con.isOpen )
		{
			me.con.update();
		}
	}
}
