//
//  AccessChannel.swift
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

public enum AccessChannel: String, CaseIterable, Identifiable {
    public var id: Self { self }

    case appleID, email, sync

    var title: String {
        switch self {
        case .appleID:
            return UserText.appleID
        case .email:
            return UserText.email
        case .sync:
            return UserText.sync
        }
    }

    var iconName: String {
        switch self {
        case .appleID:
            return "apple-id-icon"
        case .email:
            return "email-icon"
        case .sync:
            return "sync-icon"
        }
    }
}
