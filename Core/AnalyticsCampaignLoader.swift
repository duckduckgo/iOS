//
//  AnalyticsCampaignLoader.swift
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


import Foundation


public class AnalyticsCampaignLoader {
    
    public static let shared = AnalyticsCampaignLoader()
    private var analyticsStore: AnalyticsStore
    
    init(analyticsStore: AnalyticsStore = AnalyticsUserDefaults()) {
        self.analyticsStore = analyticsStore
    }
    
    public func load() {
        if analyticsStore.campaignVersion != nil {
            return
        }
        
        let request = CampaignRequest()
        request.execute { campaign, error in
            guard let campaign = campaign else {
                let errorMessage = error?.localizedDescription ?? "no error"
                Logger.log(text: "Campaign atb request failed with error \(errorMessage)")
                return
            }
            self.analyticsStore.campaignVersion = campaign.version
        }
    }
}
