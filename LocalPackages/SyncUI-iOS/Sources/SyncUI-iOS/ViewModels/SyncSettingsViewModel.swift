//
//  SyncSettingsViewModel.swift
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
import UIKit
import Combine

public protocol SyncManagementViewModelDelegate: AnyObject {

    func authenticateUser() async throws
    func showRecoverData()
    func showSyncWithAnotherDevice()
    func showRecoveryPDF()
    func shareRecoveryPDF()
    func createAccountAndStartSyncing(optionsViewModel: SyncSettingsViewModel)
    func confirmAndDisableSync() async -> Bool
    func confirmAndDeleteAllData() async -> Bool
    func copyCode()
    func confirmRemoveDevice(_ device: SyncSettingsViewModel.Device) async -> Bool
    func removeDevice(_ device: SyncSettingsViewModel.Device)
    func updateDeviceName(_ name: String)
    func refreshDevices(clearDevices: Bool)
    func updateOptions()
    func launchBookmarksViewController()
    func launchAutofillViewController()
    func showOtherPlatformLinks()
    func fireOtherPlatformLinksPixel(event: SyncSettingsViewModel.PlatformLinksPixelEvent, with source: SyncSettingsViewModel.PlatformLinksPixelSource)
    func shareLink(for url: URL, with message: String, from rect: CGRect)

    var syncBookmarksPausedTitle: String? { get }
    var syncCredentialsPausedTitle: String? { get }
    var syncPausedTitle: String? { get }
    var syncBookmarksPausedDescription: String? { get }
    var syncCredentialsPausedDescription: String? { get }
    var syncPausedDescription: String? { get }
    var syncBookmarksPausedButtonTitle: String? { get }
    var syncCredentialsPausedButtonTitle: String? { get }
}

public class SyncSettingsViewModel: ObservableObject {

    public enum UserAuthenticationError: Error {
        case authFailed
        case authUnavailable
    }

    public struct Device: Identifiable, Hashable {

        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        public let id: String
        public let name: String
        public let type: String
        public let isThisDevice: Bool

        public init(id: String, name: String, type: String, isThisDevice: Bool) {
            self.id = id
            self.name = name
            self.type = type
            self.isThisDevice = isThisDevice
        }

    }

    enum ScannedCodeValidity {
        case invalid
        case valid
    }

    public enum PlatformLinksPixelEvent {
        case appear
        case copy
        case share
    }

    public enum PlatformLinksPixelSource: String {
        case notActivated = "not_activated"
        case activating
        case activated
    }

    @Published public var isSyncEnabled = false {
        didSet {
            if !isSyncEnabled {
                devices = []
            }
        }
    }

    @Published public var devices = [Device]()
    @Published public var isFaviconsFetchingEnabled = false
    @Published public var isUnifiedFavoritesEnabled = true
    @Published public var isSyncingDevices = false
    @Published public var isSyncPaused = false
    @Published public var isSyncBookmarksPaused = false
    @Published public var isSyncCredentialsPaused = false
    @Published public var invalidBookmarksTitles: [String] = []
    @Published public var invalidCredentialsTitles: [String] = []

    @Published var isBusy = false
    @Published var recoveryCode = ""

    @Published public var isDataSyncingAvailable: Bool = true
    @Published public var isConnectingDevicesAvailable: Bool = true
    @Published public var isAccountCreationAvailable: Bool = true
    @Published public var isAccountRecoveryAvailable: Bool = true
    @Published public var isAppVersionNotSupported: Bool = false

    @Published var shouldShowPasscodeRequiredAlert: Bool = false

    public weak var delegate: SyncManagementViewModelDelegate?
    private(set) var isOnDevEnvironment: Bool
    private(set) var switchToProdEnvironment: () -> Void = {}
    private var cancellables = Set<AnyCancellable>()

    public init(
        isOnDevEnvironment: @escaping () -> Bool,
        switchToProdEnvironment: @escaping () -> Void) {
            self.isOnDevEnvironment = isOnDevEnvironment()
            self.switchToProdEnvironment = { [weak self] in
                switchToProdEnvironment()
                self?.isOnDevEnvironment = isOnDevEnvironment()
            }
        }

    @MainActor
    func commonAuthenticate() async -> Bool {
        do {
            try await delegate?.authenticateUser()
            return true
        } catch {
            if let error = error as? SyncSettingsViewModel.UserAuthenticationError {
                switch error {
                case .authFailed:
                    break
                case .authUnavailable:
                    shouldShowPasscodeRequiredAlert = true
                }
            }
            return false
        }
    }

    func disableSync() {
        isBusy = true
        Task { @MainActor in
            if await delegate!.confirmAndDisableSync() {
                isSyncEnabled = false
            }
            isBusy = false
        }
    }

    func deleteAllData() {
        isBusy = true
        Task { @MainActor in
            if await delegate!.confirmAndDeleteAllData() {
                isSyncEnabled = false
            }
            isBusy = false
        }
    }

    func copyCode() {
        delegate?.copyCode()
    }

    func saveRecoveryPDF() {
        Task { @MainActor in
            if await commonAuthenticate() {
                delegate?.shareRecoveryPDF()
            }
        }
    }

    func scanQRCode() {
        Task { @MainActor in
            if await commonAuthenticate() {
                delegate?.showSyncWithAnotherDevice()
            }
        }
    }

    func syncAndBackupThisDevice() {
        Task { @MainActor in
            if await commonAuthenticate() {
                delegate?.showSyncWithAnotherDevice()
            }
        }
    }

    func recoverSyncedData() {
        Task { @MainActor in
            if await commonAuthenticate() {
                delegate?.showSyncWithAnotherDevice()
            }
        }
    }

    func createEditDeviceModel(_ device: Device) -> EditDeviceViewModel {
        return EditDeviceViewModel(device: device) { [weak self] newValue in
            self?.delegate?.updateDeviceName(newValue.name)
        }
    }

    func createRemoveDeviceModel(_ device: Device) -> RemoveDeviceViewModel {
        return RemoveDeviceViewModel(device: device) { [weak self] device in
            self?.delegate?.removeDevice(device)
        }
    }

    public func syncEnabled(recoveryCode: String) {
        isBusy = false
        isSyncEnabled = true
        self.recoveryCode = recoveryCode
    }

    public func startSyncPressed() {
        isBusy = true
        delegate?.createAccountAndStartSyncing(optionsViewModel: self)
    }

    public func manageBookmarks() {
        delegate?.launchBookmarksViewController()
    }

    public func manageLogins() {
        delegate?.launchAutofillViewController()
    }

    public func shareLinkPressed(for url: URL, with message: String, from rect: CGRect) {
        delegate?.shareLink(for: url, with: message, from: rect)
    }

    public func showOtherPlatformsPressed() {
        delegate?.showOtherPlatformLinks()
    }

    public func fireOtherPlatformLinksPixel(for event: PlatformLinksPixelEvent, source: PlatformLinksPixelSource) {
        delegate?.fireOtherPlatformLinksPixel(event: event, with: source)
    }

    public func recoverSyncDataPressed() {
        Task { @MainActor in
            if await commonAuthenticate() {
                delegate?.showRecoverData()
            }
        }
    }

    public var syncBookmarksPausedTitle: String? {
        return delegate?.syncBookmarksPausedTitle
    }
    public var syncCredentialsPausedTitle: String? {
        delegate?.syncCredentialsPausedTitle
    }
    public var syncPausedTitle: String? {
        delegate?.syncPausedTitle
    }
    public var syncBookmarksPausedDescription: String? {
        delegate?.syncBookmarksPausedDescription
    }
    public var syncCredentialsPausedDescription: String? {
        delegate?.syncCredentialsPausedDescription
    }
    public var syncPausedDescription: String? {
        delegate?.syncPausedDescription
    }
    public var syncBookmarksPausedButtonTitle: String? {
        delegate?.syncBookmarksPausedButtonTitle
    }
    public var syncCredentialsPausedButtonTitle: String? {
        delegate?.syncCredentialsPausedButtonTitle
    }

}
