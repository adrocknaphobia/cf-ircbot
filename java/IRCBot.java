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
#		1.1.0	2005-11-23	Exposed configuration via helper, added all the
#							different onXxx event handlers
#		1.0.0	2005-11-22	Initial version
 */

package examples.ircbot;

import org.jibble.pircbot.*;

public class IRCBot extends PircBot {
	
    public IRCBot( String configFile, IRCBotGateway gateway ) throws Exception {
    		this.configuration = new IRCBotConfiguration( configFile );
        	this.gateway = gateway;
    }
    
    public void start() throws Exception {
    		this.setName( this.configuration.getBotName() );
    		this.setVerbose( true );
    		if ( this.configuration.isIdentServerNeeded() ) {
    			this.setLogin( this.configuration.getBotLogin() );
    			this.startIdentServer();
    		}
    		this.connect( this.configuration.getServerName() );
    		this.joinChannel( this.configuration.getChannelName() );
    	}

    public void stop() throws Exception {
    		this.partChannel( this.configuration.getChannelName() );
    		this.disconnect();
    }

    public void reconfigure( String configFile ) throws Exception {
        this.configuration = new IRCBotConfiguration( configFile );
    }

	public void onAction(String sender, String login, String hostname,
			String target, String action) {
        this.gateway.handleMessage( this.configuration.getBotName(),
        		target, sender, login, hostname, action,
        		this.configuration.getOnAction(), "onAction", "" );
	}

	public void onJoin(String channel, String sender, String login, String hostname) {
		this.gateway.handleMessage( this.configuration.getBotName(),
				channel, sender, login, hostname, "",
        		this.configuration.getOnJoin(), "onJoin", "" );
	}

	public void onKick(String channel, String kickerNick, String kickerLogin, 
			String kickerHostname, String recipientNick, String reason) {
		this.gateway.handleMessage( this.configuration.getBotName(),
				channel, recipientNick, kickerLogin, kickerHostname, "",
        		this.configuration.getOnKick(), "onKick", kickerNick );
	}
	
	public void onMessage(String channel, String sender,
			String login, String hostname, String message) {
        this.gateway.handleMessage( this.configuration.getBotName(),
        		channel, sender, login, hostname, message,
        		this.configuration.getOnMessage(), "onMessage", "" );
	}

	public void onNickChange(String oldNick,
			String login, String hostname, String newNick) {
        this.gateway.handleMessage( this.configuration.getBotName(),
        		"", oldNick, login, hostname, "",
        		this.configuration.getOnNickChange(), "onNickChange", newNick );
	}

	public void onNotice(String sourceNick,
			String login, String hostname, String target, String notice) {
        this.gateway.handleMessage( this.configuration.getBotName(),
        		target, sourceNick, login, hostname, notice,
        		this.configuration.getOnNotice(), "onNotice", "" );
	}

	public void onPart(String channel, String sender, String login, String hostname) {
		this.gateway.handleMessage( this.configuration.getBotName(),
				channel, sender, login, hostname, "",
        		this.configuration.getOnPart(), "onPart", "" );
	}

	public void onPrivateMessage(String sender,
			String login, String hostname, String message) {
        this.gateway.handleMessage( this.configuration.getBotName(),
        		"", sender, login, hostname, message,
        		this.configuration.getOnPrivateMessage(), "onPrivateMessage", "" );
	}
	
	public void onQuit(String sender, String login, String hostname, String reason) {
		this.gateway.handleMessage( this.configuration.getBotName(),
				"", sender, login, hostname, reason,
        		this.configuration.getOnQuit(), "onQuit", "" );
	}

	public void onTopic(String channel, String topic, String setBy, long date, boolean changed) {
		this.gateway.handleMessage( this.configuration.getBotName(),
				channel, setBy, "", "", topic,
        		this.configuration.getOnTopic(), "onTopic", "" );
	}

	// package utility for IRCBotHelper:
	IRCBotConfiguration getConfiguration() {
		return configuration;
	}
	
    private IRCBotConfiguration configuration;
    private IRCBotGateway gateway;
}
