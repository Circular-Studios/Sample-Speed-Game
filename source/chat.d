module chat;
import chatwindow;
import speed;

import std.stdio, std.string;
import gtk.Main;

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

		conn.onReceiveData!Message ~= ( Message msg )
		{
			writeln( msg.sender, "> ", msg.message );
		};
		
		while( true )
		{
			Message msg;
			write( "Message: " );
			msg.message = readln().strip;
			msg.sender = username;
			
			conn.send!Message( msg, ConnectionType.TCP );

			conn.update();
		}
	}
	else if( args[ 1 ].strip == "client-gtk" )
	{
		write( "Enter IP address to connect to: " );
		string ipToConnect = readln().strip;
		
		write( "Enter your username: " );
		string username = readln().strip;
		
		auto conn = Connection.open( ipToConnect, false, ConnectionType.TCP );
		
		string[] blargs;
		Main.init( blargs );
		new ChatApp( conn, username );
		Main.run();
	}
	else if( args[ 1 ].strip == "server" )
	{
		writeln( "Waiting for connection..." );

		auto conman = ConnectionManager.open();

		conman.onNewConnection ~= ( shared Connection conn )
		{
			writeln( "New connection." );
			conn.onReceiveData!Message ~= ( Message message )
			{
				writeln( message.sender, "> ", message.message );
				conn.send!Message( message, ConnectionType.TCP );
			};
		};

		conman.start();
	}
}
