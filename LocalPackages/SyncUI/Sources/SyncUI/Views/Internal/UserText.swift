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

// Sync Set Up
    // Sync With Another Device Card
    static let syncWithAnotherDeviceTitle = NSLocalizedString("sync.with.another.device.title", value: "Begin Syncing", comment: "Title for syncing with another device")
    static let syncWithAnotherDeviceMessage = NSLocalizedString("sync.with.another.device.message", value: "Securely sync bookmarks and passwords between your devices.", comment: "Message for syncing with another device")
    static let syncWithAnotherDeviceButton = NSLocalizedString("sync.with.another.device.button", value: "Sync with Another Device", comment: "Button label for syncing with another device")
    static let syncWithAnotherDeviceFooter = NSLocalizedString("sync.with.another.device.footer", value: "Your data is end-to-end encrypted, and DuckDuckGo does not have access to the encryption key.", comment: "Footer message for syncing with another device")
    // Other Options
    static let syncAndBackUpThisDeviceLink = NSLocalizedString("sync.and.backup.this.device.link", value: "Sync and Back Up This Device", comment: "Link label for syncing and backing up the device")
    static let recoverSyncedDataLink = NSLocalizedString("recover.synced.data.link", value: "Recover Synced Data", comment: "Link label for recovering synced data")
    static let otherOptionsSectionHeader = NSLocalizedString("other.options.section.header", value: "Other Options", comment: "Section header for other syncing options")

// Sync Enabled View
    // Turn Sync Off
    static let turnSyncOff = NSLocalizedString("turn.sync.off", value: "Turn Off Sync & Backup...", comment: "Turn Sync Off - Button")
    static let turnSyncOffSectionHeader = NSLocalizedString("turn.sync.off.section.header", value: "Sync Enabled", comment: "Turn Sync Off - Section Header")
    static let turnSyncOffSectionFooter = NSLocalizedString("turn.sync.off.section.footer", value: "Bookmarks and passwords are currently synced across your devices.", comment: "Turn Sync Off - Section Footer")
    // Sync Paused Errors
    static let syncLimitExceededTitle = NSLocalizedString("sync.limit.exceeded.title", value: "⚠️ Sync Paused", comment: "Sync Paused Errors - Title")
    static let bookmarksLimitExceededDescription = NSLocalizedString("bookmarks.limit.exceeded.description", value: "Bookmark limit exceeded. Delete some to resume syncing.", comment: "Sync Paused Errors - Bookmarks Limit Exceeded Description")
    static let credentialsLimitExceededDescription = NSLocalizedString("credentials.limit.exceeded.description", value: "Logins limit exceeded. Delete some to resume syncing.", comment: "Sync Paused Errors - Credentials Limit Exceeded Description")
    static let bookmarksLimitExceededAction = NSLocalizedString("bookmarks.limit.exceeded.action", value: "Manage Bookmarks", comment: "Sync Paused Errors - Bookmarks Limit Exceeded Action")
    static let credentialsLimitExceededAction = NSLocalizedString("credentials.limit.exceeded.action", value: "Manage Logins", comment: "Sync Paused Errors - Credentials Limit Exceeded Action")
    // Synced Devices
    static let syncedDevicesSectionHeader = NSLocalizedString("synced.devices.section.header", value: "Synced Devices", comment: "Synced Devices - Section Header")
    static let syncedDevicesThisDeviceLabel = NSLocalizedString("synced.devices.this.device.label", value: "This Device", comment: "Synced Devices - This Device Label")
    static let syncedDevicesSyncWithAnotherDeviceLabel = NSLocalizedString("synced.devices.sync.with.another.device.label", value: "Sync with Another Device", comment: "Synced Devices - Sync with Another Device Label")
    // Options
    static let optionsSectionHeader = NSLocalizedString("options.section.header", value: "Options", comment: "Options - Section Header")
    static let unifiedFavoritesTitle = NSLocalizedString("unified.favorites.title", value: "Unify Favorites", comment: "Options - Unify Favorites Title")
    static let unifiedFavoritesInstruction = NSLocalizedString("unified.favorites.instruction", value: "Use the same favorite bookmarks on all your devices. Leave off to keep mobile and desktop favorites separate.", comment: "Options - Unify Favorites Instruction")
    // Save RecoveryPDF
    static let saveRecoveryPDFButton = NSLocalizedString("save.recovery.pdf.button", value: "Save Recovery PDF", comment: "Save RecoveryPDF - Button")
    static let saveRecoveryPDFFooter = NSLocalizedString("save.recovery.pdf.footer", value: "If you lose your device, you will need this recovery code to restore your synced data.", comment: "Save RecoveryPDF - Footer")
    // Delete Server Data
    static let deleteServerData = NSLocalizedString("delete.server.data", value: "Turn Off and Delete Server Data...", comment: "Delete Server Data - Button")

// Connect With Server Sheet
    static let connectWithServerSheetTitle = NSLocalizedString("connect.with.server.sheet.title", value: "Sync and Back Up This Device", comment: "Connect With Server Sheet - Title")
    static let connectWithServerSheetDescriptionPart1 = NSLocalizedString("connect.with.server.sheet.description.part1", value: "This creates an encrypted backup of your bookmarks and passwords on DuckDuckGo’s secure server, which can be synced with your other devices.", comment: "Connect With Server Sheet - Description Part 1")
    static let connectWithServerSheetDescriptionPart2 = NSLocalizedString("connect.with.server.sheet.description.part2", value: "The encryption key is only stored on your device, DuckDuckGo cannot access it.", comment: "Connect With Server Sheet - Description Part 2")
    static let connectWithServerSheetButton = NSLocalizedString("connect.with.server.sheet.button", value: "Turn on Sync & Backup", comment: "Connect With Server Sheet - Button")
    static let connectWithServerSheetFooter = NSLocalizedString("connect.with.server.sheet.footer", value: "You can sync with your other devices later.", comment: "Connect With Server Sheet - Footer")

// Preparing To Sync Sheet
    static let preparingToSyncSheetTitle = NSLocalizedString("preparing.to.sync.sheet.title", value: "Setting Up Sync and Backup", comment: "Preparing To Sync Sheet - Title")
    static let preparingToSyncSheetDescription = NSLocalizedString("preparing.to.sync.sheet.description", value: "Your bookmarks and passwords are being prepared to sync. This should only take a moment.", comment: "Preparing To Sync Sheet - Description")
    static let preparingToSyncSheetFooter = NSLocalizedString("preparing.to.sync.sheet.footer", value: "Connecting…", comment: "Preparing To Sync Sheet - Footer")

// Save Recovery Code Sheet
    static let saveRecoveryCodeSheetTitle = NSLocalizedString("save.recovery.code.sheet.title", value: "Save Recovery Code", comment: "Save Recovery Code Sheet - Title")
    static let saveRecoveryCodeSheetDescription = NSLocalizedString("save.recovery.code.sheet.description", value: "If you lose access to your devices, you will need this code to recover your synced data.", comment: "Save Recovery Code Sheet - Description")
    static let saveRecoveryCodeSheetFooter = NSLocalizedString("save.recovery.code.sheet.footer", value: "Anyone with access to this code can access your synced data, so please keep it in a safe place.", comment: "Save Recovery Code Sheet - Footer")
    static let saveRecoveryCodeCopyCodeButton = NSLocalizedString("save.recovery.code.copy.code.button", value: "Copy Code", comment: "Save Recovery Code Sheet - Copy Code Button")
    static let saveRecoveryCodeSaveAsPdfButton = NSLocalizedString("save.recovery.code.save.as.pdf.button", value: "Save as PDF", comment: "Save Recovery Code Sheet - Save as PDF Button")
    static let saveRecoveryCodeSaveCodeCopiedToast = NSLocalizedString("save.recovery.code.code.copied.button", value: "Recovery code copied to clipboard", comment: "Save Recovery Code Sheet - Copy Code Toast")

// Device Synced Sheet
    static let deviceSyncedSheetTitle = NSLocalizedString("device.synced.sheet.title", value: "Your Data is Synced!", comment: "Device SyncedSheet - Title")

// Recover Synced Data Sheet
    static let recoverSyncedDataTitle = "Recover Synced Data"
    static let recoverSyncedDataDescription = "To restore your synced data, you'll need the Recovery Code you saved when you first set up Sync. This code may have been saved as a PDF on the device you originally used to set up Sync."
    static let recoverSyncedDataButton = "Get Started"

    static let scanQRCode = "Scan QR Code"
    static let enterTextCode = "Enter Text Code"

    static let singleDeviceSetUpTitle = "Single-Device Setup"
    static let singleDeviceSetUpInstruction = "Set up this device now, sync with other devices later."
    static let turnSyncOn = "Start Sync & Backup"
    static let recoverYourData = "Recover Your Data"

    static let syncSettingsFooter = "Your data is end-to-end encrypted, and DuckDuckGo does not have access to the decryption key."

    static let connectDeviceInstructions = "Go to Settings › Sync & Backup in the DuckDuckGo Browser on a another device and select \n”Sync with Another Device.”"

    static let recoveryModeInstructions = "Scan the QR code on your Recovery PDF, or another synced device, to recover your data."

    static let validatingCode = "Validating code"
    static let validatingCodeFailed = "Invalid code."

    static let pasteCodeInstructions = "Copy the code from the\n Settings > Sync & Back Up page in the DuckDuckGo App on another synced device and paste it here to sync this device."

    static let viewQRCodeInstructions = "Open the DuckDuckGo app on another device. Navigate to Settings > Sync & Back Up and scan this QR code."
    static let viewQRCodeTitle = "Your Sync Code"

    static let syngleDeviceConnectedTitle = "All Set!"
    static let deviceSyncedTitle = "Device Synced!"
    static let firstDeviceSyncedMessage = "You can sync this device’s bookmarks and Logins with additional devices at any time from the Sync & Back Up menu in Settings."
    static let deviceSyncedMessage = "Your bookmarks and Logins are now syncing with "
    static let multipleDevicesSyncedMessage = "Your bookmarks and Logins are now syncing on "
    static let wordDevices = "devices"

    static let cameraPermissionRequired = "Camera Permission is Required"
    static let cameraPermissionInstructions = "Please go to your device's settings and grant permission for this app to access your camera."
    static let cameraIsUnavailableTitle = "Camera is Unavailable"

    static let goToSettingsButton = "Go to Settings"

    static let syncTitle = "Sync & Backup"

    static let thisDevice = "This Device"


    static let pasteLabel = "Paste"
    static let copyCodeLabel = "Copy Code"

    static let manuallyEnterCodeTitle = "Enter Text Code"

    static let showQRCodeLabel = "Show QR Code"
    static let showQRCodeSubLabel = "Display code to scan with another device"

    static let settingsNewDeviceInstructions1 = "Go to Settings > Sync in the"
    static let settingsNewDeviceInstructions2 = "DuckDuckGo App"
    static let settingsNewDeviceInstructions3 = "on a different device and scan to connect instantly"
    static let settingsScanQRCodeButton = "Scan QR Code"
    static let settingsShowCodeButton = "Show Text Code"
    static let settingsSaveRecoveryPDFButton = "Save Recovery PDF"
    static let settingsRecoveryPDFWarning = "If you lose your device, you will need this recovery code to restore your synced data."

// Standard Buttons
    static let cancelButton = "Cancel"
    
    static let removeButton = "Remove"
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
