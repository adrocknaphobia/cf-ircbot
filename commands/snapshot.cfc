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

   1.1.0 2005-11-25 Initial version
--->
<cfcomponent hidden="true" hint="- this takes a snapshot of the bot's data.">

	<cffunction name="execute" returntype="struct" access="public" output="false">
		<cfargument name="bot" type="any" required="true" />
		<cfargument name="event" type="struct" required="true" />
		<cfargument name="target" type="string" required="true" />
		<cfargument name="args" type="string" required="true" />

		<cfset var result = structNew() />
		<cfset var gatewayID = arguments.event.gatewayID />
		<cfset var botData = arguments.bot.getBotData(gatewayID) />
		<cfset var botDataWDDX = "" />
		
		<cflock name="#botData.lockName#_seenLog" type="exclusive" timeout="30">
			<cfwddx action="cfml2wddx" input="#botData.seenLog#" output="botDataWDDX" />
			<cffile action="write" file="#expandPath(gatewayID & '_snapshot.xml')#" output="#botDataWDDX#" />
		</cflock>

		<cfset result.response = "ACTION" />
		<cfset result.target = arguments.target />
		<cfset result.message = "took a snapshot of its data." />

		<cfreturn result />

	</cffunction>

</cfcomponent>
