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

struct SmallOmniBarState {

    struct HomeEmptyEditingState: OmniBarState {
        let hasLargeWidth: Bool = false
        let showBackButton: Bool = false
        let showForwardButton: Bool = false
        let showBookmarksButton: Bool = false
        let showShareButton: Bool = false
        let clearTextOnStart = true
        let allowsTrackersAnimation = false
        let showSearchLoupe = true
        let showSiteRating = false
        let showBackground = false
        let showClear = false
        let showRefresh = false
        let showMenu = false
        let showSettings = false
        let showCancel: Bool = true
        var name: String { return "Phone" + Type.name(self) }
        var onEditingStoppedState: OmniBarState { return HomeNonEditingState() }
        var onEditingStartedState: OmniBarState { return self }
        var onTextClearedState: OmniBarState { return self }
        var onTextEnteredState: OmniBarState { return HomeTextEditingState() }
        var onBrowsingStartedState: OmniBarState { return BrowsingNonEditingState() }
        var onBrowsingStoppedState: OmniBarState { return self }
        var onEnterPadState: OmniBarState { return LargeOmniBarState.HomeEmptyEditingState() }
        var onEnterPhoneState: OmniBarState { return self }
    }

    struct HomeTextEditingState: OmniBarState {
        let hasLargeWidth: Bool = false
        let showBackButton: Bool = false
        let showForwardButton: Bool = false
        let showBookmarksButton: Bool = false
        let showShareButton: Bool = false
        let clearTextOnStart = false
        let allowsTrackersAnimation = false
        let showSearchLoupe = true
        let showSiteRating = false
        let showBackground = false
        let showClear = true
        let showRefresh = false
        let showMenu = false
        let showSettings = false
        let showCancel: Bool = true
        var name: String { return "Phone" + Type.name(self) }
        var onEditingStoppedState: OmniBarState { return HomeNonEditingState() }
        var onEditingStartedState: OmniBarState { return self }
        var onTextClearedState: OmniBarState { return HomeEmptyEditingState() }
        var onTextEnteredState: OmniBarState { return self }
        var onBrowsingStartedState: OmniBarState { return BrowsingNonEditingState() }
        var onBrowsingStoppedState: OmniBarState { return HomeEmptyEditingState() }
        var onEnterPadState: OmniBarState { return LargeOmniBarState.HomeTextEditingState() }
        var onEnterPhoneState: OmniBarState { return self }
    }

    struct HomeNonEditingState: OmniBarState {
        let hasLargeWidth: Bool = false
        let showBackButton: Bool = false
        let showForwardButton: Bool = false
        let showBookmarksButton: Bool = false
        let showShareButton: Bool = false
        let clearTextOnStart = true
        let allowsTrackersAnimation = false
        let showSearchLoupe = true
        let showSiteRating = false
        let showBackground = true
        let showClear = false
        let showRefresh = false
        let showMenu = false
        let showSettings = true
        let showCancel: Bool = false
        var name: String { return "Phone" + Type.name(self) }
        var onEditingStoppedState: OmniBarState { return self }
        var onEditingStartedState: OmniBarState { return HomeEmptyEditingState() }
        var onTextClearedState: OmniBarState { return HomeEmptyEditingState() }
        var onTextEnteredState: OmniBarState { return HomeTextEditingState() }
        var onBrowsingStartedState: OmniBarState { return BrowsingNonEditingState() }
        var onBrowsingStoppedState: OmniBarState { return HomeNonEditingState() }
        var onEnterPadState: OmniBarState { return LargeOmniBarState.HomeNonEditingState() }
        var onEnterPhoneState: OmniBarState { return self }
    }

    struct BrowsingEmptyEditingState: OmniBarState {
        let hasLargeWidth: Bool = false
        let showBackButton: Bool = false
        let showForwardButton: Bool = false
        let showBookmarksButton: Bool = false
        let showShareButton: Bool = false
        let clearTextOnStart = true
        let allowsTrackersAnimation = false
        let showSearchLoupe = true
        let showSiteRating = false
        let showBackground = false
        let showClear = false
        let showRefresh = false
        let showMenu = false
        let showSettings = false
        let showCancel: Bool = true
        var name: String { return "Phone" + Type.name(self) }
        var onEditingStoppedState: OmniBarState { return BrowsingNonEditingState() }
        var onEditingStartedState: OmniBarState { return self }
        var onTextClearedState: OmniBarState { return self }
        var onTextEnteredState: OmniBarState { return BrowsingTextEditingState() }
        var onBrowsingStartedState: OmniBarState { return self }
        var onBrowsingStoppedState: OmniBarState { return HomeEmptyEditingState() }
        var onEnterPadState: OmniBarState { return LargeOmniBarState.BrowsingEmptyEditingState() }
        var onEnterPhoneState: OmniBarState { return self }
    }

    struct BrowsingTextEditingState: OmniBarState {
        let hasLargeWidth: Bool = false
        let showBackButton: Bool = false
        let showForwardButton: Bool = false
        let showBookmarksButton: Bool = false
        let showShareButton: Bool = false
        let clearTextOnStart = false
        let allowsTrackersAnimation = false
        let showSearchLoupe = true
        let showSiteRating = false
        let showBackground = false
        let showClear = true
        let showRefresh = false
        let showMenu = false
        let showSettings = false
        let showCancel: Bool = true
        var name: String { return "Phone" + Type.name(self) }
        var onEditingStoppedState: OmniBarState { return BrowsingNonEditingState() }
        var onEditingStartedState: OmniBarState { return self }
        var onTextClearedState: OmniBarState { return BrowsingEmptyEditingState() }
        var onTextEnteredState: OmniBarState { return self }
        var onBrowsingStartedState: OmniBarState { return self }
        var onBrowsingStoppedState: OmniBarState { return HomeEmptyEditingState() }
        var onEnterPadState: OmniBarState { return LargeOmniBarState.BrowsingTextEditingState() }
        var onEnterPhoneState: OmniBarState { return self }
    }

    struct BrowsingNonEditingState: OmniBarState {
        let hasLargeWidth: Bool = false
        let showBackButton: Bool = false
        let showForwardButton: Bool = false
        let showBookmarksButton: Bool = false
        let showShareButton: Bool = false
        let clearTextOnStart = false
        let allowsTrackersAnimation = true
        let showSearchLoupe = false
        let showSiteRating = true
        let showBackground = true
        let showClear = false
        let showRefresh = true
        let showMenu = true
        let showSettings = false
        let showCancel: Bool = false
        var name: String { return "Phone" + Type.name(self) }
        var onEditingStoppedState: OmniBarState { return self }
        var onEditingStartedState: OmniBarState { return BrowsingTextEditingState() }
        var onTextClearedState: OmniBarState { return BrowsingEmptyEditingState() }
        var onTextEnteredState: OmniBarState { return BrowsingTextEditingState() }
        var onBrowsingStartedState: OmniBarState { return self }
        var onBrowsingStoppedState: OmniBarState { return HomeNonEditingState() }
        var onEnterPadState: OmniBarState { return LargeOmniBarState.BrowsingNonEditingState() }
        var onEnterPhoneState: OmniBarState { return self }
    }

}
