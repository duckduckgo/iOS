//
//  SyncErrorMessage.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

enum SyncErrorMessage {
    case unableToSyncToServer
    case unableToSyncWithDevice
    case unableToMergeTwoAccounts
    case unableToUpdateDeviceName
    case unableToTurnSyncOff
    case unableToDeleteData
    case unableToRemoveDevice
    case unableToCreateRecoveryPdf

    var title: String {
        return UserText.syncErrorAlertTitle
    }

    var description: String {
        switch self {
        case .unableToSyncToServer:
            return UserText.unableToSyncToServerDescription
        case .unableToSyncWithDevice:
            return UserText.unableToSyncWithOtherDeviceDescription
        case .unableToMergeTwoAccounts:
            return UserText.unableToMergeTwoAccountsErrorDescription
        case .unableToUpdateDeviceName:
            return UserText.unableToUpdateDeviceNameDescription
        case .unableToTurnSyncOff:
            return UserText.unableToTurnSyncOffDescription
        case .unableToDeleteData:
            return UserText.unableToDeleteDataDescription
        case .unableToRemoveDevice:
            return UserText.unableToRemoveDeviceDescription
        case .unableToCreateRecoveryPdf:
            return UserText.unableToCreateRecoveryPDF
        }
    }
}
