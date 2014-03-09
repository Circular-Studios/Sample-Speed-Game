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
		
		string[] blargs;
		Main.init( blargs );
		new ChatApp( conn, username );
		Main.run();
	}
	else if( args[ 1 ].strip == "server" )
	{
		writeln( "Waiting for connection..." );

		shared(Connection) initServerConnection()
		{
			auto conn = Connection.open( "localhost", true, ConnectionType.TCP );
			writeln( "Waiting for messages..." );
			
			conn.onRecieveData!Message ~= ( Message message )
			{
				writeln( message.sender, "> ", message.message );
				conn.send!Message( message, ConnectionType.TCP );
			};

			return conn;
		}

		auto conn = initServerConnection();

		while( true )
		{
			try	
			{
				conn.update();
			}
			catch
			{
				writeln( "Connection Closed. Waiting for new connection..." );
				conn = initServerConnection();
			}
		}
	}
}
