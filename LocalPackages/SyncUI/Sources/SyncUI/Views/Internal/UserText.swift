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

    // Sync Title
    static let syncTitle = NSLocalizedString("sync.title", value: "Sync & Backup", comment: "Sync & Backup Title")

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
    static let fetchFaviconsOptionTitle = NSLocalizedString("fetch.favicons.option.title", value: "Auto-Download Icons", comment: "Automatically download icons for your synced bookmarks. Icon downloads are exposed to your network.")
    static let fetchFaviconsOptionCaption = NSLocalizedString("fetch.favicons.option.caption", value: "Automatically download icons for synced bookmarks.", comment: "Options - Fetch Favicons Caption")

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
    static let recoverSyncedDataTitle = NSLocalizedString("recover.synced.data.sheet.title", value: "Recover Synced Data", comment: "Recover Synced Data Sheet - Title")
    static let recoverSyncedDataDescription = NSLocalizedString("recover.synced.data.sheet.description", value: "To restore your synced data, you'll need the Recovery Code you saved when you first set up Sync. This code may have been saved as a PDF on the device you originally used to set up Sync.", comment: "Recover Synced Data Sheet - Description")
    static let recoverSyncedDataButton = NSLocalizedString("recover.synced.data.sheet.button", value: "Get Started", comment: "Recover Synced Data Sheet - Button")

    // Scan Or Enter Code To Recover Synced Data View
    static let scanCodeToRecoverSyncedDataTitle = NSLocalizedString("scan.code.to.recover.synced.data.title", value: "Recover Synced Data", comment: "Scan Or Enter Code To Recover Synced Data View - Title")
    static let scanCodeToRecoverSyncedDataExplanation = NSLocalizedString("scan.code.to.recover.synced.data.explanation", value: "Scan the QR code on your Recovery PDF, or another synced device, to recover your data.", comment: "Scan Or Enter Code To Recover Synced Data View - Explanation")
    static let scanCodeToRecoverSyncedDataFooter = NSLocalizedString("scan.code.to.recover.synced.data.footer", value: "Can’t Scan?", comment: "Scan Or Enter Code To Recover Synced Data View - Footer")
    static let scanCodeToRecoverSyncedDataEnterCodeLink = NSLocalizedString("scan.code.to.recover.synced.data.enter.code.link", value: "Enter Text Code Manually", comment: "Scan Or Enter Code To Recover Synced Data View - Enter Code Link")

    // Camera View
    static let cameraPointCameraIndication = NSLocalizedString("camera.point.camera.indication", value: "Point camera at QR code to sync", comment: "Camera View - Point Camera Indication")
    static let cameraPermissionRequired = NSLocalizedString("camera.permission.required", value: "Camera Permission is Required", comment: "Camera View - Permission Required")
    static let cameraPermissionInstructions = NSLocalizedString("camera.permission.instructions", value: "Please go to your device's settings and grant permission for this app to access your camera.", comment: "Camera View - Permission Instructions")
    static let cameraIsUnavailableTitle = NSLocalizedString("camera.is.unavailable.title", value: "Camera is Unavailable", comment: "Camera View - Unavailable Title")
    static let cameraGoToSettingsButton = NSLocalizedString("camera.go.to.settings.button", value: "Go to Settings", comment: "Camera View - Go to Settings Button")

    // Manually Enter Code View
    static let manuallyEnterCodeTitle = NSLocalizedString("manually.enter.code.title", value: "Manually Enter Code", comment: "Manually Enter Code View - Title")
    static let manuallyEnterCodeValidatingCodeAction = NSLocalizedString("manually.enter.code.validating.code.action", value: "Validating code", comment: "Manually Enter Code View - Validating Code Action")
    static let manuallyEnterCodeValidatingCodeFailedAction = NSLocalizedString("manually.enter.code.validating.code.failed.action", value: "Invalid code.", comment: "Manually Enter Code View - Validating Code Failed Action")
    static func manuallyEnterCodeInstructionAttributed(syncMenuPath: String, menuItem: String) -> String {
        let localized = NSLocalizedString("manually.enter.code.instruction.attributed", value: "Go to %@ and select %@ in the DuckDuckGo App on another synced device and paste the code here to sync this device.", comment: "Manually Enter Code View - Instruction with sync menu path and view text code menu item inserted")
        return String(format: localized, syncMenuPath, menuItem)
    }
    static let manuallyEnterCodeInstruction = NSLocalizedString("manually.enter.code.instruction", value: "Go to Settings > Sync & Backup > Sync With Another Device and select Sync Menu Path in the DuckDuckGo App on another synced device and paste the code here to sync this device.", comment: "Manually Enter Code View - Instruction with sync menu path and view text code menu item inserted")
    static let syncMenuPath = NSLocalizedString("sync.menu.path", value: "Settings > Sync & Backup > Sync With Another Device", comment: "Sync Menu Path")
    static let viewTextCodeMenuItem = NSLocalizedString("view.text.code.menu.item", value: "View Text Code", comment: "View Text Code menu item")

    // Scan or See Code View
    static let scanOrSeeCodeTitle = NSLocalizedString("scan.or.see.code.title", value: "Scan QR Code", comment: "Scan or See Code View - Title")
    static let scanOrSeeCodeInstruction = NSLocalizedString("scan.or.see.code.instruction", value: "Go to Settings › Sync & Backup in the DuckDuckGo Browser on another device and select ”Sync with Another Device.”", comment: "Scan or See Code View - Instruction")
    static func scanOrSeeCodeInstructionAttributed(syncMenuPath: String) -> String {
        let localized = NSLocalizedString("scan.or.see.code.instruction.attributed", value: "Go to %@ in the DuckDuckGo Browser on another device and select ”Sync with Another Device.”.", comment: "Scan or See Code View - Instruction with syncMenuPath")
        return String(format: localized, syncMenuPath)
    }

    static let scanOrSeeCodeInstructionPart3 = NSLocalizedString("scan.or.see.code.instruction.part3", value: "in the DuckDuckGo Browser on another device and select ”Sync with Another Device.”", comment: "Scan or See Code View - Instruction Part 3")
    static let scanOrSeeCodeManuallyEnterCodeLink = NSLocalizedString("scan.or.see.code.manually.enter.code.link", value: "Manually Enter Code", comment: "Scan or See Code View - Manually Enter Code Link")
    static let scanOrSeeCodeScanCodeInstructionsTitle = NSLocalizedString("scan.or.see.code.scan.code.instructions.title", value: "Mobile-to-Mobile?", comment: "Scan or See Code View - Scan Code Instructions Title")
    static let scanOrSeeCodeScanCodeInstructionsBody = NSLocalizedString("scan.or.see.code.scan.code.instructions.body", value: "Scan this code with another device to sync.", comment: "Scan or See Code View - Scan Code Instructions Body")
    static let scanOrSeeCodeFooter = NSLocalizedString("scan.or.see.code.footer", value: "Can’t Scan?", comment: "Scan or See Code View - Footer")
    static let scanOrSeeCodeShareCodeLink = NSLocalizedString("scan.or.see.code.share.code.link", value: "Share Text Code?", comment: "Scan or See Code View - Share Code Link")

    // Edit Device View
    static let editDeviceHeader = NSLocalizedString("edit.device.header", value: "Device Name", comment: "Edit Device View - Header")
    static func editDeviceTitle(_ name: String) -> String {
        return NSLocalizedString("edit.device.title", value: "Edit \(name)", comment: "Edit Device View - Title")
    }

    // Remove Device View
    static let removeDeviceTitle = NSLocalizedString("remove.device.title", value: "Remove Device?", comment: "Remove Device View - Title")
    static let removeDeviceButton = NSLocalizedString("remove.device.button", value: "Remove Device", comment: "Remove Device View - Button")
    static func removeDeviceMessage(_ name: String) -> String {
        return NSLocalizedString("remove.device.message", value: "\"\(name)\" will no longer be able to access your synced data.", comment: "Remove Device View - Message")
    }

    // Standard Buttons
    static let cancelButton = NSLocalizedString("cancel.button", value: "Cancel", comment: "Standard Buttons - Cancel Button")
    static let doneButton = NSLocalizedString("done.button", value: "Done", comment: "Standard Buttons - Done Button")
    static let nextButton = NSLocalizedString("next.button", value: "Next", comment: "Standard Buttons - Next Button")
    static let backButton = NSLocalizedString("back.button", value: "Back", comment: "Standard Buttons - Back Button")
    static let pasteButton = NSLocalizedString("paste.button", value: "Paste", comment: "Standard Buttons - Paste Button")
    static let notNowButton = NSLocalizedString("not.now.button", value: "Not Now", comment: "Standard Buttons - Not Now Button")

    // Fetch favicons
    static let fetchFaviconsOnboardingTitle = NSLocalizedString("fetch.favicons.onboarding.title", value: "Download Missing Icons?", comment: "Fetch Favicons Onboarding - Title")
    static let fetchFaviconsOnboardingMessage = NSLocalizedString("fetch.favicons.onboarding.message", value: "Do you want this device to automatically download icons for any new bookmarks synced from your other devices? This will expose the download to your network any time a bookmark is synced.", comment: "Fetch Favicons Onboarding - Message")
    static let fetchFaviconsOnboardingButtonTitle = NSLocalizedString("fetch.favicons.onboarding.button.title", value: "Keep Bookmarks Icons Updated", comment: "Fetch Favicons Onboarding - Button Title")


    // swiftlint:enable line_length
}
