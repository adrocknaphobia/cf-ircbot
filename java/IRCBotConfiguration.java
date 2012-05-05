/*
#   Copyright 2005 Sean A Corfield http://corfield.org/
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#	Changelog:
#		1.1.0	2005-11-23	Exposed as public via helper, added debug, added
#							onXxx method handler configuration
#		1.0.0	2005-11-22	Initial version
 */

package examples.ircbot;

import java.util.*;
import java.io.*;

public class IRCBotConfiguration {
    IRCBotConfiguration( String configFile ) throws java.io.IOException {
        properties = new Properties();
        InputStream configFileStream = new FileInputStream( configFile );
        properties.load( configFileStream );
    }

    public String getBotName() { return properties.getProperty("nick"); }
    public String getBotLogin() { return properties.getProperty("user"); }
    public String getServerName() { return properties.getProperty("server"); }
    public String getChannelName() { return "#" + properties.getProperty("channel"); }
    public boolean isIdentServerNeeded() { return properties.getProperty("ident").equals("yes"); }

    public boolean isDebug() {
    	String debug = properties.getProperty("debug");
    	if (debug == null) {
    		return true;
    	} else {
    		return debug.equals("yes");
    	}
    }

    // CFC method name mappings:
    public String getOnAction() {
    	String method = properties.getProperty("onAction");
    	if (method == null) {
    		return getOnMessage();
    	} else {
    		return method;
    	}
    }
    
    public String getOnJoin() {
    	String method = properties.getProperty("onJoin");
    	if (method == null) {
    		return getOnMessage();
    	} else {
    		return method;
    	}
    }
    
    public String getOnKick() {
    	String method = properties.getProperty("onKick");
    	if (method == null) {
    		return getOnMessage();
    	} else {
    		return method;
    	}
    }
    
    public String getOnMessage() {
    	String method = properties.getProperty("onMessage");
    	if (method == null) {
    		return "onIncomingMessage";
    	} else {
    		return method;
    	}
    }
    
    public String getOnNickChange() {
    	String method = properties.getProperty("onNickChange");
    	if (method == null) {
    		return getOnMessage();
    	} else {
    		return method;
    	}
    }
    
    public String getOnNotice() {
    	String method = properties.getProperty("onNotice");
    	if (method == null) {
    		return getOnMessage();
    	} else {
    		return method;
    	}
    }
    
    public String getOnPart() {
    	String method = properties.getProperty("onPart");
    	if (method == null) {
    		return getOnMessage();
    	} else {
    		return method;
    	}
    }
    
    public String getOnPrivateMessage() {
    	String method = properties.getProperty("onPrivateMessage");
    	if (method == null) {
    		return getOnMessage();
    	} else {
    		return method;
    	}
    }
    
    public String getOnQuit() {
    	String method = properties.getProperty("onQuit");
    	if (method == null) {
    		return getOnMessage();
    	} else {
    		return method;
    	}
    }
    
    public String getOnTopic() {
    	String method = properties.getProperty("onTopic");
    	if (method == null) {
    		return getOnMessage();
    	} else {
    		return method;
    	}
    }
    
    Properties properties;
}
