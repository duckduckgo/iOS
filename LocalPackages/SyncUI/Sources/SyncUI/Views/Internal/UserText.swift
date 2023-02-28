//
//  UserText.swift
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

// swiftlint:disable line_length
struct UserText {

    static let syncTurnOnMessage = "This will save an encrypted backup of your bookmarks on DuckDuckGo’s servers, which can be synced with your other devices.\n\nThe decryption key is stored on your device and cannot be read by DuckDuckGo."

    static let syncWithAnotherDeviceMessage = "Your bookmarks will be backed up! Would you like to sync another device now?\n\nIf you’ve already set up Sync on another device, this will allow you to combine bookmarks from both devices into a single backup."

    static let syncRecoveryPDFMessage = "If you lose access to your devices, you will need a code to recover your synced data. You can save this code to your device as a PDF.\n\nAnyone with access to this code can access your synced data, so please keep it in a safe place."

}
// swiftlint:enable line_length
