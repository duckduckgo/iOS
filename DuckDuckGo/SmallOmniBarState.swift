//
//  SmallOmniBarState.swift
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
import BrowserServicesKit
struct SmallOmniBarState {

    struct HomeEmptyEditingState: OmniBarState, OmniBarLoadingBearerStateCreating {
        let hasLargeWidth: Bool = false
        let showBackButton: Bool = false
        let showForwardButton: Bool = false
        let showBookmarksButton: Bool = false
        var showAccessoryButton: Bool { featureFlagger.isFeatureOn(.aiChatNewTabPage) ? true : false }
        let clearTextOnStart = true
        let allowsTrackersAnimation = false
        let showPrivacyIcon = false
        let showBackground = false
        let showClear = false
        let showAbort = false
        let showRefresh = false
        let showMenu = false
        let showSettings = false
        var showCancel: Bool { featureFlagger.isFeatureOn(.aiChatNewTabPage) ? false : true }
        var showDismiss: Bool { featureFlagger.isFeatureOn(.aiChatNewTabPage) ? true : false }
        var name: String { return "Phone" + Type.name(self) }
        var onEditingStoppedState: OmniBarState { return HomeNonEditingState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }
        var onEditingStartedState: OmniBarState { return self }
        var onTextClearedState: OmniBarState { return self }
        var onTextEnteredState: OmniBarState { return HomeTextEditingState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }
        var onBrowsingStartedState: OmniBarState { return BrowsingNonEditingState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }
        var onBrowsingStoppedState: OmniBarState { return self }
        var onEnterPadState: OmniBarState { return LargeOmniBarState.HomeEmptyEditingState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }
        var onEnterPhoneState: OmniBarState { return self }
        var onReloadState: OmniBarState { return HomeEmptyEditingState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }
        var showSearchLoupe: Bool { !voiceSearchHelper.isSpeechRecognizerAvailable }
        var showVoiceSearch: Bool { voiceSearchHelper.isVoiceSearchEnabled }

        let voiceSearchHelper: VoiceSearchHelperProtocol
        let featureFlagger: FeatureFlagger
        let isLoading: Bool
    }

    struct HomeTextEditingState: OmniBarState, OmniBarLoadingBearerStateCreating {
        let hasLargeWidth: Bool = false
        let showBackButton: Bool = false
        let showForwardButton: Bool = false
        let showBookmarksButton: Bool = false
        var showAccessoryButton: Bool { featureFlagger.isFeatureOn(.aiChatNewTabPage) ? true : false }
        let clearTextOnStart = false
        let allowsTrackersAnimation = false
        let showPrivacyIcon = false
        let showBackground = false
        let showClear = true
        let showAbort = false
        let showRefresh = false
        let showMenu = false
        let showSettings = false
        var showCancel: Bool { featureFlagger.isFeatureOn(.aiChatNewTabPage) ? false : true }
        var showDismiss: Bool { featureFlagger.isFeatureOn(.aiChatNewTabPage) ? true : false }
        let showVoiceSearch = false
        var name: String { return "Phone" + Type.name(self) }
        var onEditingStoppedState: OmniBarState { return HomeNonEditingState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }
        var onEditingStartedState: OmniBarState { return self }
        var onTextClearedState: OmniBarState { return HomeEmptyEditingState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }
        var onTextEnteredState: OmniBarState { return self }
        var onBrowsingStartedState: OmniBarState { return BrowsingNonEditingState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }
        var onBrowsingStoppedState: OmniBarState { return HomeEmptyEditingState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }
        var onEnterPadState: OmniBarState { return LargeOmniBarState.HomeTextEditingState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }
        var onEnterPhoneState: OmniBarState { return self }
        var onReloadState: OmniBarState { return HomeTextEditingState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }
        var showSearchLoupe: Bool { !voiceSearchHelper.isSpeechRecognizerAvailable }

        let voiceSearchHelper: VoiceSearchHelperProtocol
        let featureFlagger: FeatureFlagger
        let isLoading: Bool
    }

    struct HomeNonEditingState: OmniBarState, OmniBarLoadingBearerStateCreating {
        let hasLargeWidth: Bool = false
        let showBackButton: Bool = false
        let showForwardButton: Bool = false
        let showBookmarksButton: Bool = false
        var showAccessoryButton: Bool { featureFlagger.isFeatureOn(.aiChatNewTabPage) ? true : false }
        let clearTextOnStart = true
        let allowsTrackersAnimation = false
        let showSearchLoupe = true
        let showPrivacyIcon = false
        let showBackground = true
        let showClear = false
        let showAbort = false
        let showRefresh = false
        let showMenu = false
        var showSettings: Bool { featureFlagger.isFeatureOn(.aiChatNewTabPage) ? false : true }
        let showDismiss: Bool = false
        let showCancel: Bool = false
        var name: String { return "Phone" + Type.name(self) }
        var onEditingStoppedState: OmniBarState { return self }
        var onEditingStartedState: OmniBarState { return HomeEmptyEditingState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }
        var onTextClearedState: OmniBarState { return HomeEmptyEditingState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }
        var onTextEnteredState: OmniBarState { return HomeTextEditingState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }
        var onBrowsingStartedState: OmniBarState { return BrowsingNonEditingState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }
        var onBrowsingStoppedState: OmniBarState { return HomeNonEditingState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }
        var onEnterPadState: OmniBarState { return LargeOmniBarState.HomeNonEditingState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }
        var onEnterPhoneState: OmniBarState { return self }
        var onReloadState: OmniBarState { return HomeNonEditingState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }

        var showVoiceSearch: Bool { voiceSearchHelper.isVoiceSearchEnabled }

        let voiceSearchHelper: VoiceSearchHelperProtocol
        let featureFlagger: FeatureFlagger
        let isLoading: Bool
    }

    struct BrowsingEmptyEditingState: OmniBarState, OmniBarLoadingBearerStateCreating {
        let hasLargeWidth: Bool = false
        let showBackButton: Bool = false
        let showForwardButton: Bool = false
        let showBookmarksButton: Bool = false
        var showAccessoryButton: Bool { featureFlagger.isFeatureOn(.aiChatNewTabPage) ? true : false }
        let clearTextOnStart = true
        let allowsTrackersAnimation = false
        let showPrivacyIcon = false
        let showBackground = false
        let showClear = false
        let showAbort = false
        let showRefresh = false
        let showMenu = false
        let showSettings = false
        var showCancel: Bool { featureFlagger.isFeatureOn(.aiChatNewTabPage) ? false : true }
        var showDismiss: Bool { featureFlagger.isFeatureOn(.aiChatNewTabPage) ? true : false }
        var name: String { return "Phone" + Type.name(self) }
        var onEditingStoppedState: OmniBarState { return BrowsingNonEditingState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }
        var onEditingStartedState: OmniBarState { return self }
        var onTextClearedState: OmniBarState { return self }
        var onTextEnteredState: OmniBarState { return BrowsingTextEditingState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }
        var onBrowsingStartedState: OmniBarState { return self }
        var onBrowsingStoppedState: OmniBarState { return HomeEmptyEditingState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }
        var onEnterPadState: OmniBarState { return LargeOmniBarState.BrowsingEmptyEditingState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }
        var onEnterPhoneState: OmniBarState { return self }
        var onReloadState: OmniBarState { return BrowsingEmptyEditingState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }

        var showSearchLoupe: Bool { !voiceSearchHelper.isVoiceSearchEnabled }
        var showVoiceSearch: Bool { voiceSearchHelper.isVoiceSearchEnabled }

        let voiceSearchHelper: VoiceSearchHelperProtocol
        let featureFlagger: FeatureFlagger
        let isLoading: Bool
    }

    struct BrowsingTextEditingState: OmniBarState, OmniBarLoadingBearerStateCreating {
        let hasLargeWidth: Bool = false
        let showBackButton: Bool = false
        let showForwardButton: Bool = false
        let showBookmarksButton: Bool = false
        var showAccessoryButton: Bool { featureFlagger.isFeatureOn(.aiChatNewTabPage) ? true : false }
        let clearTextOnStart = false
        let allowsTrackersAnimation = false
        let showPrivacyIcon = false
        let showBackground = false
        let showClear = true
        let showAbort = false
        let showRefresh = false
        let showMenu = false
        let showSettings = false
        var showCancel: Bool { featureFlagger.isFeatureOn(.aiChatNewTabPage) ? false : true }
        var showDismiss: Bool { featureFlagger.isFeatureOn(.aiChatNewTabPage) ? true : false }
        let showVoiceSearch = false
        var name: String { return "Phone" + Type.name(self) }
        var onEditingStoppedState: OmniBarState { return BrowsingNonEditingState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }
        var onEditingStartedState: OmniBarState { return self }
        var onTextClearedState: OmniBarState { return BrowsingEmptyEditingState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }
        var onTextEnteredState: OmniBarState { return self }
        var onBrowsingStartedState: OmniBarState { return self }
        var onBrowsingStoppedState: OmniBarState { return HomeEmptyEditingState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }
        var onEnterPadState: OmniBarState { return LargeOmniBarState.BrowsingTextEditingState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }
        var onEnterPhoneState: OmniBarState { return self }
        var onReloadState: OmniBarState { return BrowsingTextEditingState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }

        var showSearchLoupe: Bool { !voiceSearchHelper.isVoiceSearchEnabled }

        let voiceSearchHelper: VoiceSearchHelperProtocol
        let featureFlagger: FeatureFlagger
        let isLoading: Bool
    }

    struct BrowsingNonEditingState: OmniBarState, OmniBarLoadingBearerStateCreating {
        let hasLargeWidth: Bool = false
        let showBackButton: Bool = false
        let showForwardButton: Bool = false
        let showBookmarksButton: Bool = false
        let showAccessoryButton: Bool = true
        let clearTextOnStart = false
        let allowsTrackersAnimation = true
        let showSearchLoupe = false
        let showPrivacyIcon = true
        let showBackground = true
        let showClear = false
        var showAbort: Bool { isLoading }
        var showRefresh: Bool { !isLoading }
        let showMenu = false
        let showSettings = false
        let showCancel: Bool = false
        let showVoiceSearch = false
        let showDismiss: Bool = false
        var name: String { return "Phone" + Type.name(self) }
        var onEditingStoppedState: OmniBarState { return self }
        var onEditingStartedState: OmniBarState { return BrowsingTextEditingStartedState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }
        var onTextClearedState: OmniBarState { return BrowsingEmptyEditingState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }
        var onTextEnteredState: OmniBarState { return BrowsingTextEditingState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }
        var onBrowsingStartedState: OmniBarState { return self }
        var onBrowsingStoppedState: OmniBarState { return HomeNonEditingState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }
        var onEnterPadState: OmniBarState { return LargeOmniBarState.BrowsingNonEditingState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }
        var onEnterPhoneState: OmniBarState { return self }
        var onReloadState: OmniBarState { return BrowsingNonEditingState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }

        let voiceSearchHelper: VoiceSearchHelperProtocol
        let featureFlagger: FeatureFlagger
        let isLoading: Bool
    }

    struct BrowsingTextEditingStartedState: OmniBarState, OmniBarLoadingBearerStateCreating {
        let hasLargeWidth: Bool = false
        let showBackButton: Bool = false
        let showForwardButton: Bool = false
        let showBookmarksButton: Bool = false
        var showAccessoryButton: Bool { featureFlagger.isFeatureOn(.aiChatNewTabPage) ? true : false }
        let clearTextOnStart = false
        let allowsTrackersAnimation = false
        let showPrivacyIcon = false
        let showBackground = false
        let showClear = true
        let showAbort = false
        let showRefresh = false
        let showMenu = false
        let showSettings = false
        var showDismiss: Bool { featureFlagger.isFeatureOn(.aiChatNewTabPage) ? true : false }
        var showCancel: Bool { featureFlagger.isFeatureOn(.aiChatNewTabPage) ? false : true }
        var name: String { return "Phone" + Type.name(self) }
        var onEditingStoppedState: OmniBarState { return BrowsingNonEditingState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }
        var onEditingStartedState: OmniBarState { return self }
        var onTextClearedState: OmniBarState { return BrowsingEmptyEditingState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }
        var onTextEnteredState: OmniBarState { return BrowsingTextEditingState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }
        var onBrowsingStartedState: OmniBarState { return self }
        var onBrowsingStoppedState: OmniBarState { return HomeEmptyEditingState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }
        var onEnterPadState: OmniBarState { return LargeOmniBarState.BrowsingTextEditingState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }
        var onEnterPhoneState: OmniBarState { return self }
        var onReloadState: OmniBarState { return BrowsingTextEditingStartedState(voiceSearchHelper: voiceSearchHelper, featureFlagger: featureFlagger, isLoading: isLoading) }
        var showSearchLoupe: Bool { !voiceSearchHelper.isVoiceSearchEnabled }
        var showVoiceSearch: Bool { voiceSearchHelper.isVoiceSearchEnabled }

        let voiceSearchHelper: VoiceSearchHelperProtocol
        let featureFlagger: FeatureFlagger
        let isLoading: Bool
    }
}
