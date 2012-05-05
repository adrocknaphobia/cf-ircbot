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
<cfcomponent hint="is/are {item}? - retrieves the definition supplied by a know command. The ? is optional.">

	<cffunction name="execute" returntype="struct" access="public" output="false">
		<cfargument name="bot" type="any" required="true" />
		<cfargument name="event" type="struct" required="true" />
		<cfargument name="target" type="string" required="true" />
		<cfargument name="args" type="string" required="true" />

		<cfset var result = structNew() />
		<cfset var gatewayID = arguments.event.gatewayID />
		<cfset var cmdArgs = arguments.args />
		<cfset var message = "" />
		<cfset var from = arguments.event.data.sender />

		<cfset result.response = "MESSAGE" />
		<cfset result.target = arguments.target />

		<cfif right(cmdArgs,1) is "?">
			<cfset cmdArgs = left(cmdArgs,len(cmdArgs)-1) />
		</cfif>
		<cfif len(cmdArgs) gt 3 and 
				(left(cmdArgs,3) is "is " or left(cmdArgs,4) is "are ")>
			<cfset message = arguments.bot.getBotTerm(gatewayID,"key",listRest(cmdArgs," ")) />
			<cfif message is "">
				<cfset message = from & ", sorry but I don't know who " &
						listRest(cmdArgs," ") & " " & listFirst(cmdArgs," ") & "!" />
			<cfelse>
				<cfset message = from & ", I was told that " & listRest(cmdArgs," ") &
						" " & listFirst(cmdArgs," ") & " " & message />
			</cfif>
		<cfelse>
			<cfset message = from & ", sorry but I don't understand that question!" />
		</cfif>
		
		<cfset result.message = message />

		<cfreturn result />

	</cffunction>

</cfcomponent>
