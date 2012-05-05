<!---
   Copyright 2005 Sean A Corfield http://corfield.org/

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

   IRCBot uses PircBot http://www.jibble.org/pircbot.php by Paul Mutton

   PircBot is released under the GNU Public License. A copy of pircbot.jar
   is included in this distribution by permission of the author.

Changelog:

   1.2.0 2005-11-30 Added mailbox / messaging functionality
                    Added learn command (thanx Jared)
   1.1.0 2005-11-24 Initial version extracted from IRCBot.cfc
--->
<cfcomponent hint="- displays this set of help messages.">

	<cffunction name="execute" returntype="struct" access="public" output="false">
		<cfargument name="bot" type="any" required="true" />
		<cfargument name="event" type="struct" required="true" />
		<cfargument name="target" type="string" required="true" />
		<cfargument name="args" type="string" required="true" />

		<cfset var result = structNew() />
		<cfset var gatewayID = arguments.event.gatewayID />
		<cfset var botName = getGatewayHelper(gatewayID).getConfiguration().getBotName() />	
		<cfset var commands = 0 />	
		<cfset var obj = 0 />
		<cfset var showHelp = true />
		<cfset var cmdName = "" />
		<cfset var helpLine = "" />
		<cfset var botData = arguments.bot.getBotData(gatewayID) />
		<cfset var learnedCommands = 0 />
		<cfset var numLearnedCommands = 0 />
		<cfset var commandIndex = 0 />
		<!--- this should be a |-delimited list of messages to send to the user privately --->
		<cfset var help = "" &
				"I am #botName#, the channel bot. You can invoke me by name or by using ! and I also watch " &
				"all the conversations so I can remember when people were last on channel (and what they said).|" &
				"I understand the following internal commands:|" &
				"    greet {message} - I'll greet you with that message whenever you join the channel.|" &
				"    learn {cmdname} do {action} - teaches me that !{cmdname} should make me do {action}.|" &
				"    learn {cmdname} say {message} - teaches me that !{cmdname} should make me say {message}.|" &
				"        (I understand ##from## and ##args## in the {action} / {message} and will substitute appropriate values)|" &
				"    message {nickname} {message} - next time I see {nickname}, I'll give them your {message}.|" &
				"    quiet - makes me keep quiet for a while unless spoken to...|" &
				"    seen {nickname} - I'll tell you when I last saw {nickname} on channel and what they said.|" &
				"Examples:|" &
				"    !seen seancorfield|" &
				"    !tag cfapplication|" &
				"The following external commands are also available:" />
		
		<cfif structKeyExists(botData,"processing") and botData.processing>
			<cfset result.response = "MESSAGE" />
			<cfset result.target = arguments.target />
			<cfset result.message = arguments.event.data.sender & ", I'm helping someone else right now!" />
	
			<cfreturn result />
		</cfif>

		<cftry>
			<cfset botData.processing = true />
			<cflog text="Set botData.processing true (#botData.processing#)" type="information" file="seanbot" />
			<cfloop list="#help#" delimiters="|" index="helpLine">
				<cfset arguments.bot.say(gatewayID,arguments.event.data.sender,helpline) />
			</cfloop>
			
			<cfdirectory action="list" directory="#expandPath('commands')#" filter="*.cfc" name="commands" />
			
			<cfloop query="commands">
				<cfset cmdName = left(commands.name,len(commands.name)-4) />
				<cfset showHelp = true />
				<cftry>
					<cfset obj = createObject("component",cmdName) />
					<cfif structKeyExists(getMetadata(obj),"hidden") and getMetadata(obj).hidden and
							arguments.args is not "hidden">
						<cfset showHelp = false />
					</cfif>
					<cfif showHelp>
						<cfif structKeyExists(getMetadata(obj),"hint")>
							<cfset arguments.bot.say(gatewayID,arguments.event.data.sender,
									"    " & cmdName & " " & getMetadata(obj).hint) />
						<cfelse>
							<cfset arguments.bot.say(gatewayID,arguments.event.data.sender,cmdName & " - no hint given for this command!") />
						</cfif>
					</cfif>
					<cfcatch type="any">
						<cfset arguments.bot.say(gatewayID,arguments.event.data.sender,cmdName & " - unable to access this command!") />
					</cfcatch>
				</cftry>
			</cfloop>
			
			<cfif structKeyExists(botData,"memory")>
				<cfset learnedCommands = xmlSearch(botData.memory,"/dictionary/command") />
				<cfset numLearnedCommands = arrayLen(learnedCommands) />
				<cfif numLearnedCommands gt 0>
					<cfset arguments.bot.say(gatewayID,arguments.event.data.sender,"I have been taught the following additional commands:") />
					<cfloop from="1" to="#numLearnedCommands#" index="commandIndex">
						<cfset cmdName = learnedCommands[commandIndex].xmlAttributes["name"] />
						<cfset arguments.bot.say(gatewayID,arguments.event.data.sender,"    " & 
								cmdName & " - " & arguments.bot.getBotTerm(gatewayID,"command",cmdName)) />
					</cfloop>
				</cfif>
			</cfif>
		<cfcatch type="any">
		</cfcatch>
		</cftry>		

		<cfset botData.processing = false />
		<cflog text="Set botData.processing false (#botData.processing#)" type="information" file="seanbot" />
		
		<cfset result.response = "MESSAGE" />
		<cfset result.target = arguments.target />
		<cfset result.message = arguments.event.data.sender & ", I sent you help in a private message!" />

		<cfreturn result />

	</cffunction>

</cfcomponent>
