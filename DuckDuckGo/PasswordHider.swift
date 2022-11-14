//
//  PasswordHider.swift
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

class PasswordHider {
    
    private var unhiddenPassword: String!
    private var maximumLengthOfHiddenPassword: Int!
    private var hiddenPassword: String!
    
    init(unhiddenPassword: String) {
        self.unhiddenPassword = unhiddenPassword
        self.maximumLengthOfHiddenPassword = 40
        self.createHiddenPasswordString()
    }
    
    private func createHiddenPasswordString() {
        self.hiddenPassword = String(repeating: "•", count: getNumberOfCharactersToDisplayInHiddenPasswordString())
    }
    
    private func getNumberOfCharactersToDisplayInHiddenPasswordString() -> Int {
        if isUnhiddenPasswordLongerThanMaximumLengthOfHiddenPassword() {
            return maximumLengthOfHiddenPassword
        }
        return unhiddenPassword.count
    }
    
    private func isUnhiddenPasswordLongerThanMaximumLengthOfHiddenPassword() -> Bool {
        return unhiddenPassword.count > maximumLengthOfHiddenPassword
    }
        
    public func getHiddenPasswordString() -> String {
        return hiddenPassword
    }
    
}
