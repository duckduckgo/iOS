//
//  LargeOmniBarState.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

struct LargeOmniBarState {
    
    struct HomeEmptyEditingState: OmniBarState {
        let hasLargeWidth: Bool = true
        let showBackButton: Bool = true
        let showForwardButton: Bool = true
        let showBookmarksButton: Bool = true
        let showShareButton: Bool = false
        let clearTextOnStart = true
        let allowsTrackersAnimation = false
        let showSearchLoupe = !AppDependencyProvider.shared.voiceSearchHelper.isVoiceSearchEnabled
        let showPrivacyIcon = false
        let showBackground = false
        let showClear = false
        let showRefresh = false
        let showMenu = false
        let showSettings = true
        let showCancel: Bool = false
        let showVoiceSearch = AppDependencyProvider.shared.voiceSearchHelper.isVoiceSearchEnabled
        var name: String { return "Pad" + Type.name(self) }
        var onEditingStoppedState: OmniBarState { return HomeNonEditingState() }
        var onEditingStartedState: OmniBarState { return self }
        var onTextClearedState: OmniBarState { return self }
        var onTextEnteredState: OmniBarState { return HomeTextEditingState() }
        var onBrowsingStartedState: OmniBarState { return BrowsingNonEditingState() }
        var onBrowsingStoppedState: OmniBarState { return self }
        var onEnterPadState: OmniBarState { return self }
        var onEnterPhoneState: OmniBarState { return SmallOmniBarState.HomeEmptyEditingState() }
        var onReloadState: OmniBarState { return BrowsingNonEditingState() }
    }

    struct HomeTextEditingState: OmniBarState {
        let hasLargeWidth: Bool = true
        let showBackButton: Bool = true
        let showForwardButton: Bool = true
        let showBookmarksButton: Bool = true
        let showShareButton: Bool = false
        let clearTextOnStart = false
        let allowsTrackersAnimation = false
        let showSearchLoupe = !AppDependencyProvider.shared.voiceSearchHelper.isVoiceSearchEnabled
        let showPrivacyIcon = false
        let showBackground = false
        let showClear = true
        let showRefresh = false
        let showMenu = false
        let showSettings = true
        let showCancel: Bool = false
        let showVoiceSearch = AppDependencyProvider.shared.voiceSearchHelper.isVoiceSearchEnabled
        var name: String { return "Pad" + Type.name(self) }
        var onEditingStoppedState: OmniBarState { return HomeNonEditingState() }
        var onEditingStartedState: OmniBarState { return self }
        var onTextClearedState: OmniBarState { return HomeEmptyEditingState() }
        var onTextEnteredState: OmniBarState { return self }
        var onBrowsingStartedState: OmniBarState { return BrowsingNonEditingState() }
        var onBrowsingStoppedState: OmniBarState { return HomeEmptyEditingState() }
        var onEnterPadState: OmniBarState { return self }
        var onEnterPhoneState: OmniBarState { return SmallOmniBarState.HomeTextEditingState() }
        var onReloadState: OmniBarState { return HomeTextEditingState() }
    }

    struct HomeNonEditingState: OmniBarState {
        let hasLargeWidth: Bool = true
        let showBackButton: Bool = true
        let showForwardButton: Bool = true
        let showBookmarksButton: Bool = true
        let showShareButton: Bool = false
        let clearTextOnStart = true
        let allowsTrackersAnimation = false
        let showSearchLoupe = true
        let showPrivacyIcon = false
        let showBackground = true
        let showClear = false
        let showRefresh = false
        let showMenu = false
        let showSettings = true
        let showCancel: Bool = false
        let showVoiceSearch = AppDependencyProvider.shared.voiceSearchHelper.isVoiceSearchEnabled
        var name: String { return "Pad" + Type.name(self) }
        var onEditingStoppedState: OmniBarState { return self }
        var onEditingStartedState: OmniBarState { return HomeEmptyEditingState() }
        var onTextClearedState: OmniBarState { return HomeEmptyEditingState() }
        var onTextEnteredState: OmniBarState { return HomeTextEditingState() }
        var onBrowsingStartedState: OmniBarState { return BrowsingNonEditingState() }
        var onBrowsingStoppedState: OmniBarState { return HomeNonEditingState() }
        var onEnterPadState: OmniBarState { return self }
        var onEnterPhoneState: OmniBarState { return SmallOmniBarState.HomeNonEditingState() }
        var onReloadState: OmniBarState { return HomeNonEditingState() }
    }

    struct BrowsingEmptyEditingState: OmniBarState {
        let hasLargeWidth: Bool = true
        let showBackButton: Bool = true
        let showForwardButton: Bool = true
        let showBookmarksButton: Bool = true
        let showShareButton: Bool = true
        let clearTextOnStart = true
        let allowsTrackersAnimation = false
        let showSearchLoupe = !AppDependencyProvider.shared.voiceSearchHelper.isVoiceSearchEnabled
        let showPrivacyIcon = false
        let showBackground = false
        let showClear = false
        let showRefresh = false
        let showMenu = true
        let showSettings = false
        let showCancel: Bool = false
        let showVoiceSearch = AppDependencyProvider.shared.voiceSearchHelper.isVoiceSearchEnabled
        var name: String { return "Pad" + Type.name(self) }
        var onEditingStoppedState: OmniBarState { return BrowsingNonEditingState() }
        var onEditingStartedState: OmniBarState { return self }
        var onTextClearedState: OmniBarState { return self }
        var onTextEnteredState: OmniBarState { return BrowsingTextEditingState() }
        var onBrowsingStartedState: OmniBarState { return self }
        var onBrowsingStoppedState: OmniBarState { return HomeEmptyEditingState() }
        var onEnterPadState: OmniBarState { return self }
        var onEnterPhoneState: OmniBarState { return SmallOmniBarState.BrowsingEmptyEditingState() }
        var onReloadState: OmniBarState { return BrowsingEmptyEditingState() }
    }

    struct BrowsingTextEditingState: OmniBarState {
        let hasLargeWidth: Bool = true
        let showBackButton: Bool = true
        let showForwardButton: Bool = true
        let showBookmarksButton: Bool = true
        let showShareButton: Bool = true
        let clearTextOnStart = false
        let allowsTrackersAnimation = false
        let showSearchLoupe = !AppDependencyProvider.shared.voiceSearchHelper.isVoiceSearchEnabled
        let showPrivacyIcon = false
        let showBackground = false
        let showClear = true
        let showRefresh = false
        let showMenu = true
        let showSettings = false
        let showCancel: Bool = false
        let showVoiceSearch = AppDependencyProvider.shared.voiceSearchHelper.isVoiceSearchEnabled
        var name: String { return "Pad" + Type.name(self) }
        var onEditingStoppedState: OmniBarState { return BrowsingNonEditingState() }
        var onEditingStartedState: OmniBarState { return self }
        var onTextClearedState: OmniBarState { return BrowsingEmptyEditingState() }
        var onTextEnteredState: OmniBarState { return self }
        var onBrowsingStartedState: OmniBarState { return self }
        var onBrowsingStoppedState: OmniBarState { return HomeEmptyEditingState() }
        var onEnterPadState: OmniBarState { return self }
        var onEnterPhoneState: OmniBarState { return SmallOmniBarState.BrowsingTextEditingState() }
        var onReloadState: OmniBarState { return BrowsingTextEditingState() }
    }

    struct BrowsingNonEditingState: OmniBarState {
        let hasLargeWidth: Bool = true
        let showBackButton: Bool = true
        let showForwardButton: Bool = true
        let showBookmarksButton: Bool = true
        let showShareButton: Bool = true
        let clearTextOnStart = false
        let allowsTrackersAnimation = true
        let showSearchLoupe = false
        let showPrivacyIcon = true
        let showBackground = true
        let showClear = false
        let showRefresh = true
        let showMenu = true
        let showSettings = false
        let showCancel: Bool = false
        let showVoiceSearch = false
        var name: String { return "Pad" + Type.name(self) }
        var onEditingStoppedState: OmniBarState { return self }
        var onEditingStartedState: OmniBarState { return BrowsingTextEditingState() }
        var onTextClearedState: OmniBarState { return BrowsingEmptyEditingState() }
        var onTextEnteredState: OmniBarState { return BrowsingTextEditingState() }
        var onBrowsingStartedState: OmniBarState { return self }
        var onBrowsingStoppedState: OmniBarState { return HomeNonEditingState() }
        var onEnterPadState: OmniBarState { return self }
        var onEnterPhoneState: OmniBarState { return SmallOmniBarState.BrowsingNonEditingState() }
        var onReloadState: OmniBarState { return BrowsingNonEditingState() }
    }

}
