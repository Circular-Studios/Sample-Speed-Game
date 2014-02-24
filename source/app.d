module app;
import tictactoe;
import speed;
import speed.webconnection;

import std.stdio, std.array, std.conv;

Player me;

TicTacToe game;

void turn( shared Connection conn )
{
	Player winner;
	if( ( winner = game.getWinner ) != Player.Empty )
	{
		writeln( winner, " has won the game!" );
		return;
	}

	write("Where would you like to go?\nX: ");
	int x = readln()[0..$-1].to!int;
	write("Y: ");
	int y = readln()[0..$-1].to!int;
	
	Move m = Move(x, y, me);
	
	if( game.makeMove( m ) )
		conn.send!Move( m, ConnectionType.TCP );
	else writeln( "THATS NOT VALID DUMMY" );

	game.print();

	if( ( winner = game.getWinner ) != Player.Empty )
		writeln( winner, " has won the game!" );
}

void main()
{
	write( "Enter IP address to connect to: " );
	string ipToConnect = readln();
	
	write( "Will you be hosting this match? (y/n) " );
	bool hosting = readln()[0] == 'y';
	
	shared Connection con = Connection.open( ipToConnect, hosting, ConnectionType.TCP );
	writeln( "Connected" );
	
	// instantiate ticTacToe
	game = new TicTacToe();
	
	if( hosting )
	{
		me = Player.X;
	}
	else
	{
		me = Player.O;
		turn( con );
	}
	
	con.onRecieveData!Move ~= ( Move m )
	{
		game.makeMove( m );
		game.print();
		turn( con );
	};
	
	while( true ) con.update();
}
