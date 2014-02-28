module tictactoe;

import std.stdio;
import speed;
import speed.webconnection;

enum PlayerType { X, O, Empty, Spectator }

struct Player
{
	bool hasLoggedIn;
	Connection con;
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
