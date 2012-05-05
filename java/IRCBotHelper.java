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
#		1.1.0	2005-11-23	Exposed configuration
#		1.0.0	2005-11-22	Initial version
 */

package examples.ircbot;

public class IRCBotHelper implements coldfusion.eventgateway.GatewayHelper {
	
	public IRCBotHelper( IRCBotGateway gateway, IRCBot bot ) {
		this.gateway = gateway;
		this.bot = bot;
	}
	
	public String sendMessage( java.util.Map msg ) {
		coldfusion.eventgateway.CFEvent event =
			new coldfusion.eventgateway.CFEvent( this.gateway.getGatewayID() );
		event.setData( msg );
		return this.gateway.outgoingMessage( event );
	}
	
	public IRCBotConfiguration getConfiguration() {
		return this.bot.getConfiguration();
	}
	
	private IRCBotGateway gateway;
	private IRCBot bot;
}