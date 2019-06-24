//
//  easylist-parsing.js
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

(function (){

    duckduckgoDebugMessaging.log("parsing adblock files")
 
    // from https://stackoverflow.com/a/46491780/73479
    function Set_toJSON(key, value) {
      if (typeof value === 'object' && value instanceof Set) {
        return { "ddg_set" : [...value] };
      }
      return value;
    }

    try {

        var easylistPrivacy = `${easylist_privacy}`
        var easylistGeneral = `${easylist_general}`
        var easylistWhitelist = `${easylist_whitelist}`
        
        if (easylistPrivacy != "") {
            ABPFilterParser.parse(easylistPrivacy, duckduckgoBlockerData.easylistPrivacy)
        }
        duckduckgoMessaging.cache("easylist-privacy", JSON.stringify(duckduckgoBlockerData.easylistPrivacy, Set_toJSON))

        if (easylistGeneral != "") {
            ABPFilterParser.parse(easylistGeneral, duckduckgoBlockerData.easylist)
        }
        duckduckgoMessaging.cache("easylist", JSON.stringify(duckduckgoBlockerData.easylist, Set_toJSON))
        
        if (easylistWhitelist != "") {
            ABPFilterParser.parse(easylistWhitelist, duckduckgoBlockerData.easylistWhitelist)
        }
        duckduckgoMessaging.cache("easylist-whitelist", JSON.stringify(duckduckgoBlockerData.easylistWhitelist, Set_toJSON))

    } catch (error) {
        // no-op
    }

})()
