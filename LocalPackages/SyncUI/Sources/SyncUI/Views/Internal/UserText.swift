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
    static let turnOnMessage = "This will save an encrypted backup of your bookmarks and Autofill logins on DuckDuckGo’s servers, which can be synced with your other devices.\n\nThe decryption key is stored on your device and cannot be read by DuckDuckGo."

    static let syncWithAnotherDeviceTitle = "Sync Another Device?"
    static let syncWithAnotherDeviceMessage = "Your bookmarks and Autofill logins will be backed up! Would you like to sync another device now?\n\nIf you’ve already set up Sync on another device, this will allow you to combine bookmarks and Autofill logins from both devices into a single backup."
    static let syncWithAnotherDeviceButton = "Sync Another Device"

    static let recoveryMessage = "If you lose access to your devices, you will need this code to recover your synced data."

    static let connectDeviceInstructions = "Go to Settings > Sync & Back Up in the DuckDuckGo App on a different device and scan the QR code to sync."

    static let recoveryModeInstructions = "Scan the QR code from your Recovery PDF or in the DuckDuckGo app under Settings > Sync & Back Up on a signed-in device."

    static let validatingCode = "Validating code"
    static let validatingCodeFailed = "Invalid code."

    static let pasteCodeInstructions = "Copy the code from the\n Settings > Sync & Back Up page in the DuckDuckGo App on another synced device and paste it here to sync this device."

    static let viewQRCodeInstructions = "Open the DuckDuckGo app on another device. Navigate to Settings > Sync & Back Up and scan this QR code."
    static let viewQRCodeTitle = "Your Sync Code"

    static let deviceSyncedTitle = "Device Synced!"
    static let firstDeviceSyncedMessage = "You can sync this device’s bookmarks and Logins with additional devices at any time from the Sync & Back Up menu in Settings."
    static let deviceSyncedMessage = "Your bookmarks and Logins are now syncing with "
    static let multipleDevicesSyncedMessage = "Your bookmarks and Logins are now syncing on "
    static let wordDevices = "devices"

    static let saveRecoveryTitle = "Save Recovery Key"
    static let saveRecoveryButton = "Save As PDF"

    static let cameraPermissionRequired = "Camera Permission is Required"
    static let cameraPermissionInstructions = "Please go to your device's settings and grant permission for this app to access your camera."
    static let cameraIsUnavailableTitle = "Camera is Unavailable"

    static let goToSettingsButton = "Go to Settings"

    static let syncTitle = "Sync & Back Up"
    static let syncSettingsInfo = "Sync your bookmarks and Autofill logins across your devices and save an encrypted backup on DuckDuckGo’s servers."

    static let thisDevice = "This Device"
    static let connectedDevicesTitle = "Synced Devices"

    static let pasteLabel = "Paste"
    static let copyCodeLabel = "Copy Code"

    static let manuallyEnterCodeLabel = "Enter Text Code"
    static let manuallyEnterCodeTitle = "Enter Text Code"

    static let showQRCodeLabel = "Show QR Code"
    static let showQRCodeSubLabel = "Display code to scan with another device"

    static let recoverDataButton = "Recover Your Synced Data"

    static let settingsNewDeviceInstructions = "Go to Settings > Sync in the DuckDuckGo App on a different device and scan to connect instantly"
    static let settingsScanQRCodeButton = "Scan QR Code"
    static let settingsShowCodeButton = "Show Text Code"
    static let settingsSaveRecoveryPDFButton = "Save Recovery PDF"
    static let settingsRecoveryPDFWarning = "If you lose your device, you will need this recovery code to restore your synced data."
    static let settingsDeleteAllButton = "Turn Off and Delete Server Data..."

    static let removeButton = "Remove"
    static let cancelButton = "Cancel"
    static let doneButton = "Done"
    static let nextButton = "Next"
    static let notNowButton = "Not Now"
    static let backButton = "Back"

    static let editDeviceLabel = "Device Name"
    static func editDevice(_ name: String) -> String {
        return "Edit \(name)"
    }

    static let removeDeviceTitle = "Remove Device?"
    static let removeDeviceButton = "Remove Device"
    static func removeDeviceMessage(_ name: String) -> String {
        return "\"\(name)\" will no longer be able to access your synced data."
    }

}
// swiftlint:enable line_length
