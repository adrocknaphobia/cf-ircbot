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

   1.1.0 2005-11-24 Initial version
--->
<cfcomponent hint="{item} is {definition} - remembers that information for what/who questions (see below).">

	<cffunction name="execute" returntype="struct" access="public" output="false">
		<cfargument name="bot" type="any" required="true" />
		<cfargument name="event" type="struct" required="true" />
		<cfargument name="target" type="string" required="true" />
		<cfargument name="args" type="string" required="true" />

		<cfset var result = structNew() />
		<cfset var cmdArgs = arguments.args />
		<cfset var from = arguments.event.data.sender />
		<cfset var gatewayID = arguments.event.gatewayID />

		<cfset result.response = "MESSAGE" />
		<cfset result.target = arguments.target />
		<cfif find(" is ",cmdArgs)>
			<cfset cmdArgs = replace(cmdArgs," is ","=") />
			<cfset arguments.bot.setBotTerm(gatewayID,"key",listFirst(cmdArgs,"="),listRest(cmdArgs,"=")) />
			<cfset result.message = from & ", I know about " & listFirst(cmdArgs,"=") & " now." />
		<cfelse>
			<cfset result.message = from & ", sorry but I don't understand what you are telling me - perhaps you should ask for help?" />
		</cfif>

		<cfreturn result />

	</cffunction>

</cfcomponent>
