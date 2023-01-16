//
//  SyncManagementViewModel.swift
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

protocol SyncManagementViewModelDelegate: AnyObject {

    func showSyncSetup()
    func showRecoverData()
    func showSyncWithAnotherDevice()

}

class SyncManagementViewModel: ObservableObject {

    struct Device: Identifiable, Hashable {

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        let id: String
        let name: String
        let isThisDevice: Bool

    }

    @Published var isSyncEnabled = false
    @Published var isBusy = false
    @Published var devices = [Device]()

    weak var delegate: SyncManagementViewModelDelegate?

    func enableSync() {
        print(#function)
        isBusy = true
        delegate?.showSyncSetup()
    }

    func disableSync() {
        print(#function)
    }

    func setupFinished(_ model: SyncSetupViewModel) {
        isBusy = false

        switch model.state {
        case .showRecoverData:
            delegate?.showRecoverData()

        case .showSyncWithAnotherDevice:
            delegate?.showSyncWithAnotherDevice()

        case .syncWithAnotherDevicePrompt:
            // Create an account and start syncing
            createAccount()

        default: break
        }
    }

    func createAccount() {
        print(#function)
        devices = [
            Device(id: UUID().uuidString, name: UIDevice.current.name, isThisDevice: true)
        ]
        Task { @MainActor in
            try await Task.sleep(nanoseconds: 1_000_000_000 * 2)
            isBusy = false
            isSyncEnabled = true
        }
    }

}
