//
//  PadOmniBarState.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 22/07/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import Foundation
import Core

struct PadOmniBar {
    
    struct HomeEmptyEditingState: OmniBarState {
        var centeredSearchField = true
        var clearTextOnStart = true
        var allowsTrackersAnimation = false
        var showSearchLoupe = true
        let showSiteRating = false
        let showBackground = false
        let showClear = false
        let showRefresh = false
        let showMenu = false
        let showSettings = false
        let showCancel: Bool = true
        var name: String { return "Pad" + Type.name(self) }
        var onEditingStoppedState: OmniBarState { return HomeNonEditingState() }
        var onEditingStartedState: OmniBarState { return self }
        var onTextClearedState: OmniBarState { return self }
        var onTextEnteredState: OmniBarState { return HomeTextEditingState() }
        var onBrowsingStartedState: OmniBarState { return BrowsingNonEditingState() }
        var onBrowsingStoppedState: OmniBarState { return self }
        var onEnterPadState: OmniBarState { return self }
        var onEnterPhoneState: OmniBarState { return PhoneOmniBar.HomeEmptyEditingState() }
    }

    struct HomeTextEditingState: OmniBarState {
        var centeredSearchField = true
        var clearTextOnStart = false
        var allowsTrackersAnimation = false
        var showSearchLoupe = true
        let showSiteRating = false
        let showBackground = false
        let showClear = true
        let showRefresh = false
        let showMenu = false
        let showSettings = false
        let showCancel: Bool = true
        var name: String { return "Pad" + Type.name(self) }
        var onEditingStoppedState: OmniBarState { return HomeNonEditingState() }
        var onEditingStartedState: OmniBarState { return self }
        var onTextClearedState: OmniBarState { return HomeEmptyEditingState() }
        var onTextEnteredState: OmniBarState { return self }
        var onBrowsingStartedState: OmniBarState { return BrowsingNonEditingState() }
        var onBrowsingStoppedState: OmniBarState { return HomeEmptyEditingState() }
        var onEnterPadState: OmniBarState { return self }
        var onEnterPhoneState: OmniBarState { return PhoneOmniBar.HomeTextEditingState() }
    }

    struct HomeNonEditingState: OmniBarState {
        var centeredSearchField = true
        var clearTextOnStart = true
        var allowsTrackersAnimation = false
        var showSearchLoupe = true
        let showSiteRating = false
        let showBackground = true
        let showClear = false
        let showRefresh = false
        let showMenu = false
        let showSettings = true
        let showCancel: Bool = false
        var name: String { return "Pad" + Type.name(self) }
        var onEditingStoppedState: OmniBarState { return self }
        var onEditingStartedState: OmniBarState { return HomeEmptyEditingState() }
        var onTextClearedState: OmniBarState { return HomeEmptyEditingState() }
        var onTextEnteredState: OmniBarState { return HomeTextEditingState() }
        var onBrowsingStartedState: OmniBarState { return BrowsingNonEditingState() }
        var onBrowsingStoppedState: OmniBarState { return HomeNonEditingState() }
        var onEnterPadState: OmniBarState { return self }
        var onEnterPhoneState: OmniBarState { return PhoneOmniBar.HomeNonEditingState() }
    }

    struct BrowsingEmptyEditingState: OmniBarState {
        var centeredSearchField = true
        var clearTextOnStart = true
        var allowsTrackersAnimation = false
        var showSearchLoupe = true
        let showSiteRating = false
        let showBackground = false
        let showClear = false
        let showRefresh = false
        let showMenu = false
        let showSettings = false
        let showCancel: Bool = true
        var name: String { return "Pad" + Type.name(self) }
        var onEditingStoppedState: OmniBarState { return BrowsingNonEditingState() }
        var onEditingStartedState: OmniBarState { return self }
        var onTextClearedState: OmniBarState { return self }
        var onTextEnteredState: OmniBarState { return BrowsingTextEditingState() }
        var onBrowsingStartedState: OmniBarState { return self }
        var onBrowsingStoppedState: OmniBarState { return HomeEmptyEditingState() }
        var onEnterPadState: OmniBarState { return self }
        var onEnterPhoneState: OmniBarState { return PhoneOmniBar.BrowsingEmptyEditingState() }
    }

    struct BrowsingTextEditingState: OmniBarState {
        var centeredSearchField = true
        var clearTextOnStart = false
        var allowsTrackersAnimation = false
        var showSearchLoupe = true
        let showSiteRating = false
        let showBackground = false
        let showClear = true
        let showRefresh = false
        let showMenu = false
        let showSettings = false
        let showCancel: Bool = true
        var name: String { return "Pad" + Type.name(self) }
        var onEditingStoppedState: OmniBarState { return BrowsingNonEditingState() }
        var onEditingStartedState: OmniBarState { return self }
        var onTextClearedState: OmniBarState { return BrowsingEmptyEditingState() }
        var onTextEnteredState: OmniBarState { return self }
        var onBrowsingStartedState: OmniBarState { return self }
        var onBrowsingStoppedState: OmniBarState { return HomeEmptyEditingState() }
        var onEnterPadState: OmniBarState { return self }
        var onEnterPhoneState: OmniBarState { return PhoneOmniBar.BrowsingTextEditingState() }
    }

    struct BrowsingNonEditingState: OmniBarState {
        var centeredSearchField = true
        var clearTextOnStart = false
        var allowsTrackersAnimation = true
        var showSearchLoupe = false
        let showSiteRating = true
        let showBackground = true
        let showClear = false
        let showRefresh = true
        let showMenu = true
        let showSettings = false
        let showCancel: Bool = false
        var name: String { return "Pad" + Type.name(self) }
        var onEditingStoppedState: OmniBarState { return self }
        var onEditingStartedState: OmniBarState { return BrowsingTextEditingState() }
        var onTextClearedState: OmniBarState { return BrowsingEmptyEditingState() }
        var onTextEnteredState: OmniBarState { return BrowsingTextEditingState() }
        var onBrowsingStartedState: OmniBarState { return self }
        var onBrowsingStoppedState: OmniBarState { return HomeNonEditingState() }
        var onEnterPadState: OmniBarState { return self }
        var onEnterPhoneState: OmniBarState { return PhoneOmniBar.BrowsingNonEditingState() }
    }

}
