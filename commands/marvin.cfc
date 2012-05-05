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
<cfcomponent hint="- responds with a random quote from Marvin (the Paranoid Android), courtesy of Joe Rinehart">

	<cffunction name="execute" returntype="struct" output="false" access="public">
		<cfargument name="bot" type="any" required="true" />
		<cfargument name="event" type="struct" required="true" />
		<cfargument name="target" type="string" required="true" />
		<cfargument name="args" type="string" required="true" />
	
		<cfset var result = structNew() />
		<cfset var quotes = arrayNew(1) />
		
		<cfset arrayAppend(quotes, "Freeze? I'm a robot. I'm not a refrigerator.") />
		<cfset arrayAppend(quotes, "I've been talking to the main computer....it hates me.") />	
		<cfset arrayAppend(quotes, "I think you ought to know I'm feeling very depressed.") />	
		<cfset arrayAppend(quotes, "Life? Don't talk to me about life!") />	
		<cfset arrayAppend(quotes, "[as they are gazing at the wonder of Magrathea] Incredible... it's even worse than I thought it would be.") />	
		<cfset arrayAppend(quotes, "I've calculated your chance of survival, but I don't think you'll like it. ") />	
		<cfset arrayAppend(quotes, "I don't know what you're all worried about. Vogons are the worst marksmen in the galaxy. [Marvin is shot in the head.] Now I've got a headache. ") />	
		<cfset arrayAppend(quotes, "This will all end in tears.") />	
		<cfset arrayAppend(quotes, "Here I am, brain the size of a planet, and they ask me to take you to the bridge. Call that job satisfaction, 'cause I don't. ") />	
		<cfset arrayAppend(quotes, "The first ten million years were the worst, and the second ten million, they were the worst too. The third ten million I didn't enjoy at all. After that I went into a bit of a decline.") />	
		<cfset arrayAppend(quotes, "That young girl is one of the least benightedly unintelligent organiclife forms it has been my profound lack of pleasure not to be able to avoid meeting.") />	
		<cfset arrayAppend(quotes, "Life, loathe it or ignore it, you can't like it.") />	
		<cfset arrayAppend(quotes, "I'm not getting you down at all, am I?") />	
		<cfset arrayAppend(quotes, "Pardon me for breathing, which I never do any way so I don't know why I bother to say it, oh God, I'm so depressed.") />	
		<cfset arrayAppend(quotes, "Funny, how just when you think life can't possibly get any worse it suddenly does.") />	
		<cfset arrayAppend(quotes, "Do you want me to sit in the corner and rust, or just fall apart where I'm standing?") />	
		<cfset arrayAppend(quotes, "Would you like me to go and stick my head in a bucket of water?") />	
		<cfset arrayAppend(quotes, "Life's bad enough as it is without wanting to invent any more of it.") />	
		<cfset arrayAppend(quotes, "My capacity for happiness, you could fit it into a matchbox without taking out the matches first.") />	
		<cfset arrayAppend(quotes, "Ha, but my life is a box of wormgears.") />	
		<cfset arrayAppend(quotes, "Wearly I sit here, pain and misery my only companions.") />	
		<cfset arrayAppend(quotes, "Why stop now just when I'm hating it?") />	
	
		<cfset result.response = "MESSAGE" />
		<cfset result.target = arguments.target />
		<cfset result.message =  quotes[randRange(1, arrayLen(quotes))]/>
		
		<cfreturn result />
	</cffunction>
	
</cfcomponent>
