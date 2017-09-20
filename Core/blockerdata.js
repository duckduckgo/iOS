//
//  blockerdata.js
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


duckduckgo_decodeBase64 = function(s) {
    var e={},i,b=0,c,x,l=0,a,r='',w=String.fromCharCode,L=s.length;
    var A="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    for(i=0;i<64;i++){e[A.charAt(i)]=i;}
    for(x=0;x<L;x++){
        c=e[s.charAt(x)];b=(b<<6)+c;l+=6;
        while(l>=8){((a=(b>>>(l-=8))&0xff)||(x<(L-2)))&&(r+=w(a));}
    }
    return r;
};


var duckduckgoBlockerData = {

    blockingEnabled: ${blocking_enabled},
	disconnectme: ${disconnectme},
    whitelist: ${whitelist},
    easylist: {},
    easylistPrivacy: {}

}

try {

    ABPFilterParser.parse(function() {

        var easylistData = duckduckgo_decodeBase64("${easylist_general}")
        console.log("Easylist: " + easylistData.substring(0, 100))
        return easylistData
        
    }(), duckduckgoBlockerData.easylist)  

    ABPFilterParser.parse(function() {

        var easylistData = duckduckgo_decodeBase64("${easylist_privacy}")
        console.log("Easylist Privacy: " + easylistData.substring(0, 100))
        return easylistData

    }(), duckduckgoBlockerData.easylistPrivacy)

} catch (error) {

    console.warn("DuckDuckGo: Unable to find ABPFilterParser - some content blocking might not work")
    console.log(error + ", document location: " + document.location)

}
