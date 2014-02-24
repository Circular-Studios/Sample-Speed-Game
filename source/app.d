import speed;
import speed.webconnection;

import std.stdio, std.array;

//*
void main()
{
	write( "Enter IP address to connect to: " );
	string ipToConnect = readln();

	write( "Will you be hosting this match? (y/n) " );
	bool hosting = readln()[0] == 'y';
	
	shared Connection con = Connection.open( ipToConnect, hosting, ConnectionType.TCP );
	writeln( "Connected" );

	if( hosting )
	{
		con.onRecieveData!float ~= f => writeln( "Recieved float: ", f );
		con.onRecieveData!string ~= f => writeln( "Recieved string: ", f );
	}
	else
	{
		import core.thread;
		Thread.sleep( dur!"seconds"( 1 ) );

		con.send!float( 4.3f, ConnectionType.TCP );

		writeln( "Sent float." );

		Thread.sleep( dur!"seconds"( 1 ) );

		con.send!string( "Testing!!!", ConnectionType.TCP );

		writeln( "Sent message." );
	}

	while( true ) con.update();

	/*
	write( "Enter your username: " );
	string username = readln();
	
	con.login( username, ConnectionType.TCP );
	
	con.onRecieveText ~= msg => write( "Server says: ", msg );
	
	while( true )
	{
		write( "Message: " );
		string message = readln();
		
		if( message.length > 3 && message[ 0..4 ] == "EXIT" )
		{
			con.logoff( username, ConnectionType.TCP );
			con.close();
			return;
		}
		else if( message.length && message[ 0 ] == '/' )
		{
			auto mess = message.split( " " );
			
			// Split into /target message
			con.whisper( mess[ 0 ][ 1..$ ], mess[ 1..$ ].join( " " ), ConnectionType.TCP );
		}
		else
		{
			con.send!string( message, ConnectionType.TCP );
		}
		
		con.update();
	}
	*/
}
/*/

class Test1
{
	int x;
}

void main()
{
	import std.traits;
	auto t = ClassInfo.find( fullyQualifiedName!Test1 );
	writeln( Test1.stringof, ": ", t );
}
//*/
