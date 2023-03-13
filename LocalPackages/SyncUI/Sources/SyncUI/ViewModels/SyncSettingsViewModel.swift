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

    func showSyncSetup()
    func showRecoverData()
    func showSyncWithAnotherDevice()
    func showDeviceConnected()
    func showRecoveryPDF()
    func createAccountAndStartSyncing()
    func confirmDisableSync() async -> Bool
    func confirmDeleteAllData() async -> Bool
    func copyCode()

}

public class SyncSettingsViewModel: ObservableObject {

    public struct Device: Identifiable, Hashable {

        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        public let id: String
        let name: String
        let type: String
        let isThisDevice: Bool

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

    @Published var isSyncEnabled = false
    @Published var isBusy = false
    @Published var devices = [Device]()
    @Published var recoveryCode = ""

    var setupFinishedState: TurnOnSyncViewModel.Result?

    public weak var delegate: SyncManagementViewModelDelegate?

    public init() { }

    func enableSync() {
        isBusy = true
        delegate!.showSyncSetup()
    }

    func disableSync() {
        isBusy = true
        Task { @MainActor in
            if await delegate!.confirmDisableSync() {
                isSyncEnabled = false
            }
            isBusy = false
        }
    }

    func deleteAllData() {
        isBusy = true
        Task { @MainActor in
            if await delegate!.confirmDeleteAllData() {
                isSyncEnabled = false
            }
            isBusy = false
        }
    }

    func copyCode() {
        delegate?.copyCode()
    }

    func saveRecoveryPDF() {
        delegate?.showRecoveryPDF()
    }

    func scanQRCode() {
        delegate?.showSyncWithAnotherDevice()
    }

    // MARK: Called by the view controller

    public func syncEnabled(recoveryCode: String) {
        isBusy = false
        isSyncEnabled = true
        self.recoveryCode = recoveryCode
        devices = [
            Device(id: UUID().uuidString, name: UIDevice.current.name, type: "phone", isThisDevice: true)
        ]
    }

    public func appendDevice(_ device: Device) {
        devices.append(device)
        objectWillChange.send()
    }

    public func setupFinished(_ model: TurnOnSyncViewModel) {
        setupFinishedState = model.state
        switch model.state {
        case .turnOn:
            delegate?.createAccountAndStartSyncing()

        case .syncWithAnotherDevice:
            delegate?.showSyncWithAnotherDevice()

        case .recoverData:
            delegate?.showRecoverData()

        default:
            isBusy = false
        }
    }

    public func codeCollectionCancelled() {
        if setupFinishedState == .syncWithAnotherDevice {
            delegate?.createAccountAndStartSyncing()
        } else {
            isBusy = false
            isSyncEnabled = false
        }
    }

}
