module app;
import tictactoe, chat;
import speed;
import speed.webconnection;

import core.sync.mutex;
import std.stdio, std.array, std.conv, std.algorithm, std.concurrency, std.string;

void main( string[] args )
{
	if( args.length == 1 )
	{
		writeln( "Would you like to run the game or the chat? (type \"game\" or \"chat\") " );
		string arg = readln().chomp;

		if( arg == "game" || arg == "chat" )
		{
			args ~= arg;

			if( arg == "chat" )
				writeln( "Would you like to run the server or the client or the gtk-client? (type \"server\" or \"client\" or \"client-gtk\") " );
			arg = readln().chomp;

			if( arg == "server" || arg == "client" || arg == "client-gtk" )
				args ~= arg;
		}
		else writeln( "You need to run either the game or chat, the program will now exit" );
	}

	if( args[ 1 ].strip == "chat" )
	{
		startChat( args[ 1..$ ] );
	}
	else if( args[ 1 ].strip == "game" )
	{
		startGame( args[ 1..$ ] );
	}
}
