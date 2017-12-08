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

try {

    ABPFilterParser.parse(`${easylist_privacy}`, duckduckgoBlockerData.easylistPrivacy)
    duckduckgoMessaging.cache("easylist-privacy", JSON.stringify(duckduckgoBlockerData.easylistPrivacy))

    ABPFilterParser.parse(`${easylist_general}`, duckduckgoBlockerData.easylist)
    duckduckgoMessaging.cache("easylist", JSON.stringify(duckduckgoBlockerData.easylist))

    ABPFilterParser.parse(`${easylist_whitelist}`, duckduckgoBlockerData.easylistWhitelist)
    duckduckgoMessaging.cache("easylist-whitelist", JSON.stringify(duckduckgoBlockerData.easylistWhitelist))

} catch (error) {
    // no-op
}
