//
//  UserContentController.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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

import WebKit
import BrowserServicesKit

final class UserContentController: WKUserContentController {
    
    private(set) var currentRegularRulesLists = [WKContentRuleList]()
    private(set) var currentAttributedRulesList: WKContentRuleList?
    
    func replaceRegularLists(with lists: [WKContentRuleList]) {
        currentRegularRulesLists.forEach(super.remove)
        lists.forEach(super.add)
        
        currentRegularRulesLists = lists
    }
    
    func replaceAttributedList(with list: WKContentRuleList?) {
        if let current = currentAttributedRulesList {
            super.remove(current)
        }
        
        if let list = list {
            super.add(list)
        }
        
        currentAttributedRulesList = list
    }
    
    override func add(_ contentRuleList: WKContentRuleList) {
        assertionFailure("List should be managed through custom UserContentController API")
        super.add(contentRuleList)
    }
    
    override func remove(_ contentRuleList: WKContentRuleList) {
        assertionFailure("List should be managed through custom UserContentController API")
        super.remove(contentRuleList)
    }
}
