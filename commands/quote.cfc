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

   1.2.0 2005-12-14 Initial version, requested by fuzie
--->
<cfcomponent hint="{symbol} - display the stock price for the given symbol.">

	<cffunction name="execute" returntype="struct" access="public" output="false">
		<cfargument name="bot" type="any" required="true" />
		<cfargument name="event" type="struct" required="true" />
		<cfargument name="target" type="string" required="true" />
		<cfargument name="args" type="string" required="true" />

		<cfset var result = structNew() />
		<cfset var stockPrice = -1 />

		<cfset result.response = "MESSAGE" />
		<cfset result.target = arguments.target />
		<cfif trim(arguments.args) is not "">
			<cftry>
				<cfinvoke webservice="http://services.xmethods.net/soap/urn:xmethods-delayed-quotes.wsdl" 
					method="getQuote" symbol="#URL.symbol#" returnvariable="stockPrice" />
				<cfif stockPrice eq -1>
					<cfset result.message = arguments.event.data.sender & ", #arguments.args# does not appear to be a valid stock symbol." />
				<cfelse>
					<cfset result.message = arguments.event.data.sender & ", #arguments.args# was trading at $#stockPrice# 20 minutes ago." />
				</cfif>
			<cfcatch type="any">
				<cfset result.message = "Sorry, I can't get a stock quote right now. Try again later!" />
			</cfcatch>	
			</cftry>
		<cfelse>
			<cfset result.message = "If you want a funny quote, ask Marvin!" />
		</cfif>

		<cfreturn result />

	</cffunction>

</cfcomponent>
