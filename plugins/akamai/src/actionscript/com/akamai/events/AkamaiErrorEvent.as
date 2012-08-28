package com.akamai.events
{
	import flash.events.Event;
	
	/**
	 * The AkamaiErrorEvent class provides notification of run-time errors
	 * encountered by the AkamaiConnection class. It makes available an error number 
	 * and error description for each error event.<p />
	 * <table>
	 * <tr><th> Error Number</th><th>Description</th></tr>
	 * <tr><td>1</td><td>Hostname cannot be empty</td></tr>
	 * <tr><td>2</td><td>Buffer length must be &gt; 0.1</td></tr>
	 * <tr><td>3</td><td>Warning - this protocol is not supported on the Akamai network</td></tr>
	 * <tr><td>4</td><td>Warning - this port is not supported on the Akamai network</td></tr>
	 * <tr><td>5</td><td>Warning - unable to load XML data from ident request, will use domain name to connect</td></tr>
	 * <tr><td>6</td><td>Timed out while trying to connect</td></tr>
	 * <tr><td>7</td><td>Stream not found</td></tr>
	 * <tr><td>8</td><td>Cannot play, pause, seek, or resume since the stream is not defined</td></tr>
	 * <tr><td>9</td><td>Timed out trying to find the live stream</td></tr>
	 * <tr><td>10</td><td>Error requesting stream length</td></tr>
	 * <tr><td>11</td><td>Volume value out of range</td></tr>
	 * <tr><td>12</td><td>Network failure - unable to play the live stream</td></tr>
	 * <tr><td>13</td><td>Connection attempt rejected by server</td></tr>
	 * <tr><td>14</td><td>HTTP loading operation failed</td></tr>
	 * <tr><td>15</td><td>XML is not well formed</td></tr>
	 * <tr><td>16</td><td>XML does not conform to Media RSS standard</td></tr>
	 * <tr><td>17</td><td>Class is busy and cannot process your request</td></tr>
	 * <tr><td>18</td><td>XML does not conform to BOSS standard</td></tr>
	 * <tr><td>19</td><td>The Fast Start feature cannot be used with live streams</td></tr>
	 * <tr><td>20</td><td>Timed out trying to load the XML file</td></tr>
	 * <tr><td>21</td><td>NetStream IO Error event</td></tr>
	 * <tr><td>22</td><td>NetStream Failed - check your live stream auth params</td></tr>
	 * <tr><td>23</td><td>NetConnection connection attempt failed</td></tr>
	 * <tr><td>24</td><td>NetStream buffer has remained empty past timeout threshold</td></tr>
	 * * </table>
	 * 
	 * @see com.akamai.AkamaiConnection
	 */
	public class AkamaiErrorEvent extends Event
	{
		/** 
		 * The AkamaiErrorEvent.ERROR constant defines the value of an error event's
		 * <code>type</code> property, which indicates that the class
		 * has encountered a run-time error.
		 * 
		 */
  		public static const ERROR:String = "error";
		/**
		 * An integer value representing the error condition.
		 */
        public var errorNumber:uint;
        /**
		 * A description of the error condition.
		 */
        public var errorDescription:String;
		/**
		 * Constructor. Normally called by the AkamaiConnection class, not used in application code.
		 * 
		 * @param type The event type; indicates the action that caused the event.
		 * @param errorNumber An integer specifying the error condition.
		 * @param errorDescription A verbose description of the error condition. 
		 */
            public function AkamaiErrorEvent(type:String, errorNumber:uint, errorDescription:String)             {
                // Call the constructor of the superclass.
                super(type);
                // Set the new properties.
                this.errorNumber = errorNumber;
                this.errorDescription = errorDescription;
   			}

            /** 
            * @private 
            * Override the inherited clone() method.
            */
            override public function clone():Event {
                return new AkamaiErrorEvent(type, errorNumber,errorDescription);
            }

	}
}