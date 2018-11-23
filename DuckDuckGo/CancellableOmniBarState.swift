//
//  CancellableOmniBarState.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 23/11/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import Foundation
import Core

struct SupportingCancelButtonHomeEmptyEditingState: OmniBarState {
    var clearTextOnStart = true
    var showSearchLoupe = true
    let showSiteRating = false
    let showBackground = false
    let showClear = false
    let showMenu = false
    let showBookmarks = false
    let showSettings = false
    let showCancel: Bool = true
    var name: String { return Type.name(self) }
    var onEditingStoppedState: OmniBarState { return HomeNonEditingState() }
    var onEditingStartedState: OmniBarState { return self }
    var onTextClearedState: OmniBarState { return self }
    var onTextEnteredState: OmniBarState { return HomeTextEditingState() }
    var onBrowsingStartedState: OmniBarState { return BrowsingNonEditingState() }
    var onBrowsingStoppedState: OmniBarState { return self }
    var supportingCancelButtonState: OmniBarState { return self }
}

struct SupportingCancelButtonHomeTextEditingState: OmniBarState {
    var clearTextOnStart = true
    var showSearchLoupe = true
    let showSiteRating = false
    let showBackground = false
    let showClear = true
    let showMenu = false
    let showBookmarks = false
    let showSettings = false
    let showCancel: Bool = true
    var name: String { return Type.name(self) }
    var onEditingStoppedState: OmniBarState { return HomeNonEditingState() }
    var onEditingStartedState: OmniBarState { return self }
    var onTextClearedState: OmniBarState { return HomeEmptyEditingState() }
    var onTextEnteredState: OmniBarState { return self }
    var onBrowsingStartedState: OmniBarState { return BrowsingNonEditingState() }
    var onBrowsingStoppedState: OmniBarState { return HomeEmptyEditingState() }
    var supportingCancelButtonState: OmniBarState { return self }
}

struct SupportingCancelButtonHomeNonEditingState: OmniBarState {
    var clearTextOnStart = true
    var showSearchLoupe = true
    let showSiteRating = false
    let showBackground = true
    let showClear = false
    let showMenu = false
    let showBookmarks = false
    let showSettings = true
    let showCancel: Bool = true
    var name: String { return Type.name(self) }
    var onEditingStoppedState: OmniBarState { return self }
    var onEditingStartedState: OmniBarState { return HomeEmptyEditingState() }
    var onTextClearedState: OmniBarState { return HomeEmptyEditingState() }
    var onTextEnteredState: OmniBarState { return HomeTextEditingState() }
    var onBrowsingStartedState: OmniBarState { return BrowsingNonEditingState() }
    var onBrowsingStoppedState: OmniBarState { return HomeNonEditingState() }
    var supportingCancelButtonState: OmniBarState { return self }
}

struct SupportingCancelButtonBrowsingEmptyEditingState: OmniBarState {
    var clearTextOnStart = true
    var showSearchLoupe = false
    let showSiteRating = true
    let showBackground = false
    let showClear = false
    let showMenu = false
    let showBookmarks = false
    let showSettings = false
    let showCancel: Bool = false
    var name: String { return Type.name(self) }
    var onEditingStoppedState: OmniBarState { return BrowsingNonEditingState() }
    var onEditingStartedState: OmniBarState { return self }
    var onTextClearedState: OmniBarState { return self }
    var onTextEnteredState: OmniBarState { return BrowsingTextEditingState() }
    var onBrowsingStartedState: OmniBarState { return self }
    var onBrowsingStoppedState: OmniBarState { return HomeEmptyEditingState() }
    var supportingCancelButtonState: OmniBarState { return self }
}

struct SupportingCancelButtonBrowsingTextEditingState: OmniBarState {
    var clearTextOnStart = false
    var showSearchLoupe = false
    let showSiteRating = true
    let showBackground = false
    let showClear = true
    let showMenu = false
    let showBookmarks = false
    let showSettings = false
    let showCancel: Bool = false
    var name: String { return Type.name(self) }
    var onEditingStoppedState: OmniBarState { return BrowsingNonEditingState() }
    var onEditingStartedState: OmniBarState { return self }
    var onTextClearedState: OmniBarState { return BrowsingEmptyEditingState() }
    var onTextEnteredState: OmniBarState { return self }
    var onBrowsingStartedState: OmniBarState { return self }
    var onBrowsingStoppedState: OmniBarState { return HomeEmptyEditingState() }
    var supportingCancelButtonState: OmniBarState { return self }
}

struct SupportingCancelButtonBrowsingNonEditingState: OmniBarState {
    var clearTextOnStart = false
    var showSearchLoupe = false
    let showSiteRating = true
    let showBackground = true
    let showClear = false
    let showMenu = true
    let showBookmarks = false
    let showSettings = false
    let showCancel: Bool = false
    var name: String { return Type.name(self) }
    var onEditingStoppedState: OmniBarState { return self }
    var onEditingStartedState: OmniBarState { return BrowsingTextEditingState() }
    var onTextClearedState: OmniBarState { return BrowsingEmptyEditingState() }
    var onTextEnteredState: OmniBarState { return BrowsingTextEditingState() }
    var onBrowsingStartedState: OmniBarState { return self }
    var onBrowsingStoppedState: OmniBarState { return HomeNonEditingState() }
    var supportingCancelButtonState: OmniBarState { return self }
}
