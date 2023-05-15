//
//  SyncSettingsViewController.swift
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

import SwiftUI
import Combine
import SyncUI
import DDGSync

@MainActor
class SyncSettingsViewController: UIHostingController<SyncSettingsView> {

    lazy var authenticator = Authenticator()

    let syncService: DDGSyncing! = (UIApplication.shared.delegate as? AppDelegate)!.syncService
    var connector: RemoteConnecting?

    var recoveryCode: String {
        guard let code = syncService.account?.recoveryCode else {
            assertionFailure("No recovery code")
            return ""
        }

        return code
    }

    var deviceName: String {
        UIDevice.current.name
    }

    var deviceType: String {
        isPad ? "tablet" : "phone"
    }

    var cancellables = Set<AnyCancellable>()

    convenience init() {
        self.init(rootView: SyncSettingsView(model: SyncSettingsViewModel()))

        // For some reason, on iOS 14, the viewDidLoad wasn't getting called so do some setup here
        if syncService.isAuthenticated {
            rootView.model.syncEnabled(recoveryCode: recoveryCode)
            refreshDevices()
        }

        syncService.isAuthenticatedPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.rootView.model.isSyncEnabled = self!.syncService.isAuthenticated
            }
            .store(in: &cancellables)

        rootView.model.delegate = self
        navigationItem.title = "Sync" // TODO externalise
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme(ThemeManager.shared.currentTheme)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        connector = nil
    }

    func dismissPresentedViewController() {
        navigationController?.topViewController?.dismiss(animated: true)
    }

    func refreshDevices(clearDevices: Bool = true) {
        guard syncService.isAuthenticated else { return }

        Task { @MainActor in
            if clearDevices {
                rootView.model.devices = []
            }

            do {
                let devices = try await syncService.fetchDevices()
                mapDevices(devices)
            } catch {
                handleError(error)
            }
        }
    }

    func mapDevices(_ devices: [RegisteredDevice]) {
        rootView.model.devices = devices.map {
            .init(id: $0.id, name: $0.name, type: $0.type, isThisDevice: $0.id == syncService.account?.deviceId)
        }.sorted(by: { lhs, _ in
            lhs.isThisDevice
        })
    }

}

extension SyncSettingsViewController: ScanOrPasteCodeViewModelDelegate {

    var pasteboardString: String? {
        UIPasteboard.general.string
    }

    func endConnectMode() {
        connector?.stopPolling()
        connector = nil
    }

    func startConnectMode() async -> String? {
        // Handle local authentication later
        do {
            self.connector = try syncService.remoteConnect()
            self.startPolling()
            return self.connector?.code
        } catch {
            self.handleError(error)
            return nil
        }
    }

    func startPolling() {
        Task { @MainActor in
            do {
                if let recoveryKey = try await connector?.pollForRecoveryKey() {
                        try await syncService.login(recoveryKey, deviceName: deviceName, deviceType: deviceType)
                } else {
                    // Likely cancelled elsewhere
                    return
                }
                dismissPresentedViewController()
                showDeviceConnected()
            } catch {
                handleError(error)
            }
        }
    }

    func syncCodeEntered(code: String) async -> Bool {
        do {
            guard let syncCode = try? SyncCode.decodeBase64String(code) else {
                return false
            }

            if let recoveryKey = syncCode.recovery {
                try await syncService.login(recoveryKey, deviceName: deviceName, deviceType: deviceType)
                dismissPresentedViewController()
                showDeviceConnected()
                return true
            } else if let connectKey = syncCode.connect {
                if syncService.account == nil {
                    try await syncService.createAccount(deviceName: deviceName, deviceType: deviceType)
                    rootView.model.syncEnabled(recoveryCode: recoveryCode)
                }
                try await syncService.transmitRecoveryKey(connectKey)
                dismissPresentedViewController()
                return true
            }

        } catch {
            handleError(error)
        }
        return false
    }

    func codeCollectionCancelled() {
        assert(navigationController?.visibleViewController is UIHostingController<ScanOrPasteCodeView>)
        dismissPresentedViewController()
        rootView.model.codeCollectionCancelled()
    }

    func gotoSettings() {
        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
        }
    }

}
