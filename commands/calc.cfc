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

   1.2.0 2005-11-26 Initial version, suggested by cesskull
--->
<cfcomponent hint="{expression} - evaluate the expression and display the result.">

	<cffunction name="execute" returntype="struct" access="public" output="false">
		<cfargument name="bot" type="any" required="true" />
		<cfargument name="event" type="struct" required="true" />
		<cfargument name="target" type="string" required="true" />
		<cfargument name="args" type="string" required="true" />

		<cfset var result = structNew() />

		<cfset result.response = "MESSAGE" />
		<cfset result.target = arguments.target />
		<cftry>
			<cfif findNoCase("set",arguments.args) or
					findNoCase("delete",arguments.args) or
					findNoCase("create",arguments.args) or
					findNoCase("evaluate",arguments.args) or
					findNoCase("exists",arguments.args) or
					findNoCase("new",arguments.args) or
					findNoCase("application",arguments.args) or
					findNoCase("server",arguments.args) or
					findNoCase("get",arguments.args)>
				<cfthrow type="expression" message="Attempt to use dangerous function or variable in calc command." />
			</cfif>
			<cfset result.message = arguments.event.data.sender & ", " & 
					arguments.args & " is " & evaluate(arguments.args) />
			<cfcatch type="any">
				<cfset result.message = arguments.event.data.sender & ", that does not appear to be a valid expression!" />
			</cfcatch>
		</cftry>

		<cfreturn result />

	</cffunction>

</cfcomponent>
