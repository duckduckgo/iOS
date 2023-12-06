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

public protocol SyncManagementViewModelDelegate: AnyObject {

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
}

public class SyncSettingsViewModel: ObservableObject {

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
    @Published public var isSyncBookmarksPaused = false
    @Published public var isSyncCredentialsPaused = false

    @Published var isBusy = false
    @Published var recoveryCode = ""

    public weak var delegate: SyncManagementViewModelDelegate?

    public init() { }

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
        delegate?.shareRecoveryPDF()
    }

    func scanQRCode() {
        delegate?.showSyncWithAnotherDevice()
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

    public func recoverSyncDataPressed() {
        delegate?.showRecoverData()
    }
}
