//
//  DeviceOrientationEnvironmentValue.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

extension EnvironmentValues {
    var isLandscapeOrientation: Bool {
        self[DeviceOrientationHolderKey.self].deviceOrientation.isLandscape
    }

    var deviceOrientation: UIDeviceOrientation {
        self[DeviceOrientationHolderKey.self].deviceOrientation
    }
}

private struct DeviceOrientationHolderKey: EnvironmentKey {
    static let defaultValue = DeviceOrientationHolder()
}

private final class DeviceOrientationHolder: ObservableObject {
    @Published private(set) var deviceOrientation = UIDevice.current.orientation

    private var observable: NSObjectProtocol?

    init() {
        observable = NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                self?.deviceOrientation = UIDevice.current.orientation
        }
    }
}
