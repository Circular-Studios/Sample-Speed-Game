module chat;
import speed, speed.webconnection;;

import std.stdio, std.string;

struct Message
{
	string sender;
	string message;
}

void startChat( string[] args )
{
	if( args.length == 1 )
	{
		writeln( "Please specify one of the following:\n - client\n - server" );
	}
	else if( args[ 1 ].strip == "client" )
	{
		write( "Enter IP address to connect to: " );
		string ipToConnect = readln().strip;

		write( "Enter your username: " );
		string username = readln().strip;

		auto conn = Connection.open( ipToConnect, false, ConnectionType.TCP );
		writeln( "Connected." );

		while( true )
		{
			Message msg;
			write( "Message: " );
			msg.message = readln().strip;
			msg.sender = username;

			conn.send!Message( msg, ConnectionType.TCP );
		}
	}
	else if( args[ 1 ].strip == "server" )
	{
		writeln( "Waiting for connection..." );
		auto conn = Connection.open( "localhost", true, ConnectionType.TCP );
		writeln( "Waiting for messages..." );

		conn.onRecieveData!Message ~= ( Message message )
		{
			writeln( message.sender, "> ", message.message );
		};

		while( true )
		{
			try	
			{
				conn.update();
			}
			catch
			{
				writeln( "Connection Closed" );
				return;
			}
		}
	}
}
