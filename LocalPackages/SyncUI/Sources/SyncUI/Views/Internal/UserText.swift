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
// Localise these later, when feature is closer to exernal release
struct UserText {

    static let turnOnTitle = "Turn on Sync?"
    static let turnOnButton = "Turn on Sync"
    static let turnOnMessage = "This will save an encrypted backup of your bookmarks on DuckDuckGo’s servers, which can be synced with your other devices.\n\nThe decryption key is stored on your device and cannot be read by DuckDuckGo."

    static let syncWithAnotherDeviceTitle = "Sync Another Device?"
    static let syncWithAnotherDeviceMessage = "Your bookmarks will be backed up! Would you like to sync another device now?\n\nIf you’ve already set up Sync on another device, this will allow you to combine bookmarks from both devices into a single backup."
    static let syncWithAnotherDeviceButton = "Sync Another Device"

    static let recoveryMessage = "If you lose access to your devices, you will need this code to recover your synced data."

    static let connectDeviceInstructions = "Go to Settings > Sync in the DuckDuckGo App on a different device and scan the QR code to sync."

    static let recoveryModeInstructions = "Scan the QR code on your Recovery PDF, or another synced device, to recover your synced data."

    static let validatingCode = "Validating code"
    static let validatingCodeFailed = "That code does not appear to be valid.  Please try copying it again."

    static let pasteCodeInstructions = "Copy the code from the Settings > Sync page in the DuckDuckGo App on another synced device and paste it here to sync this device."

    static let viewQRCodeInstructions = "Go to Settings > Sync in the DuckDuckGo App on a different device and scan this QR code to sync."
    static let viewQRCodeTitle = "QR Code"

    static let deviceSyncedTitle = "Device Synced!"
    static let deviceSyncedMessage = "Your bookmarks are now syncing with this device."

    static let saveRecoveryTitle = "Save Recovery Key"
    static let saveRecoveryButton = "Save As PDF"

    static let cameraPermissionRequired = "Camera Permission is Required"
    static let cameraPermissionInstructions = "Please go to your device's settings and grant permission for this app to access your camera."
    static let cameraIsUnavailableTitle = "Camera is Unavailable"

    static let goToSettingsButton = "Go to Settings"

    static let syncTitle = "Sync"
    static let syncSettingsInfo = "Sync your bookmarks across your devices and save an encrypted backup on DuckDuckGo’s servers."

    static let thisDevice = "This Device"
    static let connectedDevicesTitle = "Synced Devices"

    static let pasteLabel = "Paste"
    static let copyCodeLabel = "Copy Code"

    static let manuallyEnterCodeLabel = "Manually Enter Code"
    static let manuallyEnterCodeTitle = "Manually Enter Code"

    static let showQRCodeLabel = "Show QR Code"

    static let recoverDataButton = "Recover Your Synced Data"

    static let settingsNewDeviceInstructions = "Go to Settings > Sync in the DuckDuckGo App on a different device and scan to connect instantly"
    static let settingsScanQRCodeButton = "Scan QR Code"
    static let settingsShowCodeButton = "Show Text Code"
    static let settingsSaveRecoveryPDFButton = "Save Recovery PDF"
    static let settingsRecoveryPDFWarning = "If you lose your device, you will need this recovery code to restore your synced data."
    static let settingsDeleteAllButton = "Turn Off and Delete Server Data..."

    static let removeButton = "Remove"
    static let cancelButton = "Cancel"
    static let nextButton = "Next"
    static let notNowButton = "Not Now"
    static let backButton = "Back"

    static func editDevice(named name: String) -> String {
        return "Edit \(name)"
    }

}
// swiftlint:enable line_length
