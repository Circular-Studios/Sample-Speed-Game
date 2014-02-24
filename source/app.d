module app;
import tictactoe;
import speed;
import speed.webconnection;

import std.stdio, std.array;

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
}
