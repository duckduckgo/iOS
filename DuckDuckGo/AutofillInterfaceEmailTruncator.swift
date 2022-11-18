//
//  AutofillInterfaceEmailTruncator.swift
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

struct AutofillInterfaceEmailTruncator {
    static func truncateEmail(_ email: String, maxLength: Int) -> String {
        let emailComponents = email.components(separatedBy: "@")
        if emailComponents.count > 1 && email.count > maxLength {
            let ellipsis = "..."
            let minimumPrefixSize = 3
            
            let difference = email.count - maxLength + ellipsis.count
            if let username = emailComponents.first,
               let domain = emailComponents.last {
                
                var prefixCount = username.count - difference
                prefixCount = prefixCount < 0 ? minimumPrefixSize : prefixCount
                let prefix = username.prefix(prefixCount)
                
                return "\(prefix)\(ellipsis)@\(domain)"
            }
        }
        
        return email
    }
}

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
        self.setEmailComponentsFromUntruncatedEmail()
        return self.getTruncatedEmail()
    }
    
    private func setEmailToTruncate(_ email: String) {
        self.unTruncatedEmail = email
    }
    
    private func setMaximumLengthOfEmailToTruncate(_ maxLength: Int) {
        self.maximumLengthOfEmailToTruncate = maxLength
    }
    
    private func setEmailComponentsFromUntruncatedEmail() {
        let emailComponents = unTruncatedEmail.components(separatedBy: "@")
        self.userName = emailComponents.first
        self.domainName = emailComponents.last
    }

    private func getTruncatedEmail() -> String {
        if shouldPerformTruncationOnEmail() {
            self.setNumberOfPrefixCharactersToIncludeInUserName()
            self.correctNumberOfCharactersToPrefixUserNameIfNegative()
            return self.getNewTruncatedEmail()
        }
        return unTruncatedEmail
    }

    private func shouldPerformTruncationOnEmail() -> Bool {
        return areUserNameAndDomainNameNotNil() && isEmailLongerThanMaximumLengthOfEmailToTruncate()
    }
    
    private func areUserNameAndDomainNameNotNil() -> Bool {
        return self.userName != nil && self.domainName != nil
    }
    
    private func isEmailLongerThanMaximumLengthOfEmailToTruncate() -> Bool {
        return unTruncatedEmail.count > maximumLengthOfEmailToTruncate
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
        return "\(getTruncatedUserName())@\(domainName!)"
    }
    
    private func getTruncatedUserName() -> String {
        return String(userName!.prefix(numberOfCharactersToPrefixUserName))
    }
    
}
