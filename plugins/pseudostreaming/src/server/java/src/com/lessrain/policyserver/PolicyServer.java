package com.lessrain.policyserver;

import java.io.BufferedReader;
import java.io.EOFException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.InterruptedIOException;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;

/**
 * Class PolicyServer
 * Starts a PolicyServer on the specified port.
 * Can be started as main class, passing the port number as the first command line argument
 * @author Thomas Meyer, Less Rain (thomas@lessrain.com)
 *
 */
public class PolicyServer extends Thread
{
	/**
	 * If no argument is passed the server will listen on this port for connections
	 */
	public static final int DEFAULT_PORT = 1008;
	public static final String[] DEFAULT_POLICY = new String[] { "*" };
	
	/**
	 * The character sequence sent by the Flash Player to request a _policy file
	 */
	public static final String POLICY_REQUEST = "<policy-file-request/>";
	
	public static final boolean DEBUG = true;
	
	/**
	 * @param args	Use the first command line argument to set the port the server will listen on for connections
	 */
	public static void main(String[] args)
	{
		int port = DEFAULT_PORT;
		try
		{
			if (args.length>0) port = Integer.parseInt(args[0]);
		}
		catch (NumberFormatException e) {}
		
		// Start the PolicyServer
		(new PolicyServer( port , new String[] { "*:80" })).start();
	}


	/*
	 * PolicyServer class variables
	 */
	private int _port;
	private boolean _listening;
	private ServerSocket _socketServer;
	private String _policy;

	
	/**
	 * PolicyServer constructor
	 * @param port_	Sets the port that the PolicyServer listens on
	 */
	public PolicyServer( int port_, String[] allowedHosts_ )
	{
		_port = port_;
		_listening=true;
		if (allowedHosts_==null) allowedHosts_ = DEFAULT_POLICY;
		_policy = buildPolicy(allowedHosts_);
	}
	
	private String buildPolicy( String[] allowedHosts_ )
	{
		StringBuffer policyBuffer = new StringBuffer();

		policyBuffer.append("<?xml version=\"1.0\"?><cross-domain-policy>");
		for (int i = 0; i < allowedHosts_.length; i++) {
			String[] hostInfo = allowedHosts_[i].split(":");
			String hostname = hostInfo[0];
			String ports;
			if (hostInfo.length>1) ports = hostInfo[1];
			else ports = "*";
			
			policyBuffer.append("<allow-access-from domain=\""+hostname+"\" to-ports=\""+ports+"\" />");
		}
		policyBuffer.append("</cross-domain-policy>");
		
		return policyBuffer.toString();
	}

	/**
	 * Thread run method, accepts incoming connections and creates SocketConnection objects to handle requests
	 */
	public void run()
	{
		try
		{
			_listening=true;
			
			// Start listening for connections
			_socketServer = new ServerSocket(_port,50);
			if (DEBUG) System.out.println("PolicyServer listening on port "+_port);
			
			while(_listening)
			{
				// Wait for a connection and accept it
				Socket socket = _socketServer.accept();
				
				try
				{
					if (DEBUG) System.out.println("PolicyServer got a connection on port "+_port);
					// Start a new connection thread
					(new SocketConnection(socket)).start();
				}
				catch (Exception e)
				{
					if (DEBUG) System.out.println("Exception: "+e.getMessage());
				}
				try
				{
					// Wait for a sec until a new connection is accepted to avoid flooding
					sleep(1000);
				}
				catch (InterruptedException e) {}
			}
		}
		catch(IOException e)
		{
			if (DEBUG) System.out.println("IO Exception: "+e.getMessage());
		}
	}
	
	/**
	 * Local class SocketConnection
	 * For every accepted connection one SocketConnection is created.
	 * It waits for the _policy file request, returns the _policy file and closes the connection immediately
	 * @author Thomas Meyer, Less Rain (thomas@lessrain.com)
	 *
	 */
	class SocketConnection extends Thread
	{
		private Socket _socket;
		private BufferedReader _socketIn;
		private PrintWriter _socketOut;
		
		/**
		 * Constructor takes the Socket object for this connection
		 * @param socket_	Socket connection to a client created by the PolicyServer main thread
		 */
		public SocketConnection(Socket socket_)
		{
			_socket = socket_;
		}
		
		/**
		 * Thread run method waits for the _policy request, returns the poilcy file and closes the connection
		 */
		public void run()
		{
			try
			{
				// initialize socket and readers/writers
				_socket.setSoTimeout(10000);
				_socketIn = new BufferedReader(new InputStreamReader(_socket.getInputStream()));
				_socketOut =new PrintWriter(_socket.getOutputStream(), true);
			}
			catch (IOException e)
			{
				if (DEBUG) System.out.println("IO Exception "+e.getMessage());
				return;
			}

			readPolicyRequest();
		}
		
		/**
		 * Wait for and read the _policy request sent by the Flash Player
		 * Return the _policy file and close the Socket connection
		 */
		private void readPolicyRequest()
		{
			try
			{
				// Read the request and compare it to the request string defined in the constants.
				// If the proper _policy request has been sent write out the _policy file
				if (POLICY_REQUEST.equals(read())) write(_policy);
			}
			catch (Exception e)
			{
				if (DEBUG) System.out.println("Exception "+e.getMessage());
			}
			close();
		}
		
		/**
		 * Read until a zero character is sent or a maximum of 100 character
		 * @return The character sequence read
		 * @throws IOException
		 * @throws EOFException
		 * @throws InterruptedIOException
		 */
		private String read() throws IOException, EOFException, InterruptedIOException
		{
			StringBuffer buffer = new StringBuffer();
			int codePoint;
			boolean zeroByteRead=false;
			
			if (DEBUG) System.out.println("Reading...");
			do
			{
				codePoint=_socketIn.read();
				if (codePoint==0) zeroByteRead=true;
				else buffer.appendCodePoint( codePoint );
			}
			while (!zeroByteRead && buffer.length()<100);
			if (DEBUG) System.out.println("Read: "+buffer.toString());
			
			return buffer.toString();
		}
		
		/**
		 * Writes a String to the client
		 * @param msg	Text to be sent to the client (_policy file)
		 */
		public void write(String msg)
		{
			_socketOut.println(msg+"\u0000");
			_socketOut.flush();
			if (DEBUG) System.out.println("Wrote: "+msg);
		}
		
		/**
		 * Close the Socket connection an set everything to null. Prepared for garbage collection
		 */
		public void close()
		{
			try
			{
				if (_socket!=null) _socket.close();
				if (_socketOut!=null) _socketOut.close();
				if (_socketIn!=null) _socketIn.close();
			}
			catch (IOException e) {}
			
			_socketIn=null;
			_socketOut=null;
			_socket=null;
		}
		
	}
	
}
