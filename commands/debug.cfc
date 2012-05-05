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
<cfcomponent hint="{command} {args} - runs the command and reports any exceptions thrown (for debugging external commands).">

	<cffunction name="execute" returntype="struct" access="public" output="false">
		<cfargument name="bot" type="any" required="true" />
		<cfargument name="event" type="struct" required="true" />
		<cfargument name="target" type="string" required="true" />
		<cfargument name="args" type="string" required="true" />

		<cfset var result = structNew() />
		<cfset var cmd = listFirst(arguments.args," ") />
		<cfset var cmdArgs = listRest(arguments.args," ") />
		<cfset var obj = 0 />

		<cfset result.response = "MESSAGE" />
		<cfset result.target = arguments.target />
		<cfset result.message = "Failed to execute the debug command." />
		
		<cfif trim(cmd) is "">
			<cfset result.message = "The debug command requires an argument: debug {command} {args}" />
			<cfreturn result />
		</cfif>
		
		<cftry>
			<cfset obj = createObject("component",cmd) />
			<cfset result = obj.execute(bot=arguments.bot,
										event=arguments.event,
										target=arguments.target,
										args=cmdArgs) />
			<cfswitch expression="#result.response#">
				<cfcase value="SILENT">
					<cfset result.response = "MESSAGE" />
					<cfset result.target = arguments.target />
					<cfset result.message = "success: '#arguments.args#'" />
				</cfcase>
				<cfcase value="MESSAGE">
					<cfset result.response = "MESSAGE" />
					<cfset result.message = "success: '#arguments.args#' - said '#result.message#' to '#result.target#'" />
					<cfset result.target = arguments.target />
				</cfcase>
				<cfcase value="ACTION">
					<cfset result.response = "MESSAGE" />
					<cfset result.message = "success: '#arguments.args#' - did '#result.message#'" />
					<cfset result.target = arguments.target />
				</cfcase>
			</cfswitch>
			<cfcatch type="any">
				<cfset result.response = "MESSAGE" />
				<cfset result.target = arguments.target />
				<cfset result.message = "exception: '#arguments.args#' - #cfcatch.Type# - #cfcatch.Message# - #cfcatch.Detail#" />
			</cfcatch>
		</cftry>

		<cfreturn result />

	</cffunction>

</cfcomponent>
