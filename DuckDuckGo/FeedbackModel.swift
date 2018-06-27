//
//  FeedbackViewModel.swift
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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

struct FeedbackModel {
    
    var url: String?
    var message: String?
    var isBrokenSite: Bool = false
    
    private let feedbackSender: FeedbackSender
    
    init(feedbackSender: FeedbackSender = FeedbackSubmitter()) {
        self.feedbackSender = feedbackSender
    }

    public func canSubmit() -> Bool {
        guard let message = message, !message.trimWhitespace().isEmpty else {
            return false
        }
        
        if isBrokenSite && (url == nil || url!.trimWhitespace().isEmpty) {
            return false
        }
        
        return true
    }
    
    public func submit() {
        
        guard canSubmit() else { return }

        if isBrokenSite {
            feedbackSender.submitBrokenSite(url: url!, message: message!)
        } else {
            feedbackSender.submitMessage(message: message!)
        }
    }
}
