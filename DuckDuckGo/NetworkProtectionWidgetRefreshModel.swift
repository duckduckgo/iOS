//
//  NetworkProtectionWidgetRefreshModel.swift
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

#if NETWORK_PROTECTION

import Foundation
import Combine
import NetworkExtension
import WidgetKit

class NetworkProtectionWidgetRefreshModel {

    private var cancellable: AnyCancellable?

    public func beginObservingVPNStatus() {
        cancellable = NotificationCenter.default.publisher(for: .NEVPNStatusDidChange)
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshVPNWidget()
            }
    }

    public func refreshVPNWidget() {
        WidgetCenter.shared.reloadTimelines(ofKind: "VPNStatusWidget")
    }

}

#endif
