module chatwindow;
import speed;

import core.time;
import std.concurrency, std.stdio;

import gtk.MainWindow;
import gtk.Label, gtk.Entry, gtk.Grid;
import gtk.TextView, gtk.TextBuffer, gtk.Button;
import gtk.ScrolledWindow;

struct Message
{
	string sender;
	string message;

	string toString()
	{
		return sender ~ "> " ~ message;
	}
}

class ChatApp : MainWindow
{
	ScrolledWindow textViewScroll;
	TextView textView;
	Entry textBox;
	Grid grid;
	Tid receiveThread;
	shared Connection connection;
	string username;
	
	this( shared Connection conn, string un )
	{
		super( "GtkD" );
		setBorderWidth( 10 );
		setResizable( false );
		
		// Create grid
		grid = new Grid;
		
		// Add message view
		textView = new TextView;
		textView.getBuffer().setText( "" );
		textView.setEditable = false;
		textViewScroll = new ScrolledWindow( textView );
		textViewScroll.setSizeRequest( 400, 200 );
		grid.attach( textViewScroll, 1, 1, 3, 1 );
		
		// Add message prompt
		grid.attach( new Label( "Message: " ), 1, 2, 1, 1 );
		
		// Add entry box
		textBox = new Entry( "" );
		grid.attach( textBox, 2, 2, 1, 1 );
		
		grid.attach( new Button( "Send", &send ), 3, 2, 1, 1 );
		
		// Attach grid to window, and show everything
		add( grid );
		showAll();

		username = un;
		connection = conn;
		connection.onRecieveData!Message ~= ( Message msg ) {  addMessage( msg ); };

		receiveThread = spawn( ( shared Connection conn )
		{
			while( true )
			{
				if( receiveTimeout( dur!"msecs"( 0 ), ( string s ) { } ) )
					return;

				try
				{
					conn.update();
				}
				catch
				{
					return;
				}
			}
		}, connection );
	}

	~this()
	{
		//receiveThread.send( "DONE" );
	}

	void addMessage( Message msg )
	{
		string previousText = textView.getBuffer.getText;

		textView.getBuffer().setText( previousText ~ "\n" ~ msg.toString() );
		
		auto adj = textViewScroll.getVadjustment();
		adj.setValue( adj.getUpper() ); 
	}
	
	void send( Button button )
	{
		synchronized( this )
		{
			Message msg;
			msg.message = textBox.getText();
			msg.sender = username;

			//addMessage( msg );
			connection.send!Message( msg, ConnectionType.TCP );

			textBox.setText( "" );
		}
	}
}
