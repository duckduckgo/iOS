//
//  AccountStorage.swift
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

public protocol AccountStorage: AnyObject {
    func getAuthToken() throws -> String?
    func store(authToken: String) throws
    func getAccessToken() throws -> String?
    func store(accessToken: String) throws
    func getEmail() throws -> String?
    func store(email: String?) throws
    func getExternalID() throws -> String?
    func store(externalID: String?) throws
    func clearAuthenticationState() throws
}
