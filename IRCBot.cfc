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

   1.2.0 2005-11-27 Added mailbox / messaging functionality
                    Added learn command (thanx Jared)
                    Removed some external commands in favor of "learned" versions
   1.1.0 2005-11-24 Refactored to use the onXxx event for admin stuff
                    Added otherUser for some events
                    Separated nickname from bot name for memory etc
                    Added greet commands
                    Added ability to extend bot with arbitrary command CFCs
   1.0.0 2005-11-22 Initial version
--->
<cfcomponent name="IRCBot" hint="I am an IRC bot.">

	<cffunction name="onIncomingMessage" returntype="struct" access="public" output="false"
		hint="I am called automatically by the Java gateway code.">
		<cfargument name="event" type="struct" required="true"
			 hint="I contain the event information." />
		<!---
	   		event:
	   			gatewayID - name of bot event gateway
	   			data:
		   			botName	- name of this bot
		   			eventName	- name of onXxx event that triggered this message
		   			channel	- channel on which this message was received
		   					- "" if this was a private message
		   			sender	- nick of person who sent the message
		   			otherUser	- nick of other person in event (kick, nickchange)
		   			login	- login name of sender (ignored)
		   			hostname	- hostname of sender (ignored)
		   			message	- incoming message
	   		result:
	   			response	- MESSAGE | ACTION | SILENT
	   			target	- channel or user to send message back to
	   			message	- message / action to send
	   	--->
	   	<cfset var result = structNew() />
	   	<cfset var response = "SILENT" /> <!--- by default we don't respond --->
	   	<cfset var target = arguments.event.data.channel />
	   	<cfset var message = "" />
	   	<cfset var gatewayID = arguments.event.gatewayID />
	   	<cfset var eventName = arguments.event.data.eventName />
	   	<cfset var from = arguments.event.data.sender />
	   	<cfset var otherUser = arguments.event.data.otherUser />
	   	<cfset var inbound = trim(arguments.event.data.message) />
	   	<cfset var self = arguments.event.data.botName />
	   	<cfset var selfNameLen = len(self) />
	   	<cfset var inLen = len(inbound) />
	   	<cfset var command = "" />
	   	<cfset var cmdArgs = "" />
	   	<cfset var delimiters = ",.:; " />
	   	<cfset var seenLog = getBotSeenLog(gatewayID) />
	   	<cfset var botData = getBotData(gatewayID) />
	   	<cfset var seenRecord = 0 />
	   	<cfset var days = 0 />
	   	<cfset var hours = 0 />
	   	<cfset var minutes = 0 />
	   	
	   	<!--- private message, respond to user if at all --->
	   	<cfswitch expression="#eventName#">
	   	
	   	<cfcase value="onConnect">
			<!--- attempt to restore the snapshot --->
			<cfinvoke component="commands.restore" method="execute" returnvariable="result">
				<cfinvokeargument name="bot" value="#this#" />
				<cfinvokeargument name="event" value="#arguments.event#" />
				<cfinvokeargument name="target" value="" />
				<cfinvokeargument name="args" value="" />
			</cfinvoke>
		</cfcase>
		   	
	   	<cfcase value="onDisconnect">
			<!--- attempt to save a snapshot --->
			<cfinvoke component="commands.snapshot" method="execute" returnvariable="result">
				<cfinvokeargument name="bot" value="#this#" />
				<cfinvokeargument name="event" value="#arguments.event#" />
				<cfinvokeargument name="target" value="" />
				<cfinvokeargument name="args" value="" />
			</cfinvoke>
			<!--- now attempt to start up again --->
			<cfset getGatewayHelper(gatewayID).start() />
		</cfcase>
		   	
		<cfcase value="onPrivateMessage">
	   		<cfset target = from />
	   		<!--- strip ! from private messages in case user forgets --->
	   		<cfif left(inbound,1) is "!">
				<cfset inbound = trim(right(inbound,len(inbound)-1)) />
			</cfif>
		</cfcase>

	   	<cfcase value="onMessage">
	   		<cflock name="#botData.lockName#_seenLog" type="exclusive" timeout="30">
		   		<!--- any messages for this user? --->
				<cfif structKeyExists(seenLog,from) and structKeyExists(seenLog[from],"mailbox")>
					<cfloop collection="#seenLog[from].mailbox#" item="cmdArgs">
						<cfset say(gatewayID,from,cmdArgs & " sent you this message: " & 
								seenLog[from].mailbox[cmdArgs] ) />
					</cfloop>
					<cfset structDelete(seenLog[from],"mailbox") />
				</cfif>
		   		<!--- record the last message from every user --->
		   		<cfset seenRecord = structNew() />
		   		<cfset seenRecord.when = now() />
		   		<cfset seenRecord.said = inbound />
		   		<cfset seenLog[from] = seenRecord />
			</cflock>
	   		<!--- see if the message was for us  --->
	   		<cfif inLen gt selfNameLen and left(inbound,selfNameLen) eq self>
	   			<cfset inbound = trim(right(inbound,len(inbound)-selfNameLen-1)) />
	   		<cfelseif left(inbound,1) is "!">
	   			<!--- possible command with ! --->
	   			<cfset inbound = trim(right(inbound,len(inbound)-1)) />
	   		<cfelse>
	   			<!--- free-form comments in response to general messages --->
	   			<!--- we ignore these in quiet mode --->
	   			<cfif not structKeyExists(botData,"quiet") or botData.quiet eq 0>
	 	   			<cfif findNoCase("modelglue",inbound) or findNoCase("model-glue",inbound)>
						<cfset response = "ACTION" />
						<cfset message = from & ", there's a ##modelglue channel you know..." />
	 	   			<cfelseif findNoCase("machii",inbound) or findNoCase("mach ii",inbound) or
							findNoCase("mach-ii",inbound)>
						<cfset response = "ACTION" />
						<cfset message = from & ", there's a ##machii channel you know..." />
	 	   			<cfelseif findNoCase("osx",inbound) or findNoCase("os x",inbound)>
						<cfset response = "ACTION" />
						<cfset message = from & ", there's a ##cfosx channel you know..." />
	 	   			<cfelseif findNoCase("cfeclipse",inbound)>
						<cfset response = "ACTION" />
						<cfset message = from & ", there's a ##cfeclipse channel you know..." />
	 	   			<cfelseif findNoCase("coldspring",inbound)>
						<cfset response = "ACTION" />
						<cfset message = from & ", there's a ##coldspring channel you know..." />
	 	   			<cfelseif findNoCase("tartan",inbound)>
						<cfset response = "ACTION" />
						<cfset message = from & ", there's a ##tartan channel you know..." />
	 	   			<cfelseif findNoCase("fusebox",inbound)>
						<cfset response = "ACTION" />
						<cfset message = from & ", there's a ##fusebox channel you know..." />
					</cfif>
				</cfif>
	   			<!--- general message, ignore it --->
	   			<cfset inbound = "" />
	   			<cfif structKeyExists(botData,"quiet") and botData.quiet gt 0>
	   				<cflock name="#botData.lockName#_quiet" type="exclusive" timeout="30">
			   			<cfif structKeyExists(botData,"quiet") and botData.quiet gt 0>
				   			<cfset botData.quiet = botData.quiet - 1 />
						</cfif>
					</cflock>
				</cfif>
	   		</cfif>
	   	</cfcase>

		<!--- these are admin commands - triggered by IRC events --->
		<cfcase value="onJoin,onPart,onQuit,onKick,onNickChange" delimiters=",">
			<cfset response = "SILENT" />
			<!--- record the last message from every user --->
			<cfset seenRecord = structNew() />
			<cfset seenRecord.when = now() />
	   		<cflock name="#botData.lockName#_seenLog" type="exclusive" timeout="30">
				<cfswitch expression="#eventName#">
				<cfcase value="onJoin">
					<cfset message = getBotTerm(gatewayID,"greeting",from) />
					<cfif message is not "">
						<cfset say(gatewayID,target,message) />
					</cfif>
					<cfif structKeyExists(seenLog,from) and structKeyExists(seenLog[from],"mailbox")>
						<cfloop collection="#seenLog[from].mailbox#" item="cmdArgs">
							<cfset say(gatewayID,from,cmdArgs & " sent you this message: " & 
									seenLog[from].mailbox[cmdArgs] ) />
						</cfloop>
					</cfif>
					<cfset seenRecord.said = "[#from# joined #target#]" />
				</cfcase>
				<cfcase value="onPart">
					<cfset seenRecord.said = "[#from# left #target#]" />
				</cfcase>
				<cfcase value="onQuit">
					<cfset seenRecord.said = "[#from# quit the server (#inbound#)]" />
				</cfcase>
				<cfcase value="onKick">
					<cfset seenRecord.said = "[#from# was kicked from #target# by #otherUser#]" />
				</cfcase>
				<cfcase value="onNickChange">
					<cfset message = getBotTerm(gatewayID,"greeting",otherUser) />
					<cfif message is not "">
						<cfset say(gatewayID,getGatewayHelper(gatewayID).getConfiguration().getChannelName(),message) />
					</cfif>
					<cfif structKeyExists(seenLog,otherUser) and structKeyExists(seenLog[otherUser],"mailbox")>
						<cfloop collection="#seenLog[otherUser].mailbox#" item="cmdArgs">
							<cfset say(gatewayID,otherUser,cmdArgs & " sent you this message: " & 
									seenLog[otherUser].mailbox[cmdArgs] ) />
						</cfloop>
					</cfif>
					<cfset seenRecord.said = "[#from# changed to #otherUser#]" />
					<cfset seenLog[otherUser] = seenRecord />
				</cfcase>
				</cfswitch>
				<cfset seenLog[from] = seenRecord />
			</cflock>
			<cfset inbound = "" />
		</cfcase>

	   	<cfdefaultcase>
			<cfset inbound = "" />
		</cfdefaultcase>
		
		</cfswitch>
	   	
	   	<cfif inbound is not "">
	   		<!--- pull out the "command" from the message --->
	   		<cfset command = listFirst(inbound,delimiters) />
   			<cfset response = "MESSAGE" />
	   		<cfswitch expression="#command#">
		   		
	   		<!--- remember a greeting for when someone joins a channel --->
	   		<cfcase value="greet">
				<cfset cmdArgs = listRest(inbound,delimiters) />
				<cfset setBotTerm(gatewayID,"greeting",from,cmdArgs) />
				<cfset message = from & ", I'll be sure to greet you next time you return!" />
			</cfcase>
			
			<!--- learn a new command --->
			<cfcase value="learn">
				<!--- syntax learn cmd say/do something --->
				<cfset cmdArgs = listRest(inbound,delimiters) />
				<cfset message = listRest(cmdArgs,delimiters) />
				<cfif listFirst(message,delimiters) is "say" or
						listFirst(message,delimiters) is "do">
					<cfset setBotTerm(gatewayID,"command",listFirst(cmdArgs,delimiters),message) />
					<cfset message = from & ", I know a new command now!" />
				<cfelse>
					<cfset message = "Sorry " & from & ", I don't understand what you are trying to teach me..." />
				</cfif>
			</cfcase>
			
	   		<!--- remember a message for when someone joins a channel --->
	   		<cfcase value="message">
		   		<cflock name="#botData.lockName#_seenLog" type="exclusive" timeout="30">
					<cfset cmdArgs = listRest(inbound,delimiters) />
					<cfif not structKeyExists(seenLog,listFirst(cmdArgs,delimiters))>
						<cfset seenLog[listFirst(cmdArgs,delimiters)] = structNew() />
					</cfif>
					<cfif not structKeyExists(seenLog[listFirst(cmdArgs,delimiters)],"mailbox")>
						<cfset seenLog[listFirst(cmdArgs,delimiters)].mailbox = structNew() />
					</cfif>
					<cfset seenLog[listFirst(cmdArgs,delimiters)].mailbox[from] = listRest(cmdArgs,delimiters) />
					<cfset message = from & ", I'll pass that message on to " & listFirst(cmdArgs,delimiters) & " next time I see them." />
				</cflock>
			</cfcase>
			
			<!--- shut the bot up for a while --->
			<cfcase value="quiet,stfu" delimiters=",">
				<cfset cmdArgs = listRest(inbound,delimiters) />
				<cfif trim(cmdArgs) is "" or not isNumeric(cmdArgs)>
					<cfset cmdArgs = 20 />
				</cfif>
				<cfset botData = getBotData(gatewayID) />
   				<cflock name="#botData.lockName#_quiet" type="exclusive" timeout="30">
		   			<cfset botData.quiet = val(cmdArgs) />
		   			<cfif botData.quiet eq 0>
						<cfset message = from & ", I'll start paying attention again!" />
			   		<cfelse>				
						<cfset message = from & ", I'll be quiet for a while!" />
					</cfif>
				</cflock>
			</cfcase>
			
	   		<!--- seen a user? --->
	   		<cfcase value="seen">
	   			<cfset cmdArgs = listRest(inbound,delimiters) />
	   			<cfif cmdArgs is "">
		   			<cfset message = from & ", seen wha'?" />
		   		<cfelseif cmdArgs is self>
		   			<cfset message = from & ", I'm right in front of you dude!" />
		   		<cfelseif listFirst(cmdArgs," ") is "my">
		   			<cfset message = from & ", I swear I wasn't looking at you!" />
		   		<cfelse>
		   			<cfif structKeyExists(seenLog,cmdArgs) and structKeyExists(seenLog[cmdArgs],"when") and
		   					structKeyExists(seenLog[cmdArgs],"said")>
			   			<cfset minutes = dateDiff("n",seenLog[cmdArgs].when,now()) />
			   			<cfset hours = int(minutes / 60) />
			   			<cfset days = int(hours / 24) />
			   			<cfset hours = hours mod 24 />
			   			<cfset minutes = minutes mod 60 />
		   				<cfset message = cmdArgs & " was last seen on " & timeformat(seenLog[cmdArgs].when,"long") &
		   									" on " & dateformat(seenLog[cmdArgs].when,"medium") & " (" />
		   				<cfif days eq 1>
			   				<cfset message = message & days & " day" />
		   				<cfelseif days neq 0>
							<cfset message = message & days & " days" />
						</cfif>
						<cfif hours eq 1>
							<cfif days neq 0>
								<cfif minutes eq 0>
									<cfset message = message & " and " />
								<cfelse>
									<cfset message = message & ", " />
								</cfif>
							</cfif>
							<cfset message = message & hours & " hour" />
						<cfelseif hours neq 0>
							<cfif days neq 0>
								<cfif minutes eq 0>
									<cfset message = message & " and " />
								<cfelse>
									<cfset message = message & ", " />
								</cfif>
							</cfif>
							<cfset message = message & hours & " hours" />
						</cfif>
						<cfif minutes eq 1>
							<cfif days neq 0 or hours neq 0>
								<cfset message = message & " and " />
							</cfif>
							<cfset message = message & minutes & " minute" />
						<cfelseif minutes neq 0>
							<cfif days neq 0 or hours neq 0>
								<cfset message = message & " and " />
							</cfif>
							<cfset message = message & minutes & " minutes" />
						</cfif>
						<cfif days eq 0 and hours eq 0 and minutes eq 0>
							<cfset message = message & "just now" />
						<cfelse>
							<cfset message = message & " ago" />
						</cfif>
		   				<cfset message = message & ") saying " & seenLog[cmdArgs].said />
		   			<cfelse>
		   				<cfset message = "Sorry " & from & ", I haven't seen " & cmdArgs & " lately." />
		   			</cfif>
	   			</cfif>
	   		</cfcase>
	   		
	   		<cfdefaultcase>
		   		<cftry>
					<cfinvoke component="commands.#command#" method="execute" returnvariable="result">
						<cfinvokeargument name="bot" value="#this#" />
						<cfinvokeargument name="event" value="#arguments.event#" />
						<cfinvokeargument name="target" value="#target#" />
						<cfinvokeargument name="args" value="#listRest(inbound,delimiters)#" />
					</cfinvoke>
					<!--- unpack result to local variables --->
					<cfset response = result.response />
					<cfset target = result.target />
					<cfset message = result.message />
					<cfcatch type="any">
						<cfset command = getBotTerm(gatewayID,"command",command) />
						<cfif command is "">
				   			<cfset message = "Sorry " & from & ", I don't understand " & inbound />
				   		<cfelse>
				   			<cfset message = listRest(command,delimiters) />
				   			<cfif listFirst(command,delimiters) is "say">
								<cfset response = "MESSAGE" />
							<cfelseif listFirst(command,delimiters) is "do">
								<cfset response = "ACTION" />
							</cfif>
							<cfset message = replace(message,"##from##",from,"all") />
							<cfset message = replace(message,"##args##",listRest(inbound,delimiters),"all") />
							<cfif trim(listRest(inbound,delimiters)) is "">
								<cfset message = replace(message,"##args/from##",from,"all") />
							<cfelse>
								<cfset message = replace(message,"##args/from##",listRest(inbound,delimiters),"all") />
							</cfif>
						</cfif>
					</cfcatch>
				</cftry>
	   		</cfdefaultcase>
	   		</cfswitch>
	   	</cfif>

		<!--- fill in the result structure --->	   	
		<cfset result.response = response />
		<cfset result.target = target />
		<cfset result.message = message />
		<cfreturn result />
	</cffunction>
	
	<cffunction name="getBotData" returntype="struct" access="public" output="false"
				hint="I return the core shared data for the bot.">
		<cfargument name="botName" type="string" required="true"
					hint="I am the event gateway name." />

		<cfset var serverKey = "ircbot_" & arguments.botName />
		<cfset var lockName = "server_" & serverKey />

		<cfif not structKeyExists(server,serverKey)>
			<cflock name="#lockName#" type="exclusive" timeout="30">
				<cfif not structKeyExists(server,serverKey)>
					<cfset server[serverKey] = structNew() />
					<cfset server[serverKey].name = arguments.botName />
					<cfset server[serverKey].key = serverKey />
					<cfset server[serverKey].lockName = lockName />
				</cfif>
			</cflock>
		</cfif>

		<cfreturn server["ircbot_" & arguments.botName] />

	</cffunction>
	
	<cffunction name="getBotSeenLog" returntype="struct" access="private" output="false">
		<cfargument name="botName" type="string" required="true" />

		<cfset var botData = getBotData(arguments.botName) />

		<cfif not structKeyExists(botData,"seenLog")>
			<cflock name="#botData.lockName#_seenLog" type="exclusive" timeout="30">
				<cfif not structKeyExists(botData,"seenLog")>
					<cfset botData.seenLog = structNew() />
				</cfif>
			</cflock>
		</cfif>

		<cfreturn botData.seenLog />

	</cffunction>
	
	<cffunction name="getBotMemory" returntype="xml" access="private" output="false">
		<cfargument name="botName" type="string" required="true" />
		
		<cfset var botData = getBotData(arguments.botName) />
		<cfset var memoryFile = "" />
		<cfset var memoryData = "" />
		
		<cfif not structKeyExists(botData,"memory")>
			<cflock name="#botData.lockName#_memory" type="exclusive" timeout="30">
				<cfif not structKeyExists(botData,"memory")>
					<cfset memoryFile = expandPath(arguments.botName & ".xml") />
					<cftry>
						<cffile action="read" file="#memoryFile#" variable="memoryData" />
						<cfset botData.memory = xmlParse(memoryData) />
						<cfcatch type="any">
							<cfset botData.memory = xmlParse("<dictionary></dictionary>") />
						</cfcatch>
					</cftry>
				</cfif>
			</cflock>
		</cfif>
		
		<cfreturn botData.memory />

	</cffunction>
	
	<cffunction name="getBotTerm" returntype="string" access="public" output="false"
				hint="I retrieve a term from the bot's persistent memory.">
		<cfargument name="botName" type="string" required="true" 
					hint="I am the event gateway name."/>
		<cfargument name="section" type="string" required="true"
					hint="I am the section from which to retrieve the term." />
		<cfargument name="key" type="string" required="true"
					hint="I am the key of the term to be retrieved." />
		
		<cfset var data = getBotData(arguments.botName) />
		<cfset var memory = getBotMemory(arguments.botName) />
		<cfset var keys = xmlSearch(memory,"/dictionary/#arguments.section#[@name='#arguments.key#']") />
		<cfset var term = "" />
		
		<cfif arrayLen(keys) eq 1>
			<cfset term = URLDecode(keys[1].xmlText) />
			<cfset term = replace(term,"&lt;","<","all") />
			<cfset term = replace(term,"&gt;",">","all") />
			<cfset term = replace(term,"&amp;","&","all") />
			<cfset term = replace(term,"&apos;","'","all") />
			<cfset term = replace(term,"&quot;","""","all") />
			<cfreturn term />
		<cfelse>
			<cfreturn "" />
		</cfif>
		
	</cffunction>
	
	<cffunction name="setBotTerm" returntype="void" access="public" output="false"
				hint="I store a term in the bot's persistent memory.">
		<cfargument name="botName" type="string" required="true"
					hint="I am the event gateway name." />
		<cfargument name="section" type="string" required="true"
					hint="I am the section in which to store the term." />
		<cfargument name="key" type="string" required="true"
					hint="I am the key of the term to be stored." />
		<cfargument name="value" type="string" required="true"
					hint="I am the value to be stored." />
		
		<cfset var data = getBotData(arguments.botName) />
		<cfset var memory = getBotMemory(arguments.botName) />
		<cfset var keys = xmlSearch(memory,"/dictionary/#arguments.section#[@name='#arguments.key#']") />
		<cfset var elem = "" />
		
		<cfif arrayLen(keys) eq 0 and arguments.value is not "">
			<cflock name="#data.lockname#_memory" type="exclusive" timeout="30">
				<!--- add the new key/value --->
				<cfset elem = xmlElemNew(memory,arguments.section) />
				<cfset elem.xmlAttributes["name"] = arguments.key />
				<cfset elem.xmlText = xmlFormat(trim(arguments.value)) />
				<cfset arrayAppend(memory.xmlRoot.xmlChildren,elem) />
				<cffile action="write" file="#expandPath(arguments.botName & '.xml')#" output="#ToString(memory)#" />
			</cflock>
		<cfelseif arrayLen(keys) eq 1>
			<cflock name="#data.lockname#_memory" type="exclusive" timeout="30">
				<!--- replace the value --->
				<cfset keys[1].xmlText = xmlFormat(trim(arguments.value)) />
				<cffile action="write" file="#expandPath(arguments.botName & '.xml')#" output="#ToString(memory)#" />
			</cflock>
		<cfelse>
			<!--- error! how did the value get duplicated? --->
		</cfif>
		
	</cffunction>
	
	<cffunction name="say" returntype="void" access="public" output="false"
				hint="I send a message to the channel or to a given nickname.">
		<cfargument name="gatewayID" type="string" required="true"
					hint="I am the event gateway name." />
		<cfargument name="target" type="string" required="true"
					hint="I am the channel name or nickname to which the message should be sent." />
		<cfargument name="message" type="string" required="true"
					hint="I am the message to be sent." />
		
		<cfset var response = structNew() />
		
		<cfset response.response = "MESSAGE" />
		<cfset response.target = arguments.target />
		<cfset response.message = arguments.message />
		
		<cfset getGatewayHelper(arguments.gatewayID).sendMessage(response) />
		<cfset createObject("java","java.lang.Thread").sleep(javaCast("int",500)) />
		
	</cffunction>
	
</cfcomponent>
