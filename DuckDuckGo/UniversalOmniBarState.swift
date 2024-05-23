//
//  UniversalOmniBarState.swift
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

import Foundation
import Core

enum UniversalOmniBarState {
    struct EditingSuspendedState: OmniBarState {
        let baseState: OmniBarState

        var hasLargeWidth: Bool { baseState.hasLargeWidth }
        var showBackButton: Bool { baseState.showBackButton }
        var showForwardButton: Bool { baseState.showForwardButton }
        var showBookmarksButton: Bool { baseState.showBookmarksButton }
        var showShareButton: Bool { baseState.showShareButton }
        var clearTextOnStart: Bool { baseState.clearTextOnStart }
        var allowsTrackersAnimation: Bool { baseState.allowsTrackersAnimation }
        var showSearchLoupe: Bool { baseState.showSearchLoupe }
        var showCancel: Bool { true }
        var showPrivacyIcon: Bool { baseState.showPrivacyIcon }
        var showBackground: Bool { baseState.showBackground }
        var showClear: Bool { false }
        var showRefresh: Bool { baseState.showRefresh }
        var showMenu: Bool { baseState.showMenu }
        var showSettings: Bool { baseState.showSettings }
        var showVoiceSearch: Bool { baseState.showVoiceSearch }
        var name: String { Type.name(self) }
        var onEditingStoppedState: OmniBarState { baseState.onEditingStoppedState }
        var onEditingStartedState: OmniBarState { baseState.onEditingStartedState }
        var onTextClearedState: OmniBarState { baseState.onTextClearedState }
        var onTextEnteredState: OmniBarState { baseState.onTextEnteredState }
        var onBrowsingStartedState: OmniBarState { baseState.onBrowsingStartedState }
        var onBrowsingStoppedState: OmniBarState { baseState.onBrowsingStoppedState }
        var onEnterPhoneState: OmniBarState { baseState.onEnterPhoneState }
        var onEnterPadState: OmniBarState { baseState.onEnterPadState }
        var onReloadState: OmniBarState { baseState.onReloadState }
    }
}
