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

   1.2.0 2005-11-27 Initial version
--->
<cfcomponent hint="{title} - I'll try to tell you the IMDB link for that movie.">

	<cffunction name="execute" returntype="struct" access="public" output="false">
		<cfargument name="bot" type="any" required="true" />
		<cfargument name="event" type="struct" required="true" />
		<cfargument name="target" type="string" required="true" />
		<cfargument name="args" type="string" required="true" />

		<cfset var result = structNew() />

		<cfset result.response = "MESSAGE" />
		<cfset result.target = arguments.target />
		<cfif trim(arguments.args) is "">
			<cfset result.message = arguments.event.data.sender &
					", lookup what movie?" />
		<cfelse>
			<cfhttp url="http://imdb.com/find?q=#arguments.args#;s=all" redirect="false" />
			<cfif left(cfhttp.StatusCode,3) is "302">
				<cfset result.message = arguments.event.data.sender & ", " &
						arguments.args & " can be found at " & rereplace(cfhttp.responseHeader.Location,"(.*/).*","\1") />
			<cfelseif find("Titles (Exact Matches)",cfhttp.FileContent)>
				<cfset result.message = arguments.event.data.sender & ", " & 
						arguments.args & " can be found at http://imdb.com/title/tt" &
						rereplace(cfhttp.filecontent,".*Titles \(Exact Matches\).*?<a href=""/title/tt([0-9]*/).*","\1") />
			<cfelseif find("Popular Titles",cfhttp.FileContent)>
				<cfset result.message = arguments.event.data.sender & ", " & 
						arguments.args & " can be found at http://imdb.com/title/tt" &
						rereplace(cfhttp.filecontent,".*Popular Titles.*?<a href=""/title/tt([0-9]*/).*","\1") />
			<cfelse>
				<cfset result.message = arguments.event.data.sender & 
						", sorry but I don't know that movie!" />
			</cfif>
		</cfif>

		<cfreturn result />

	</cffunction>

</cfcomponent>
