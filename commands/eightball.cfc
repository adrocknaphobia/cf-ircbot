<!---
   Copyright 2005 Joe Rinehart http://clearsoftware.net/

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

   1.2.0 2005-11-28 Initial version from Joe Rinehart
--->
<cfcomponent hint="- responds with a random 8ball answer, courtesy of Joe Rinehart">

	<cffunction name="execute" returntype="struct" output="false" access="public">
		<cfargument name="bot" type="any" required="true" />
		<cfargument name="event" type="struct" required="true" />
		<cfargument name="target" type="string" required="true" />
		<cfargument name="args" type="string" required="true" />
	
		<cfset var result = structNew() />
		<cfset var quotes = arrayNew(1) />
	
		<cfset arrayAppend(quotes, "Signs point to yes.") />
		<cfset arrayAppend(quotes, "Yes.") />
		<cfset arrayAppend(quotes, "Reply hazy, try again.") />
		<cfset arrayAppend(quotes, "Without a doubt.") />
		<cfset arrayAppend(quotes, "My sources say no.") />
		<cfset arrayAppend(quotes, "As I see it, yes.") />
		<cfset arrayAppend(quotes, "You may rely on it.") />
		<cfset arrayAppend(quotes, "Concentrate and ask again.") />
		<cfset arrayAppend(quotes, "Outlook not so good.") />
		<cfset arrayAppend(quotes, "It is decidedly so.") />
		<cfset arrayAppend(quotes, "Better not tell you now.") />
		<cfset arrayAppend(quotes, "Very doubtful.") />
		<cfset arrayAppend(quotes, "Yes - definitely.") />
		<cfset arrayAppend(quotes, "It is certain.") />
		<cfset arrayAppend(quotes, "Cannot predict now.") />
		<cfset arrayAppend(quotes, "Most likely.") />
		<cfset arrayAppend(quotes, "Ask again later.") />
		<cfset arrayAppend(quotes, "My reply is no.") />
		<cfset arrayAppend(quotes, "Outlook good.") />
		<cfset arrayAppend(quotes, "Don't count on it.") />	

		<cfset result.response = "MESSAGE" />
		<cfset result.target = arguments.target />
		<cfif trim(arguments.args) is "">
			<cfset result.message =  quotes[randRange(1, arrayLen(quotes))] />
		<cfelse>
			<cfset result.message =  arguments.args & " " & quotes[randRange(1, arrayLen(quotes))] />
		</cfif>
	
		<cfreturn result />
	</cffunction>

</cfcomponent>
