//
//  EmailTruncator.swift
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

import Foundation

class EmailTruncator {

    private var ellipsis: String!
    private var minimumSizeOfPrefix: Int!
    private var unTruncatedEmail: String!
    private var maximumLengthOfEmailToTruncate: Int!
    private var userName: String?
    private var domainName: String?
    private var numberOfCharactersToPrefixUserName: Int!

    init() {
        self.ellipsis = "..."
        self.minimumSizeOfPrefix = 3
    }
    
    public func truncateEmailToLength(_ email: String, _ maxLength: Int) -> String {
        self.setEmailToTruncate(email)
        self.setMaximumLengthOfEmailToTruncate(maxLength)
        return self.getTruncatedEmail()
    }
    
    private func setEmailToTruncate(_ email: String) {
        self.unTruncatedEmail = email
    }
    
    private func setMaximumLengthOfEmailToTruncate(_ maxLength: Int) {
        self.maximumLengthOfEmailToTruncate = maxLength
    }
    
    private func getTruncatedEmail() -> String {
        if shouldPerformTruncationOnEmail() {
            self.setEmailComponentsFromUntruncatedEmail()
            self.setNumberOfPrefixCharactersToIncludeInUserName()
            self.correctNumberOfCharactersToPrefixUserNameIfNegative()
            return self.getNewTruncatedEmail()
        }
        return unTruncatedEmail
    }

    private func shouldPerformTruncationOnEmail() -> Bool {
        return doesEmailContainAtSymbol() && isEmailLongerThanMaximumLengthOfEmailToTruncate()
    }
        
    private func doesEmailContainAtSymbol() -> Bool {
        return unTruncatedEmail.contains("@")
    }
    
    private func isEmailLongerThanMaximumLengthOfEmailToTruncate() -> Bool {
        return unTruncatedEmail.count > maximumLengthOfEmailToTruncate
    }
    
    private func setEmailComponentsFromUntruncatedEmail() {
        let emailComponents = unTruncatedEmail.components(separatedBy: "@")
        self.userName = emailComponents.first
        self.domainName = emailComponents.last
    }
    
    private func setNumberOfPrefixCharactersToIncludeInUserName() {
        self.numberOfCharactersToPrefixUserName = self.getNumberOfPrefixCharactersToIncludeInUserName()
    }
    
    private func getNumberOfPrefixCharactersToIncludeInUserName() -> Int {
        return userName!.count - self.getDifference()
    }
        
    private func getDifference() -> Int {
        return unTruncatedEmail.count - maximumLengthOfEmailToTruncate + ellipsis.count
    }
    
    private func correctNumberOfCharactersToPrefixUserNameIfNegative() {
        if self.numberOfCharactersToPrefixUserName < 0 {
            self.numberOfCharactersToPrefixUserName = minimumSizeOfPrefix
        }
    }
    
    private func getNewTruncatedEmail() -> String {
        return "\(getTruncatedUserName())\(ellipsis!)@\(domainName!)"
    }
    
    private func getTruncatedUserName() -> String {
        return String(userName!.prefix(numberOfCharactersToPrefixUserName))
    }
    
}
