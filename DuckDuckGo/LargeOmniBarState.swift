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
import BrowserServicesKit
struct LargeOmniBarState {

    struct HomeEmptyEditingState: OmniBarState, OmniBarLoadingBearerStateCreating {
        let hasLargeWidth: Bool = true
        let showBackButton: Bool = true
        let showForwardButton: Bool = true
        let showBookmarksButton: Bool = true
        var showAccessoryButton: Bool { dependencies.isAIChatEnabledOnSettingsAndFeatureFlagOn }
        let clearTextOnStart = true
        let allowsTrackersAnimation = false
        let showPrivacyIcon = false
        let showBackground = false
        let showClear = false
        let showAbort = false
        let showRefresh = false
        var showMenu: Bool { dependencies.featureFlagger.isFeatureOn(.aiChatNewTabPage) ? true : false }
        var showSettings: Bool { dependencies.featureFlagger.isFeatureOn(.aiChatNewTabPage) ? false : true }
        let showCancel: Bool = false
        let showDismiss: Bool = false
        var name: String { return "Pad" + Type.name(self) }
        var onEditingStoppedState: OmniBarState { return HomeNonEditingState(dependencies: dependencies, isLoading: isLoading) }
        var onEditingStartedState: OmniBarState { return self }
        var onTextClearedState: OmniBarState { return self }
        var onTextEnteredState: OmniBarState { return HomeTextEditingState(dependencies: dependencies, isLoading: isLoading) }
        var onBrowsingStartedState: OmniBarState { return BrowsingNonEditingState(dependencies: dependencies, isLoading: isLoading) }
        var onBrowsingStoppedState: OmniBarState { return self }
        var onEnterPadState: OmniBarState { return self }
        var onEnterPhoneState: OmniBarState { return SmallOmniBarState.HomeEmptyEditingState(dependencies: dependencies, isLoading: isLoading) }
        var onReloadState: OmniBarState { return BrowsingNonEditingState(dependencies: dependencies, isLoading: isLoading) }
        var showSearchLoupe: Bool { !dependencies.voiceSearchHelper.isVoiceSearchEnabled }
        var showVoiceSearch: Bool { dependencies.voiceSearchHelper.isVoiceSearchEnabled }

        let dependencies: OmnibarDependencyProvider
        let isLoading: Bool

        func withLoading() -> LargeOmniBarState.HomeEmptyEditingState {
            Self.init(dependencies: dependencies, isLoading: true)
        }

        func withoutLoading() -> LargeOmniBarState.HomeEmptyEditingState {
            Self.init(dependencies: dependencies, isLoading: false)
        }
    }

    struct HomeTextEditingState: OmniBarState, OmniBarLoadingBearerStateCreating {
        let hasLargeWidth: Bool = true
        let showBackButton: Bool = true
        let showForwardButton: Bool = true
        let showBookmarksButton: Bool = true
        var showAccessoryButton: Bool { dependencies.isAIChatEnabledOnSettingsAndFeatureFlagOn }
        let clearTextOnStart = false
        let allowsTrackersAnimation = false
        let showPrivacyIcon = false
        let showBackground = false
        let showClear = true
        let showAbort = false
        let showRefresh = false
        var showMenu: Bool { dependencies.featureFlagger.isFeatureOn(.aiChatNewTabPage) ? true : false }
        var showSettings: Bool { dependencies.featureFlagger.isFeatureOn(.aiChatNewTabPage) ? false : true }
        let showCancel: Bool = false
        let showDismiss: Bool = false
        var name: String { return "Pad" + Type.name(self) }
        var onEditingStoppedState: OmniBarState { return HomeNonEditingState(dependencies: dependencies, isLoading: isLoading) }
        var onEditingStartedState: OmniBarState { return self }
        var onTextClearedState: OmniBarState { return HomeEmptyEditingState(dependencies: dependencies, isLoading: isLoading) }
        var onTextEnteredState: OmniBarState { return self }
        var onBrowsingStartedState: OmniBarState { return BrowsingNonEditingState(dependencies: dependencies, isLoading: isLoading) }
        var onBrowsingStoppedState: OmniBarState { return HomeEmptyEditingState(dependencies: dependencies, isLoading: isLoading) }
        var onEnterPadState: OmniBarState { return self }
        var onEnterPhoneState: OmniBarState { return SmallOmniBarState.HomeTextEditingState(dependencies: dependencies, isLoading: isLoading) }
        var onReloadState: OmniBarState { return HomeTextEditingState(dependencies: dependencies, isLoading: isLoading) }
        var showSearchLoupe: Bool { !dependencies.voiceSearchHelper.isVoiceSearchEnabled }
        var showVoiceSearch: Bool { dependencies.voiceSearchHelper.isVoiceSearchEnabled }

        let dependencies: OmnibarDependencyProvider
        let isLoading: Bool
    }

    struct HomeNonEditingState: OmniBarState, OmniBarLoadingBearerStateCreating {
        let hasLargeWidth: Bool = true
        let showBackButton: Bool = true
        let showForwardButton: Bool = true
        let showBookmarksButton: Bool = true
        var showAccessoryButton: Bool { dependencies.isAIChatEnabledOnSettingsAndFeatureFlagOn }
        let clearTextOnStart = true
        let allowsTrackersAnimation = false
        let showSearchLoupe = true
        let showPrivacyIcon = false
        let showBackground = true
        let showClear = false
        let showAbort = false
        let showRefresh = false
        var showMenu: Bool { dependencies.featureFlagger.isFeatureOn(.aiChatNewTabPage) ? true : false }
        var showSettings: Bool { dependencies.featureFlagger.isFeatureOn(.aiChatNewTabPage) ? false : true }
        let showCancel: Bool = false
        let showDismiss: Bool = false
        var name: String { return "Pad" + Type.name(self) }
        var onEditingStoppedState: OmniBarState { return self }
        var onEditingStartedState: OmniBarState { return HomeEmptyEditingState(dependencies: dependencies, isLoading: isLoading) }
        var onTextClearedState: OmniBarState { return HomeEmptyEditingState(dependencies: dependencies, isLoading: isLoading) }
        var onTextEnteredState: OmniBarState { return HomeTextEditingState(dependencies: dependencies, isLoading: isLoading) }
        var onBrowsingStartedState: OmniBarState { return BrowsingNonEditingState(dependencies: dependencies, isLoading: isLoading) }
        var onBrowsingStoppedState: OmniBarState { return HomeNonEditingState(dependencies: dependencies, isLoading: isLoading) }
        var onEnterPadState: OmniBarState { return self }
        var onEnterPhoneState: OmniBarState { return SmallOmniBarState.HomeNonEditingState(dependencies: dependencies, isLoading: isLoading) }
        var onReloadState: OmniBarState { return HomeNonEditingState(dependencies: dependencies, isLoading: isLoading) }
        var showVoiceSearch: Bool { dependencies.voiceSearchHelper.isVoiceSearchEnabled }

        let dependencies: OmnibarDependencyProvider
        let isLoading: Bool
    }

    struct BrowsingEmptyEditingState: OmniBarState, OmniBarLoadingBearerStateCreating {
        let hasLargeWidth: Bool = true
        let showBackButton: Bool = true
        let showForwardButton: Bool = true
        let showBookmarksButton: Bool = true
        let showAccessoryButton: Bool = true
        let clearTextOnStart = true
        let allowsTrackersAnimation = false
        let showPrivacyIcon = false
        let showBackground = false
        let showClear = false
        let showAbort = false
        let showRefresh = false
        let showMenu = true
        let showSettings = false
        let showCancel: Bool = false
        let showDismiss: Bool = false
        var name: String { return "Pad" + Type.name(self) }
        var onEditingStoppedState: OmniBarState { return BrowsingNonEditingState(dependencies: dependencies, isLoading: isLoading) }
        var onEditingStartedState: OmniBarState { return self }
        var onTextClearedState: OmniBarState { return self }
        var onTextEnteredState: OmniBarState { return BrowsingTextEditingState(dependencies: dependencies, isLoading: isLoading) }
        var onBrowsingStartedState: OmniBarState { return self }
        var onBrowsingStoppedState: OmniBarState { return HomeEmptyEditingState(dependencies: dependencies, isLoading: isLoading) }
        var onEnterPadState: OmniBarState { return self }
        var onEnterPhoneState: OmniBarState { return SmallOmniBarState.BrowsingEmptyEditingState(dependencies: dependencies, isLoading: isLoading) }
        var onReloadState: OmniBarState { return BrowsingEmptyEditingState(dependencies: dependencies, isLoading: isLoading) }
        var showSearchLoupe: Bool { !dependencies.voiceSearchHelper.isVoiceSearchEnabled }
        var showVoiceSearch: Bool { dependencies.voiceSearchHelper.isVoiceSearchEnabled }

        let dependencies: OmnibarDependencyProvider
        let isLoading: Bool
    }

    struct BrowsingTextEditingState: OmniBarState, OmniBarLoadingBearerStateCreating {
        let hasLargeWidth: Bool = true
        let showBackButton: Bool = true
        let showForwardButton: Bool = true
        let showBookmarksButton: Bool = true
        let showAccessoryButton: Bool = true
        let clearTextOnStart = false
        let allowsTrackersAnimation = false
        let showPrivacyIcon = false
        let showBackground = false
        let showClear = true
        let showAbort = false
        let showRefresh = false
        let showMenu = true
        let showSettings = false
        let showCancel: Bool = false
        let showDismiss: Bool = false
        var name: String { return "Pad" + Type.name(self) }
        var onEditingStoppedState: OmniBarState { return BrowsingNonEditingState(dependencies: dependencies, isLoading: isLoading) }
        var onEditingStartedState: OmniBarState { return self }
        var onTextClearedState: OmniBarState { return BrowsingEmptyEditingState(dependencies: dependencies, isLoading: isLoading) }
        var onTextEnteredState: OmniBarState { return self }
        var onBrowsingStartedState: OmniBarState { return self }
        var onBrowsingStoppedState: OmniBarState { return HomeEmptyEditingState(dependencies: dependencies, isLoading: isLoading) }
        var onEnterPadState: OmniBarState { return self }
        var onEnterPhoneState: OmniBarState { return SmallOmniBarState.BrowsingTextEditingState(dependencies: dependencies, isLoading: isLoading) }
        var onReloadState: OmniBarState { return BrowsingTextEditingState(dependencies: dependencies, isLoading: isLoading) }
        var showSearchLoupe: Bool { !dependencies.voiceSearchHelper.isVoiceSearchEnabled }
        var showVoiceSearch: Bool { dependencies.voiceSearchHelper.isVoiceSearchEnabled }

        let dependencies: OmnibarDependencyProvider
        let isLoading: Bool
    }

    struct BrowsingNonEditingState: OmniBarState, OmniBarLoadingBearerStateCreating {
        let hasLargeWidth: Bool = true
        let showBackButton: Bool = true
        let showForwardButton: Bool = true
        let showBookmarksButton: Bool = true
        let showAccessoryButton: Bool = true
        let clearTextOnStart = false
        let allowsTrackersAnimation = true
        let showSearchLoupe = false
        let showPrivacyIcon = true
        let showBackground = true
        let showClear = false
        var showAbort: Bool { isLoading }
        var showRefresh: Bool { !isLoading }
        let showMenu = true
        let showSettings = false
        let showCancel: Bool = false
        let showDismiss: Bool = false
        let showVoiceSearch = false
        var name: String { return "Pad" + Type.name(self) }
        var onEditingStoppedState: OmniBarState { return self }
        var onEditingStartedState: OmniBarState { return BrowsingTextEditingState(dependencies: dependencies, isLoading: isLoading) }
        var onTextClearedState: OmniBarState { return BrowsingEmptyEditingState(dependencies: dependencies, isLoading: isLoading) }
        var onTextEnteredState: OmniBarState { return BrowsingTextEditingState(dependencies: dependencies, isLoading: isLoading) }
        var onBrowsingStartedState: OmniBarState { return self }
        var onBrowsingStoppedState: OmniBarState { return HomeNonEditingState(dependencies: dependencies, isLoading: isLoading) }
        var onEnterPadState: OmniBarState { return self }
        var onEnterPhoneState: OmniBarState { return SmallOmniBarState.BrowsingNonEditingState(dependencies: dependencies, isLoading: isLoading) }
        var onReloadState: OmniBarState { return BrowsingNonEditingState(dependencies: dependencies, isLoading: isLoading) }

        let dependencies: OmnibarDependencyProvider
        let isLoading: Bool
    }
}
