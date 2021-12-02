//
//  textsize.js
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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

(function() {
    let hostname = getTopLevelURL().hostname;
    
    let knownDynamicTypeExceptions = `$KNOWN_DYNAMIC_TYPE_EXCEPTIONS$`.split("\n");
    
    let shouldAdjustForDynamicType = isURLMatchingAnyOfDomains(hostname, knownDynamicTypeExceptions);
    let isDDG = isURLMatchingDomain(hostname, "duckduckgo.com");
    
    let currentTextSizeAdjustment = $TEXT_SIZE_ADJUSTMENT_IN_PERCENTS$;
    
    if (document.readyState === "complete"
        || document.readyState === "loaded"
        || document.readyState === "interactive") {
        // DOM should have been parsed
        adjustTextSize(currentTextSizeAdjustment);
    } else {
        // DOM not yet ready, add a listener instead
        if ((shouldAdjustForDynamicType) || (isDDG) || (currentTextSizeAdjustment != 100)) {
            document.addEventListener("DOMContentLoaded", function(event) {
                adjustTextSize(currentTextSizeAdjustment);
            }, false)
        }
    }
    
    function getTopLevelURL() {
        try {
            // FROM: https://stackoverflow.com/a/7739035/73479
            // FIX: Better capturing of top level URL so that trackers in embedded documents are not considered first party
            return new URL(window.location != window.parent.location ? document.referrer : document.location.href)
        } catch(error) {
            return new URL(location.href)
        }
    }
    
    function isURLMatchingDomain(url, domain) {
        var urlParts = url.split('.');
        
        while (urlParts.length > 1) {
            if (domain === urlParts.join('.')) {
                return true;
            }
            
            urlParts.shift();
        }
        
        return false;
    }
    
    function isURLMatchingAnyOfDomains(url, domains) {
        for (const domain of domains) {
            if (isURLMatchingDomain(url, domain)) {
                return true
            }
        }
        
        return false
    }
    
    function adjustTextSize(percentage) {
        if (shouldAdjustForDynamicType) {
            adjustTextSizeForDynamicType(percentage);
        } else if (isDDG && (typeof DDG !== 'undefined')) {
            adjustTextSizeForDDG(percentage);
        } else {
            document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust=percentage+"%";
        }
    }
    
    function adjustTextSizeForDynamicType(percentage) {
        let dynamicTypeAdjustment = $DYNAMIC_TYPE_SCALE_PERCENTAGE$;
        var adjustedPercentage = percentage * 100/dynamicTypeAdjustment;
        
        document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust=adjustedPercentage+"%";
    }
    
    function adjustTextSizeForDDG(percentage) {
        var adjustedPercentage = 100;
        
        // Fix for side menu sliding in when growing due to increased text
        let menu = document.getElementsByClassName('nav-menu--slideout')[0];
        let previousLeft = menu.style.left;
        menu.style.left="-100%";
        
        // Force re-painting of the menu: https://stackoverflow.com/a/3485654
        menu.style.display='none';
        menu.offsetHeight; // no need to store this anywhere, the reference is enough
        menu.style.display='block';
        
        switch(percentage) {
            case 80:
                DDG.settings.set('ks', 's');
                break;
            case 90:
                DDG.settings.set('ks', 'm');
                break;
            case 100:
                DDG.settings.set('ks', 'n');
                break;
            case 110:
                DDG.settings.set('ks', 'n');
                adjustedPercentage = 105;
                break;
            case 120:
                DDG.settings.set('ks', 'l');
                break;
            case 130:
                DDG.settings.set('ks', 'l');
                adjustedPercentage = 105;
                break;
            case 140:
                DDG.settings.set('ks', 'l');
                adjustedPercentage = 110;
                break;
            case 150:
                DDG.settings.set('ks', 't');
                break;
            case 160:
                DDG.settings.set('ks', 't');
                adjustedPercentage = 105;
                break;
            case 170:
                DDG.settings.set('ks', 't');
                adjustedPercentage = 110;
                break;
            default:
                DDG.settings.set('ks', 'n');
                break;
        }
        
        document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust=adjustedPercentage+"%";
        
        menu.style.left = previousLeft;
    }
    
}) ();
