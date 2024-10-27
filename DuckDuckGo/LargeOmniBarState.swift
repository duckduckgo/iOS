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
        let showPrivacyIcon = false
        let showBackground = false
        let showClear = false
        let showRefresh = false
        let showMenu = false
        let showSettings = true
        let showCancel: Bool = false
        var name: String { return "Pad" + Type.name(self) }
        var onEditingStoppedState: OmniBarState { return HomeNonEditingState(voiceSearchHelper: voiceSearchHelper) }
        var onEditingStartedState: OmniBarState { return self }
        var onTextClearedState: OmniBarState { return self }
        var onTextEnteredState: OmniBarState { return HomeTextEditingState(voiceSearchHelper: voiceSearchHelper) }
        var onBrowsingStartedState: OmniBarState { return BrowsingNonEditingState(voiceSearchHelper: voiceSearchHelper) }
        var onBrowsingStoppedState: OmniBarState { return self }
        var onEnterPadState: OmniBarState { return self }
        var onEnterPhoneState: OmniBarState { return SmallOmniBarState.HomeEmptyEditingState(voiceSearchHelper: voiceSearchHelper) }
        var onReloadState: OmniBarState { return BrowsingNonEditingState(voiceSearchHelper: voiceSearchHelper) }
        var showSearchLoupe: Bool { !voiceSearchHelper.isVoiceSearchEnabled }
        var showVoiceSearch: Bool { voiceSearchHelper.isVoiceSearchEnabled }

        let voiceSearchHelper: VoiceSearchHelperProtocol
    }

    struct HomeTextEditingState: OmniBarState {
        let hasLargeWidth: Bool = true
        let showBackButton: Bool = true
        let showForwardButton: Bool = true
        let showBookmarksButton: Bool = true
        let showShareButton: Bool = false
        let clearTextOnStart = false
        let allowsTrackersAnimation = false
        let showPrivacyIcon = false
        let showBackground = false
        let showClear = true
        let showRefresh = false
        let showMenu = false
        let showSettings = true
        let showCancel: Bool = false
        var name: String { return "Pad" + Type.name(self) }
        var onEditingStoppedState: OmniBarState { return HomeNonEditingState(voiceSearchHelper: voiceSearchHelper) }
        var onEditingStartedState: OmniBarState { return self }
        var onTextClearedState: OmniBarState { return HomeEmptyEditingState(voiceSearchHelper: voiceSearchHelper) }
        var onTextEnteredState: OmniBarState { return self }
        var onBrowsingStartedState: OmniBarState { return BrowsingNonEditingState(voiceSearchHelper: voiceSearchHelper) }
        var onBrowsingStoppedState: OmniBarState { return HomeEmptyEditingState(voiceSearchHelper: voiceSearchHelper) }
        var onEnterPadState: OmniBarState { return self }
        var onEnterPhoneState: OmniBarState { return SmallOmniBarState.HomeTextEditingState(voiceSearchHelper: voiceSearchHelper) }
        var onReloadState: OmniBarState { return HomeTextEditingState(voiceSearchHelper: voiceSearchHelper) }
        var showSearchLoupe: Bool { !voiceSearchHelper.isVoiceSearchEnabled }
        var showVoiceSearch: Bool { voiceSearchHelper.isVoiceSearchEnabled }

        let voiceSearchHelper: VoiceSearchHelperProtocol
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
        var name: String { return "Pad" + Type.name(self) }
        var onEditingStoppedState: OmniBarState { return self }
        var onEditingStartedState: OmniBarState { return HomeEmptyEditingState(voiceSearchHelper: voiceSearchHelper) }
        var onTextClearedState: OmniBarState { return HomeEmptyEditingState(voiceSearchHelper: voiceSearchHelper) }
        var onTextEnteredState: OmniBarState { return HomeTextEditingState(voiceSearchHelper: voiceSearchHelper) }
        var onBrowsingStartedState: OmniBarState { return BrowsingNonEditingState(voiceSearchHelper: voiceSearchHelper) }
        var onBrowsingStoppedState: OmniBarState { return HomeNonEditingState(voiceSearchHelper: voiceSearchHelper) }
        var onEnterPadState: OmniBarState { return self }
        var onEnterPhoneState: OmniBarState { return SmallOmniBarState.HomeNonEditingState(voiceSearchHelper: voiceSearchHelper) }
        var onReloadState: OmniBarState { return HomeNonEditingState(voiceSearchHelper: voiceSearchHelper) }
        var showVoiceSearch: Bool { voiceSearchHelper.isVoiceSearchEnabled }

        let voiceSearchHelper: VoiceSearchHelperProtocol
    }

    struct BrowsingEmptyEditingState: OmniBarState {
        let hasLargeWidth: Bool = true
        let showBackButton: Bool = true
        let showForwardButton: Bool = true
        let showBookmarksButton: Bool = true
        let showShareButton: Bool = true
        let clearTextOnStart = true
        let allowsTrackersAnimation = false
        let showPrivacyIcon = false
        let showBackground = false
        let showClear = false
        let showRefresh = false
        let showMenu = true
        let showSettings = false
        let showCancel: Bool = false
        var name: String { return "Pad" + Type.name(self) }
        var onEditingStoppedState: OmniBarState { return BrowsingNonEditingState(voiceSearchHelper: voiceSearchHelper) }
        var onEditingStartedState: OmniBarState { return self }
        var onTextClearedState: OmniBarState { return self }
        var onTextEnteredState: OmniBarState { return BrowsingTextEditingState(voiceSearchHelper: voiceSearchHelper) }
        var onBrowsingStartedState: OmniBarState { return self }
        var onBrowsingStoppedState: OmniBarState { return HomeEmptyEditingState(voiceSearchHelper: voiceSearchHelper) }
        var onEnterPadState: OmniBarState { return self }
        var onEnterPhoneState: OmniBarState { return SmallOmniBarState.BrowsingEmptyEditingState(voiceSearchHelper: voiceSearchHelper) }
        var onReloadState: OmniBarState { return BrowsingEmptyEditingState(voiceSearchHelper: voiceSearchHelper) }
        var showSearchLoupe: Bool { !voiceSearchHelper.isVoiceSearchEnabled }
        var showVoiceSearch: Bool { voiceSearchHelper.isVoiceSearchEnabled }

        let voiceSearchHelper: VoiceSearchHelperProtocol
    }

    struct BrowsingTextEditingState: OmniBarState {
        let hasLargeWidth: Bool = true
        let showBackButton: Bool = true
        let showForwardButton: Bool = true
        let showBookmarksButton: Bool = true
        let showShareButton: Bool = true
        let clearTextOnStart = false
        let allowsTrackersAnimation = false
        let showPrivacyIcon = false
        let showBackground = false
        let showClear = true
        let showRefresh = false
        let showMenu = true
        let showSettings = false
        let showCancel: Bool = false
        var name: String { return "Pad" + Type.name(self) }
        var onEditingStoppedState: OmniBarState { return BrowsingNonEditingState(voiceSearchHelper: voiceSearchHelper) }
        var onEditingStartedState: OmniBarState { return self }
        var onTextClearedState: OmniBarState { return BrowsingEmptyEditingState(voiceSearchHelper: voiceSearchHelper) }
        var onTextEnteredState: OmniBarState { return self }
        var onBrowsingStartedState: OmniBarState { return self }
        var onBrowsingStoppedState: OmniBarState { return HomeEmptyEditingState(voiceSearchHelper: voiceSearchHelper) }
        var onEnterPadState: OmniBarState { return self }
        var onEnterPhoneState: OmniBarState { return SmallOmniBarState.BrowsingTextEditingState(voiceSearchHelper: voiceSearchHelper) }
        var onReloadState: OmniBarState { return BrowsingTextEditingState(voiceSearchHelper: voiceSearchHelper) }
        var showSearchLoupe: Bool { !voiceSearchHelper.isVoiceSearchEnabled }
        var showVoiceSearch: Bool { voiceSearchHelper.isVoiceSearchEnabled }

        let voiceSearchHelper: VoiceSearchHelperProtocol
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
        var onEditingStartedState: OmniBarState { return BrowsingTextEditingState(voiceSearchHelper: voiceSearchHelper) }
        var onTextClearedState: OmniBarState { return BrowsingEmptyEditingState(voiceSearchHelper: voiceSearchHelper) }
        var onTextEnteredState: OmniBarState { return BrowsingTextEditingState(voiceSearchHelper: voiceSearchHelper) }
        var onBrowsingStartedState: OmniBarState { return self }
        var onBrowsingStoppedState: OmniBarState { return HomeNonEditingState(voiceSearchHelper: voiceSearchHelper) }
        var onEnterPadState: OmniBarState { return self }
        var onEnterPhoneState: OmniBarState { return SmallOmniBarState.BrowsingNonEditingState(voiceSearchHelper: voiceSearchHelper) }
        var onReloadState: OmniBarState { return BrowsingNonEditingState(voiceSearchHelper: voiceSearchHelper) }

        let voiceSearchHelper: VoiceSearchHelperProtocol
    }

}
