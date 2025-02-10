//
//  OmniBarState.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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
import Core
import BrowserServicesKit

protocol OmniBarState: CustomStringConvertible {

    var name: String { get }

    var hasLargeWidth: Bool { get }
    var showBackButton: Bool { get }
    var showForwardButton: Bool { get }
    var showBookmarksButton: Bool { get }
    var showAccessoryButton: Bool { get }

    var clearTextOnStart: Bool { get }
    var allowsTrackersAnimation: Bool { get }
    var showSearchLoupe: Bool { get }
    var showCancel: Bool { get } // Cancel button outside the address bar
    var showPrivacyIcon: Bool { get }
    var showBackground: Bool { get }
    var showClear: Bool { get }
    var showRefresh: Bool { get }
    var showMenu: Bool { get }
    var showSettings: Bool { get }
    var showVoiceSearch: Bool { get }
    var showAbort: Bool { get }
    var showDismiss: Bool { get } // < button inside the address bar

    var onEditingStoppedState: OmniBarState { get }
    var onEditingSuspendedState: OmniBarState { get }
    var onEditingStartedState: OmniBarState { get }
    var onTextClearedState: OmniBarState { get }
    var onTextEnteredState: OmniBarState { get }
    var onBrowsingStartedState: OmniBarState { get }
    var onBrowsingStoppedState: OmniBarState { get }
    var onEnterPhoneState: OmniBarState { get }
    var onEnterPadState: OmniBarState { get }
    var onReloadState: OmniBarState { get }

    var dependencies: OmnibarDependencyProvider { get }
    var isLoading: Bool { get }

    func withLoading() -> Self
    func withoutLoading() -> Self

    func requiresUpdate(transitioningInto other: OmniBarState) -> Bool
    func isDifferentState(than other: OmniBarState) -> Bool
}

extension OmniBarState {
    /// Returns if new state requires UI update
    func requiresUpdate(transitioningInto other: OmniBarState) -> Bool {
        name != other.name || isLoading != other.isLoading
    }

    /// Checks whether the state type is different.
    /// If `true` it may require transitioning to a different appearance and/or cancelling pending animations.
    func isDifferentState(than other: OmniBarState) -> Bool {
        name != other.name
    }

    var description: String {
        "\(name)\(isLoading ? " (loading)" : "")"
    }

    var onEditingSuspendedState: OmniBarState {
        UniversalOmniBarState.EditingSuspendedState(baseState: onEditingStartedState,
                                                    dependencies: dependencies,
                                                    isLoading: isLoading)
    }
}

protocol OmniBarLoadingBearerStateCreating {
    init(dependencies: OmnibarDependencyProvider, isLoading: Bool)
}

extension OmniBarLoadingBearerStateCreating where Self: OmniBarState {
    func withLoading() -> Self {
        Self.init(dependencies: dependencies, isLoading: true)
    }

    func withoutLoading() -> Self {
        Self.init(dependencies: dependencies, isLoading: false)
    }
}
