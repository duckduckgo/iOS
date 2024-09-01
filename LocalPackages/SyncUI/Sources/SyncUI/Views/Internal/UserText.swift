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

public struct UserText {

    // Sync Title
    public static let syncTitle = NSLocalizedString("sync.title", bundle: Bundle.module, value: "Sync & Backup", comment: "Sync & Backup Title")

    // Sync Set Up
    // Sync With Another Device Card
    static let syncWithAnotherDeviceTitle = NSLocalizedString("sync.with.another.device.title", bundle: Bundle.module, value: "Begin Syncing", comment: "Title for syncing with another device")
    static let syncWithAnotherDeviceMessage = NSLocalizedString("sync.with.another.device.message", bundle: Bundle.module, value: "Securely sync bookmarks and passwords between your devices.", comment: "Message for syncing with another device")
    static let syncWithAnotherDeviceButton = NSLocalizedString("sync.with.another.device.button", bundle: Bundle.module, value: "Sync With Another Device", comment: "Button label for syncing with another device")
    static let syncWithAnotherDeviceFooter = NSLocalizedString("sync.with.another.device.footer", bundle: Bundle.module, value: "Your data is end-to-end encrypted, and DuckDuckGo does not have access to the encryption key.", comment: "Footer message for syncing with another device")
    // Other Options
    static let syncAndBackUpThisDeviceLink = NSLocalizedString("sync.and.backup.this.device.link", bundle: Bundle.module, value: "Sync and Back Up This Device", comment: "Link label for syncing and backing up the device")
    static let recoverSyncedDataLink = NSLocalizedString("recover.synced.data.link", bundle: Bundle.module, value: "Recover Synced Data", comment: "Link label for recovering synced data")
    static let otherOptionsSectionHeader = NSLocalizedString("other.options.section.header", bundle: Bundle.module, value: "Other Options", comment: "Section header for other syncing options")
    // Other Platforms
    static let syncGetOnOtherDevices = NSLocalizedString("sync.get.other.devices", bundle: Bundle.module, value: "Get DuckDuckGo on Other Devices", comment: "Button to get DuckDuckGo on other devices")

    // Sync Enabled View
    // Turn Sync Off
    static let turnSyncOff = NSLocalizedString("turn.sync.off", bundle: Bundle.module, value: "Turn Off Sync & Backup...", comment: "Turn Sync Off - Button")
    static let turnSyncOffSectionHeader = NSLocalizedString("turn.sync.off.section.header", bundle: Bundle.module, value: "Sync Enabled", comment: "Turn Sync Off - Section Header")
    // Sync Filtered Items Errors
    static let invalidBookmarksPresentTitle = NSLocalizedString("bookmarks.invalid.objects.present.title", bundle: Bundle.module, value: "Some bookmarks are not syncing due to excessively long content in certain fields.", comment: "Alert title for invalid bookmarks being filtered out of synced data")
    static let invalidCredentialsPresentTitle = NSLocalizedString("credentials.invalid.objects.present.title", bundle: Bundle.module, value: "Some logins are not syncing due to excessively long content in certain fields.", comment: "Alert title for invalid logins being filtered out of synced data")
    static let bookmarksLimitExceededAction = NSLocalizedString("prefrences.sync.bookmarks-limit-exceeded-action", value: "Manage Bookmarks", comment: "Button title for sync bookmarks limits exceeded warning to go to manage bookmarks")
    static let credentialsLimitExceededAction = NSLocalizedString("prefrences.sync.credentials-limit-exceeded-action", value: "Manage passwords…", comment: "Button title for sync credentials limits exceeded warning to go to manage passwords")
    static func invalidBookmarksPresentDescription(_ invalidItemTitle: String, numberOfOtherInvalidItems: Int) -> String {
        let message = NSLocalizedString("bookmarks.invalid.objects.present.description", bundle: Bundle.module, comment: "Do not translate - stringsdict entry")
        return String(format: message, numberOfOtherInvalidItems, invalidItemTitle)
    }

    static func invalidCredentialsPresentDescription(_ invalidItemTitle: String, numberOfOtherInvalidItems: Int) -> String {
        let message = NSLocalizedString("credentials.invalid.objects.present.description", bundle: Bundle.module, comment: "Do not translate - stringsdict entry")
        return String(format: message, numberOfOtherInvalidItems, invalidItemTitle)
    }

    // Synced Devices
    static let syncedDevicesSectionHeader = NSLocalizedString("synced.devices.section.header", bundle: Bundle.module, value: "Synced Devices", comment: "Synced Devices - Section Header")
    static let syncedDevicesThisDeviceLabel = NSLocalizedString("synced.devices.this.device.label", bundle: Bundle.module, value: "This Device", comment: "Synced Devices - This Device Label")
    static let syncedDevicesSyncWithAnotherDeviceLabel = NSLocalizedString("synced.devices.sync.with.another.device.label", bundle: Bundle.module, value: "Sync With Another Device", comment: "Synced Devices - Sync with Another Device Label")
    // Options
    static let optionsSectionHeader = NSLocalizedString("options.section.header", bundle: Bundle.module, value: "Options", comment: "Options - Section Header")
    static let unifiedFavoritesTitle = NSLocalizedString("unified.favorites.title", bundle: Bundle.module, value: "Unify Favorites Across Devices", comment: "Options - Unify Favorites Title")
    static let unifiedFavoritesInstruction = NSLocalizedString("unified.favorites.instruction", bundle: Bundle.module, value: "Use the same favorite bookmarks on all your devices. Leave off to keep mobile and desktop favorites separate.", comment: "Options - Unify Favorites Instruction")
    static let fetchFaviconsOptionTitle = NSLocalizedString("fetch.favicons.option.title", bundle: Bundle.module, value: "Auto-Download Icons", comment: "Options - Fetch Favicons Title")
    static let fetchFaviconsOptionCaption = NSLocalizedString("fetch.favicons.option.caption", bundle: Bundle.module, value: "Automatically download icons for your synced bookmarks. Icon downloads are exposed to your network.", comment: "Options - Fetch Favicons Description")

    // Save RecoveryPDF
    static let saveRecoveryPDFButton = NSLocalizedString("save.recovery.pdf.button", bundle: Bundle.module, value: "Save Recovery PDF", comment: "Save RecoveryPDF - Button")
    static let saveRecoveryPDFFooter = NSLocalizedString("save.recovery.pdf.footer", bundle: Bundle.module, value: "If you lose your device, you will need this recovery code to restore your synced data.", comment: "Save RecoveryPDF - Footer")
    // Delete Server Data
    static let deleteServerData = NSLocalizedString("delete.server.data", bundle: Bundle.module, value: "Turn Off and Delete Server Data...", comment: "Delete Server Data - Button")

    // Connect With Server Sheet
    static let connectWithServerSheetTitle = NSLocalizedString("connect.with.server.sheet.title", bundle: Bundle.module, value: "Sync and Back Up This Device", comment: "Connect With Server Sheet - Title")
    static let connectWithServerSheetDescriptionPart1 = NSLocalizedString("connect.with.server.sheet.description.part1", bundle: Bundle.module, value: "This creates an encrypted backup of your bookmarks and passwords on DuckDuckGo’s secure server, which can be synced with your other devices.", comment: "Connect With Server Sheet - Description Part 1")
    static let connectWithServerSheetDescriptionPart2 = NSLocalizedString("connect.with.server.sheet.description.part2", bundle: Bundle.module, value: "The encryption key is only stored on your device, DuckDuckGo cannot access it.", comment: "Connect With Server Sheet - Description Part 2")
    static let connectWithServerSheetButton = NSLocalizedString("connect.with.server.sheet.button", bundle: Bundle.module, value: "Turn On Sync & Back Up", comment: "Connect With Server Sheet - Button")
    static let connectWithServerSheetFooter = NSLocalizedString("connect.with.server.sheet.footer", bundle: Bundle.module, value: "You can sync with your other devices later.", comment: "Connect With Server Sheet - Footer")

    // Preparing To Sync Sheet
    static let preparingToSyncSheetTitle = NSLocalizedString("preparing.to.sync.sheet.title", bundle: Bundle.module, value: "Setting Up Sync and Backup", comment: "Preparing To Sync Sheet - Title")
    static let preparingToSyncSheetDescription = NSLocalizedString("preparing.to.sync.sheet.description", bundle: Bundle.module, value: "Your bookmarks and passwords are being prepared to sync. This should only take a moment.", comment: "Preparing To Sync Sheet - Description")
    static let preparingToSyncSheetFooter = NSLocalizedString("preparing.to.sync.sheet.footer", bundle: Bundle.module, value: "Connecting…", comment: "Preparing To Sync Sheet - Footer")

    // Save Recovery Code Sheet
    static let saveRecoveryCodeSheetTitle = NSLocalizedString("save.recovery.code.sheet.title", bundle: Bundle.module, value: "Save Recovery Code", comment: "Save Recovery Code Sheet - Title")
    static let saveRecoveryCodeSheetDescription = NSLocalizedString("save.recovery.code.sheet.description", bundle: Bundle.module, value: "If you lose access to your devices, you will need this code to recover your synced data.", comment: "Save Recovery Code Sheet - Description")
    static let saveRecoveryCodeSheetFooter = NSLocalizedString("save.recovery.code.sheet.footer", bundle: Bundle.module, value: "Anyone with access to this code can access your synced data, so please keep it in a safe place.", comment: "Save Recovery Code Sheet - Footer")
    static let saveRecoveryCodeCopyCodeButton = NSLocalizedString("save.recovery.code.copy.code.button", bundle: Bundle.module, value: "Copy Code", comment: "Save Recovery Code Sheet - Copy Code Button")
    static let saveRecoveryCodeSaveAsPdfButton = NSLocalizedString("save.recovery.code.save.as.pdf.button", bundle: Bundle.module, value: "Save as PDF", comment: "Save Recovery Code Sheet - Save as PDF Button")
    static let saveRecoveryCodeSaveCodeCopiedToast = NSLocalizedString("save.recovery.code.code.copied.button", bundle: Bundle.module, value: "Recovery code copied to clipboard", comment: "Save Recovery Code Sheet - Copy Code Toast")

    // Device Synced Sheet
    static let deviceSyncedSheetTitle = NSLocalizedString("device.synced.sheet.title", bundle: Bundle.module, value: "Your data is synced!", comment: "Device SyncedSheet - Title")
    static let deviceSyncedSheetGetOnOtherDevicesButton = NSLocalizedString("device.synced.sheet.button.get.other.devices", bundle: Bundle.module, value: "Get DuckDuckGo on Other Devices", comment: "Device SyncedSheet Button to go get DuckDuckGo on other devices")

    // Recover Synced Data Sheet
    static let recoverSyncedDataTitle = NSLocalizedString("recover.synced.data.sheet.title", bundle: Bundle.module, value: "Recover Synced Data", comment: "Recover Synced Data Sheet - Title")
    static let recoverSyncedDataDescription = NSLocalizedString("recover.synced.data.sheet.description", bundle: Bundle.module, value: "To restore your synced data, you'll need the Recovery Code you saved when you first set up Sync. This code may have been saved as a PDF on the device you originally used to set up Sync.", comment: "Recover Synced Data Sheet - Description")
    static let recoverSyncedDataButton = NSLocalizedString("recover.synced.data.sheet.button", bundle: Bundle.module, value: "Get Started", comment: "Recover Synced Data Sheet - Button")

    // Scan Or Enter Code To Recover Synced Data View
    static let scanCodeToRecoverSyncedDataTitle = NSLocalizedString("scan.code.to.recover.synced.data.title", bundle: Bundle.module, value: "Recover Synced Data", comment: "Scan Or Enter Code To Recover Synced Data View - Title")
    static let scanCodeToRecoverSyncedDataExplanation = NSLocalizedString("scan.code.to.recover.synced.data.explanation", bundle: Bundle.module, value: "Scan the QR code on your Recovery PDF, or another synced device, to recover your data.", comment: "Scan Or Enter Code To Recover Synced Data View - Explanation")
    static let scanCodeToRecoverSyncedDataFooter = NSLocalizedString("scan.code.to.recover.synced.data.footer", bundle: Bundle.module, value: "Can’t Scan?", comment: "Scan Or Enter Code To Recover Synced Data View - Footer")
    static let scanCodeToRecoverSyncedDataEnterCodeLink = NSLocalizedString("scan.code.to.recover.synced.data.enter.code.link", bundle: Bundle.module, value: "Enter Text Code Manually", comment: "Scan Or Enter Code To Recover Synced Data View - Enter Code Link")

    // Camera View
    static let cameraPointCameraIndication = NSLocalizedString("camera.point.camera.indication", bundle: Bundle.module, value: "Point camera at QR code to sync", comment: "Camera View - Point Camera Indication")
    static let cameraPermissionRequired = NSLocalizedString("camera.permission.required", bundle: Bundle.module, value: "Camera Permission is Required", comment: "Camera View - Permission Required")
    static let cameraPermissionInstructions = NSLocalizedString("camera.permission.instructions", bundle: Bundle.module, value: "Please go to your device's settings and grant permission for this app to access your camera.", comment: "Camera View - Permission Instructions")
    static let cameraIsUnavailableTitle = NSLocalizedString("camera.is.unavailable.title", bundle: Bundle.module, value: "Camera is Unavailable", comment: "Camera View - Unavailable Title")
    static let cameraGoToSettingsButton = NSLocalizedString("camera.go.to.settings.button", bundle: Bundle.module, value: "Go to Settings", comment: "Camera View - Go to Settings Button")

    // Manually Enter Code View
    static let manuallyEnterCodeTitle = NSLocalizedString("manually.enter.code.title", bundle: Bundle.module, value: "Manually Enter Code", comment: "Manually Enter Code View - Title")
    static let manuallyEnterCodeValidatingCodeAction = NSLocalizedString("manually.enter.code.validating.code.action", bundle: Bundle.module, value: "Validating code", comment: "Manually Enter Code View - Validating Code Action")
    static let manuallyEnterCodeValidatingCodeFailedAction = NSLocalizedString("manually.enter.code.validating.code.failed.action", bundle: Bundle.module, value: "Invalid code.", comment: "Manually Enter Code View - Validating Code Failed Action")
    static func manuallyEnterCodeInstructionAttributed(syncMenuPath: String, menuItem: String) -> String {
        let localized = NSLocalizedString("manually.enter.code.instruction.attributed", bundle: Bundle.module, value: "Go to %@ and select %@ in the DuckDuckGo App on another synced device and paste the code here to sync this device.", comment: "Manually Enter Code View - Instruction with sync menu path and view text code menu item inserted")
        return String(format: localized, syncMenuPath, menuItem)
    }
    static let syncMenuPath = NSLocalizedString("sync.menu.path", bundle: Bundle.module, value: "Settings > Sync & Backup > Sync With Another Device", comment: "Sync Menu Path")
    static let viewTextCodeMenuItem = NSLocalizedString("view.text.code.menu.item", bundle: Bundle.module, value: "View Text Code", comment: "View Text Code menu item")

    // Scan or See Code View
    static let scanOrSeeCodeTitle = NSLocalizedString("scan.or.see.code.title", bundle: Bundle.module, value: "Scan QR Code", comment: "Scan or See Code View - Title")
    static let scanOrSeeCodeInstruction = NSLocalizedString("scan.or.see.code.instruction", bundle: Bundle.module, value: "Go to Settings › Sync & Backup in the DuckDuckGo Browser on another device and select ”Sync With Another Device.”", comment: "Scan or See Code View - Instruction")
    static func scanOrSeeCodeInstructionAttributed(syncMenuPath: String) -> String {
        let localized = NSLocalizedString("scan.or.see.code.instruction.attributed", bundle: Bundle.module, value: "Go to %@ in the DuckDuckGo Browser on another device and select ”Sync With Another Device.”.", comment: "Scan or See Code View - Instruction with syncMenuPath")
        return String(format: localized, syncMenuPath)
    }

    static let scanOrSeeCodeManuallyEnterCodeLink = NSLocalizedString("scan.or.see.code.manually.enter.code.link", bundle: Bundle.module, value: "Manually Enter Code", comment: "Scan or See Code View - Manually Enter Code Link")
    static let scanOrSeeCodeScanCodeInstructionsTitle = NSLocalizedString("scan.or.see.code.scan.code.instructions.title", bundle: Bundle.module, value: "Mobile-to-Mobile?", comment: "Scan or See Code View - Scan Code Instructions Title")
    static let scanOrSeeCodeScanCodeInstructionsBody = NSLocalizedString("scan.or.see.code.scan.code.instructions.body", bundle: Bundle.module, value: "Scan this code with another device to sync.", comment: "Scan or See Code View - Scan Code Instructions Body")
    static let scanOrSeeCodeFooter = NSLocalizedString("scan.or.see.code.footer", bundle: Bundle.module, value: "Can’t Scan?", comment: "Scan or See Code View - Footer")
    static let scanOrSeeCodeShareCodeLink = NSLocalizedString("scan.or.see.code.share.code.link", bundle: Bundle.module, value: "Share Text Code", comment: "Scan or See Code View - Share Code Link")

    // Edit Device View
    static let editDeviceHeader = NSLocalizedString("edit.device.header", bundle: Bundle.module, value: "Device Name", comment: "Edit Device View - Header")
    static func editDeviceTitle(_ name: String) -> String {
        let localized = NSLocalizedString("edit.device.title", bundle: Bundle.module, value: "Edit %@", comment: "Edit Device View - Title")
        return String(format: localized, name)
    }

    // Remove Device View
    static let removeDeviceTitle = NSLocalizedString("remove.device.title", bundle: Bundle.module, value: "Remove Device?", comment: "Remove Device View - Title")
    static let removeDeviceButton = NSLocalizedString("remove.device.button", bundle: Bundle.module, value: "Remove Device", comment: "Remove Device View - Button")
    static func removeDeviceMessage(_ name: String) -> String {
        let localized = NSLocalizedString("remove.device.message", bundle: Bundle.module, value: "\"%@\" will no longer be able to access your synced data.", comment: "Remove Device View - Message")
        return String(format: localized, name)
    }

    // Standard Buttons
    static let cancelButton = NSLocalizedString("cancel.button", bundle: Bundle.module, value: "Cancel", comment: "Standard Buttons - Cancel Button")
    static let doneButton = NSLocalizedString("done.button", bundle: Bundle.module, value: "Done", comment: "Standard Buttons - Done Button")
    static let nextButton = NSLocalizedString("next.button", bundle: Bundle.module, value: "Next", comment: "Standard Buttons - Next Button")
    static let backButton = NSLocalizedString("back.button", bundle: Bundle.module, value: "Back", comment: "Standard Buttons - Back Button")
    static let pasteButton = NSLocalizedString("paste.button", bundle: Bundle.module, value: "Paste", comment: "Standard Buttons - Paste Button")
    static let notNowButton = NSLocalizedString("not.now.button", bundle: Bundle.module, value: "Not Now", comment: "Standard Buttons - Not Now Button")
    static let copyButton = NSLocalizedString("copy.button", bundle: Bundle.module, value: "Copy", comment: "Standard Buttons - Copy Button")

    // Fetch favicons
    static let fetchFaviconsOnboardingTitle = NSLocalizedString("fetch.favicons.onboarding.title", bundle: Bundle.module, value: "Download Missing Icons?", comment: "Fetch Favicons Onboarding - Title")
    static let fetchFaviconsOnboardingMessage = NSLocalizedString("fetch.favicons.onboarding.message", bundle: Bundle.module, value: "Do you want this device to automatically download icons for any new bookmarks synced from your other devices? This will expose the download to your network any time a bookmark is synced.", comment: "Fetch Favicons Onboarding - Message")
    static let fetchFaviconsOnboardingButtonTitle = NSLocalizedString("fetch.favicons.onboarding.button.title", bundle: Bundle.module, value: "Keep Bookmarks Icons Updated", comment: "Fetch Favicons Onboarding - Button Title")

    // Sync Feature Flags
    static let syncUnavailableTitle = NSLocalizedString("sync.warning.sync.unavailable", bundle: Bundle.module, value: "Sync & Backup is Unavailable", comment: "Title of the warning message")
    static let syncUnavailableMessage = NSLocalizedString("sync.warning.data.syncing.disabled", bundle: Bundle.module, value: "Sorry, but Sync & Backup is currently unavailable. Please try again later.", comment: "Data syncing unavailable warning message")
    static let syncUnavailableMessageUpgradeRequired = NSLocalizedString("sync.warning.data.syncing.disabled.upgrade.required", bundle: Bundle.module, value: "Sorry, but Sync & Backup is no longer available in this app version. Please update DuckDuckGo to the latest version to continue.", comment: "Data syncing unavailable warning message")

    // Sync Get Other Devices
    static let syncGetOtherDevicesScreenTitle = NSLocalizedString("sync.get.other.devices.screen.title", bundle: Bundle.module, value: "Get DuckDuckGo", comment: "Title of screen with share links for users to download DuckDuckGo on other devices")
    static let syncGetOtherDevicesTitle = NSLocalizedString("sync.get.other.devices.card.title", bundle: Bundle.module, value: "Get DuckDuckGo on other devices to sync with this one", comment: "Title of card with share links for users to download DuckDuckGo on other devices")
    static let syncGetOtherDevicesMessage = NSLocalizedString("sync.get.other.devices.card.message", bundle: Bundle.module, value: "To download DuckDuckGo on desktop or another mobile device, visit:", comment: "Message before share link for downloading DuckDuckGo on other devices")
    static let syncGetOtherDevicesButtonTitle = NSLocalizedString("sync.get.other.devices.card.button.title", bundle: Bundle.module, value: "Share Download Link", comment: "Button title to share link for downloading DuckDuckGo on other devices")
    static let syncGetOtherDeviceShareLinkMessage = NSLocalizedString("sync.get.other.devices.share.link.message", bundle: Bundle.module, value: "Install the DuckDuckGo browser on your devices to start securely syncing your bookmarks and passwords:", comment: "Message included when sharing a url via the system share sheet")

}
