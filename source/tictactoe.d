module tictactoe;

import std.stdio;
import speed;
import speed.webconnection;

enum PlayerType { X, O, Empty, Spectator }

struct Player
{
	bool hasLoggedIn;
	shared Connection con;
	PlayerType type;
}

struct Move
{
	int x;
	int y;
	PlayerType player;

	@property bool valid()
	{
		return x > 0 && x < 4 && y > 0 && y < 4;
	}
}

Player me;
int numPlayers;
string versionNumber;

TicTacToe game;

struct Handshake {
    int currentNumPlayers;
    string currentVersion;
}

void startGame( string[] args )
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

    if ( hosting )
    {
        playerList ~= Player( false, Connection.open( ipToConnect, hosting, ConnectionType.TCP), PlayerType.Empty );

        playerList[0].con.onReceiveData!Handshake ~= ( Handshake h )
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
        };

        me.type = PlayerType.X;
    } else {
        me.con = Connection.open( ipToConnect, hosting, ConnectionType.TCP );
        me.con.send!Handshake( Handshake( numPlayers, versionNumber ), ConnectionType.TCP );

        me.con.onReceiveData!Handshake ~= ( Handshake h )
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
        playerList[0].con.onReceiveData!Move ~= ( Move m )
        {
            game.makeMove( m );
            game.print();
            turn( playerList[0].con );
        };
    }
    else
    {
        me.con.onReceiveData!Move ~= ( Move m )
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
            foreach_reverse( i, player; playerList )
            {
                if( player.con.isOpen )
                {
                    try
                    {
                        player.con.update();
                    }
                    catch
                    {
                        writeln( "Connection Closed" );
                        return;
                    }
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
            try
            {
                me.con.update();
            }
            catch
            {
                writeln( "Connection Closed" );
                return;
            }
        }
    }
}

void turn( shared Connection conn )
{
    PlayerType winner;
    if( ( winner = game.getWinner ) != PlayerType.Empty )
    {
        writeln( winner, " has won the game!" );
        conn.close();
        return;
    }

    bool validMove = true;

    Move m;
    m.player = me.type;

    do
    {
        if( !validMove )
            writeln( "Your move is bad, and you should feel bad." );

        write("Where would you like to go?\nX: ");
        m.x = readln()[0..$-1].to!int;
        write("Y: ");
        m.y = readln()[0..$-1].to!int;
    } while( ( validMove = game.makeMove( m ) ) == false );

    game.print();
    conn.send!Move( m, ConnectionType.TCP );

    if( ( winner = game.getWinner ) != PlayerType.Empty )
    {
        writeln( winner, " has won the game!" );
        conn.close();
    }
}

class TicTacToe
{
public:
	this()
	{
		foreach( ref row; board )
			foreach( ref cell; row )
				cell = PlayerType.Empty;
	}

	bool makeMove( Move move )
	{
		if( !move.valid || board[ move.x - 1 ][ move.y - 1 ] != PlayerType.Empty )
			return false;

		board[ move.x - 1 ][ move.y - 1 ] = move.player;

		return true;
	}

	PlayerType getWinner()
	{
		// With help from http://rosettacode.org/wiki/Tic-tac-toe#D
		static immutable wins = [
			// Rows
			[ [ 0, 0 ], [ 0, 1 ], [ 0, 2 ] ],
			[ [ 1, 0 ], [ 1, 1 ], [ 1, 2 ] ],
			[ [ 2, 0 ], [ 2, 1 ], [ 2, 2 ] ],
			// Cols
			[ [ 0, 0 ], [ 1, 0 ], [ 2, 0 ] ],
			[ [ 0, 1 ], [ 1, 1 ], [ 2, 1 ] ],
			[ [ 0, 2 ], [ 1, 2 ], [ 2, 2 ] ],
			// Diags
			[ [ 0, 0 ], [ 1, 1 ], [ 2, 2 ] ],
			[ [ 0, 2 ], [ 1, 1 ], [ 2, 0 ] ]
		];

		foreach( immutable win; wins )
		{
			immutable bw0 = board[ win[ 0 ][ 0 ] ][ win[ 0 ][ 1 ] ];
			if( bw0 == PlayerType.Empty )
				continue; // Nobody wins on this one.

			if( bw0 == board[ win[ 1 ][ 0 ] ][ win[ 1 ][ 1 ] ] && bw0 == board[ win[ 2 ][ 0 ] ][ win[ 2 ][ 1 ] ] )
				return bw0;
		}

		return PlayerType.Empty;
	}

	void print()
	{
		for( int y = 0; y < 3; y++ )
		{
			for( int x = 0; x < 3; x++ )
			{
				if( board[x][y] == PlayerType.X )
					write( "X" );
				else if ( board[x][y] == PlayerType.O )
					write( "O" );
				else if( y == 2 )
					write( " " );
				else write( "_" );

				if ( x < 2 ) write ( "|" );
			}
			write( "\n" );
		}
	}

private:
	PlayerType[3][3] board;
}
