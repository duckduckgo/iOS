//
//  SyncSettingsScreenViewModel.swift
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

}

public class SyncSettingsScreenViewModel: ObservableObject {

    public struct Device: Identifiable, Hashable {

        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        public let id: String
        let name: String
        let isThisDevice: Bool

        public init(id: String, name: String, isThisDevice: Bool) {
            self.id = id
            self.name = name
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

    public weak var delegate: SyncManagementViewModelDelegate?

    public init() { }

    public func showDevices() {
        isBusy = false
        isSyncEnabled = true
        devices = [
            Device(id: UUID().uuidString, name: UIDevice.current.name, isThisDevice: true)
        ]
    }

    public func appendDevice(_ device: Device) {
        devices.append(device)
    }

    func enableSync() {
        isBusy = true
        delegate!.showSyncSetup()
    }

    func disableSync() {
        isSyncEnabled = false
    }

    public func setupFinished(_ model: TurnOnSyncViewModel) {
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
        isBusy = false
        isSyncEnabled = false
    }

}
