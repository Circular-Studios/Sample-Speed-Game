module tictactoe;

import std.stdio;

enum Player { X, O, Empty }

class TicTacToe
{
public:
	bool makeMove( Player player, int x, int y )
	{
		if( x < 1 || x > 3 || y < 1 || y > 3 )
			return false;

		board[ x ][ y ] = player;

		return true;
	}

	void print()
	{

	}

private:
	Player[3][3] board;
}
