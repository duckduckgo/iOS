//
//  SyncService.swift
//  DuckDuckGo
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

// This will be fleshed out/changed entirely when we start the backend work
protocol SyncService {

    func retrieveConnectCode() async -> String?
    func createAccount() async

    var recoveryCode: String { get }

}

class FakeSyncService: SyncService {

    let recoveryCode: String = "eyAicmVjb3ZlcnkiOiB7ICJ1c2VyX2lkIjogIjY4RTc4OTlBLTQ5OTQtNEUzMi04MERDLT" +
    "gyNzNFMDc1MUExMSIsICJwcmltYXJ5X2tleSI6ICJNVEl6TkRVMk56ZzVN" +
    "REV5TXpRMU5qYzRPVEF4TWpNME5UWTNPRGt3TVRJPSIgfSB9"

    func retrieveConnectCode() async -> String? {
        if #available(iOS 16.0, *) {
            try? await Task.sleep(for: .milliseconds(500))
        }
        return "Fake Connect Code"
    }

    func createAccount() async {
        if #available(iOS 16.0, *) {
            try? await Task.sleep(for: .seconds(2))
        }
    }

}
