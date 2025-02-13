//
//  ContentBlockerRulesLists.swift
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

import BrowserServicesKit

public final class ContentBlockerRulesLists: DefaultContentBlockerRulesListsSource {

    private let adClickAttribution: AdClickAttributionFeature

    init(trackerDataManager: TrackerDataManager, adClickAttribution: AdClickAttributionFeature) {
        self.adClickAttribution = adClickAttribution
        super.init(trackerDataManager: trackerDataManager)
    }

    public override var contentBlockerRulesLists: [ContentBlockerRulesList] {
        var result = super.contentBlockerRulesLists

        if adClickAttribution.isEnabled,
           let tdsRulesIndex = result.firstIndex(where: { $0.name == Constants.trackerDataSetRulesListName }) {
            let tdsRules = result[tdsRulesIndex]
            let allowlist = adClickAttribution.allowlist
            let allowlistedTrackerNames = allowlist.map { $0.entity }
            let splitter = AdClickAttributionRulesSplitter(rulesList: tdsRules, allowlistedTrackerNames: allowlistedTrackerNames)
            if let splitRules = splitter.split() {
                result.remove(at: tdsRulesIndex)
                result.append(splitRules.0)
                result.append(splitRules.1)
            }
        }

        return result
    }

}
