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
    func confirmAndDisableSync() async -> Bool
    func confirmAndDeleteAllData() async -> Bool
    func copyCode()
    func confirmRemoveDevice(_ device: SyncSettingsViewModel.Device) async -> Bool

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

    @Published public var isSyncEnabled = false
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
        delegate?.showRecoveryPDF()
    }

    func scanQRCode() {
        delegate?.showSyncWithAnotherDevice()
    }

    func createEditDeviceModel(_ device: Device) -> EditDeviceViewModel {
        return EditDeviceViewModel(device: device) { newValue in

            self.devices = self.devices.map {
                if $0.id == newValue.id {
                    return newValue
                }
                return $0
            }

        } remove: { @MainActor in
            if await self.delegate?.confirmRemoveDevice(device) == true {
                self.devices = self.devices.filter { $0.id != device.id }
                return true
            }
            return false
        }
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
        }
    }

}
