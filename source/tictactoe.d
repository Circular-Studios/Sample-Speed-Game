module tictactoe;

import std.stdio;

enum Player { X, O, Empty }

struct Move
{
	int x;
	int y;
	Player player;
	
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
				cell = Player.Empty;
	}
	
	bool makeMove( Move move )
	{
		if( !move.valid || board[ move.x - 1 ][ move.y - 1 ] != Player.Empty )
			return false;
		
		board[ move.x - 1 ][ move.y - 1 ] = move.player;
		
		return true;
	}
	
	void print()
	{
		
	}
	
private:
	Player[3][3] board;
}
