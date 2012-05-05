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

   1.2.0 2005-11-30 News was sent to the channel - fixed! (bug reported by JesusWept)
   1.1.0 2005-11-24 Initial version extracted from IRCBot.cfc
--->
<cfcomponent hint="- display the ten most popular ColdFusion posts from MXNA (in private messages).">

	<cffunction name="execute" returntype="struct" access="public" output="false">
		<cfargument name="bot" type="any" required="true" />
		<cfargument name="event" type="struct" required="true" />
		<cfargument name="target" type="string" required="true" />
		<cfargument name="args" type="string" required="true" />
		
		<cfset var result = structNew() />
		<cfset var ircbot = arguments.bot />
		<cfset var gatewayID = arguments.event.gatewayID />
		<cfset var ws = 0 />
		<cfset var botData = ircbot.getBotData(gatewayID) />
		<cfset var cats = 0 />
		<cfset var catsSelect = 0 />
		<cfset var langs = 0 />
		<cfset var langsSelect = 0 />
		<cfset var cfposts = 0 />
		<cfset var postsSelect = 0 />
		
		<cfif structKeyExists(botData,"processing") and botData.processing>
			<cfset result.response = "MESSAGE" />
			<cfset result.target = arguments.target />
			<cfset result.message = arguments.event.data.sender & ", I'm helping someone else right now!" />
	
			<cfreturn result />
		</cfif>

		<cftry>
			<cfset botData.processing = true />
			
			<cfset ws = createObject("webservice","http://weblogs.macromedia.com/mxna/webservices/mxna2.cfc?wsdl") />
			
			<cfif not structKeyExists(botData,"mxna") or not structKeyExists(botData.mxna,"lastIdCached") or
				  dateDiff('d',botData.mxna.lastIdCached,now()) gt 1>
					  
				<cfset cats = ws.getCategories() />
				<cfquery name="catsSelect" dbtype="query">
					SELECT categoryid FROM cats WHERE categoryname = 'ColdFusion'
				</cfquery>
				<cfset langs = ws.getLanguages() />
				<cfquery name="langsSelect" dbtype="query">
					SELECT languageid FROM langs WHERE languagename = 'English'
				</cfquery>

				<cflock name="#botData.lockName#_mxna" type="exclusive" timeout="30">
					<cfset botData.mxna.cfCatId = catsSelect.categoryid />
					<cfset botData.mxna.enLangId = langsSelect.languageid />
					<cfset botData.mxna.lastIdCached = now() />
				</cflock>
				
			</cfif>

			<cfif not structKeyExists(botData.mxna,"lastQueryCached") or
				  dateDiff('n',botData.mxna.lastQueryCached,now()) gt 15>

				<cfset cfposts = ws.getPostsByCategory(200,0,botData.mxna.cfCatId,botData.mxna.enLangId) />
				<cfquery name="postsSelect" dbtype="query" maxrows="10">
					SELECT clicks, postlink as link, postexcerpt as excerpt, posttitle as title
					FROM cfposts
					ORDER BY clicks DESC
				</cfquery>

				<cflock name="#botData.lockName#_mxna" type="exclusive" timeout="30">
					<cfset botData.mxna.postsSelect = postsSelect />
					<cfset botData.mxna.lastQueryCached = now() />
				</cflock>

			</cfif>

			<cfset postsSelect = botData.mxna.postsSelect />

			<cfset ircbot.say(gatewayID,arguments.event.data.sender,"Most popular ColdFusion posts on MXNA:") />
			<cfloop query="postsSelect">
				<cfset ircbot.say(gatewayID,arguments.event.data.sender,
						"* " & postsSelect.title & " (#postsSelect.clicks#) - " & postsSelect.link) />
			</cfloop>
			<cfset ircbot.say(gatewayID,arguments.event.data.sender,"Via MXNA web service - http://weblogs.macromedia.com/mxna/Developers.cfm") />
			
		<cfcatch type="any">
			<cfset ircbot.say(gatewayID,arguments.event.data.sender,"Unable to retrieve popular posts from MXNA. Please try again later.") />
		</cfcatch>
		
		</cftry>
		
		<cfset botData.processing = false />
		
		<cfset result.response = "MESSAGE" />
		<cfset result.target = arguments.target />
		<cfset result.message = arguments.event.data.sender & ", I just sent you the latest MXNA news in a private message!" />

		<cfreturn result />

	</cffunction>
	
</cfcomponent>
