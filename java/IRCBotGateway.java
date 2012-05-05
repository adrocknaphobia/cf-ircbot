/*
#   Copyright 2005 Sean A Corfield http://corfield.org/
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#	Changelog:
#		1.1.0	2005-11-23	Added debug flag, added handler specifiers,
#							added eventName and otherUser to message handler
#		1.0.0	2005-11-22	Initial version
 */

package examples.ircbot;

import coldfusion.eventgateway.CFEvent;
import coldfusion.eventgateway.GenericGateway;
import coldfusion.eventgateway.GatewayHelper;

import java.util.*;

public class IRCBotGateway extends GenericGateway {
	
    // start/stop template methods:
	protected void startGateway() throws Exception {
        // re-read the configuration:
        this.bot.reconfigure( this.configFile );
		// start listener thread(s)
		this.bot.start();
	}
	
	protected void stopGateway() throws Exception {
        this.bot.stop();
	}
	
	public GatewayHelper getHelper() {
		return new IRCBotHelper( this, this.bot );
	}
	
	// handle response from CFC:
	public String outgoingMessage( CFEvent cfmessage ) {
		Map data = cfmessage.getData();
		// either MESSAGE or ACTION or SILENT
		String response = (String) data.get( "response" );
		if ( response.equals( "MESSAGE" ) ) {
			String target = (String) data.get( "target" );
			String message = (String) data.get( "message" );
			this.bot.sendMessage( target, message );
		} else if ( response.equals( "ACTION" ) ) {
			String target = (String) data.get( "target" );
			String message = (String) data.get( "message" );
			this.bot.sendAction( target, message );
		}
        return response;
	}
	// constructor (can throw coldfusion.server.ServiceRuntimeException):
    public IRCBotGateway( String gatewayID, String configFile ) throws Exception {
        super( gatewayID );
        this.configFile = configFile;
        this.bot = new IRCBot( configFile, this );
    }

	public void handleMessage( String botName, String channel, String sender,
			String login, String hostname, String message, String method,
			String eventName, String otherUser ) {
        coldfusion.eventgateway.Logger log = getGatewayServices().getLogger();
        Map data = new HashMap();
		CFEvent cfMsg = new CFEvent( getGatewayID() );
		cfMsg.setCfcMethod(method);
		data.put( "botName", botName );
		data.put( "bot", this.bot );
        data.put( "channel", channel );
        data.put( "sender", sender );
        data.put( "otherUser", otherUser );
        data.put( "login", login );
        data.put( "hostname", hostname );
        data.put( "message", message );
        data.put( "eventName", eventName );
		cfMsg.setData( data );
		cfMsg.setOriginatorID( channel + ":" + sender );
		cfMsg.setGatewayType( "IRC" );
		if ( sendMessage( cfMsg ) ) {
			if ( this.bot.getConfiguration().isDebug() ) {
				log.info( "Added message from '" + channel + ":" + sender + "' to queue." );
			}
		} else {
            // this isn't really enough - we need to save the failed msg and / or
            // retry sending the message...
			log.error( "Failed to add message from '" + channel + ":" + sender + "' to queue." );
		}
    }
	
    private String configFile;
    private IRCBot bot;
}
