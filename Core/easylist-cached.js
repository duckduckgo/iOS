//
//  easylist-cached.js
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

duckduckgoBlockerData.easylist = ${easylist_general_json}
duckduckgoBlockerData.easylistPrivacy = ${easylist_privacy_json}
duckduckgoBlockerData.easylistWhitelist = ${easylist_whitelist_json}

function duckduckgoEasylistRepair(parserData) {
	parserData.bloomFilter = new BloomFilterModule.BloomFilter(parserData.bloomFilter)
	parserData.exceptionBloomFilter = new BloomFilterModule.BloomFilter(parserData.exceptionFilter)
}

if (Object.keys(duckduckgoBlockerData.easylist).length > 0) {
	duckduckgoEasylistRepair(duckduckgoBlockerData.easylist)	
}

if (Object.keys(duckduckgoBlockerData.easylistPrivacy).length > 0) {
	duckduckgoEasylistRepair(duckduckgoBlockerData.easylistPrivacy)
}

if (Object.keys(duckduckgoBlockerData.easylistWhitelist).length > 0) {
	duckduckgoEasylistRepair(duckduckgoBlockerData.easylistWhitelist)
}
