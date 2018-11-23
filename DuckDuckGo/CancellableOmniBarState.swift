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
    var onEditingStoppedState: OmniBarState { return SupportingCancelButtonHomeNonEditingState() }
    var onEditingStartedState: OmniBarState { return self }
    var onTextClearedState: OmniBarState { return self }
    var onTextEnteredState: OmniBarState { return SupportingCancelButtonHomeTextEditingState() }
    var onBrowsingStartedState: OmniBarState { return SupportingCancelButtonBrowsingNonEditingState() }
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
    var onEditingStoppedState: OmniBarState { return SupportingCancelButtonHomeNonEditingState() }
    var onEditingStartedState: OmniBarState { return self }
    var onTextClearedState: OmniBarState { return SupportingCancelButtonHomeEmptyEditingState() }
    var onTextEnteredState: OmniBarState { return self }
    var onBrowsingStartedState: OmniBarState { return SupportingCancelButtonBrowsingNonEditingState() }
    var onBrowsingStoppedState: OmniBarState { return SupportingCancelButtonHomeEmptyEditingState() }
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
    var onEditingStartedState: OmniBarState { return SupportingCancelButtonHomeEmptyEditingState() }
    var onTextClearedState: OmniBarState { return SupportingCancelButtonHomeEmptyEditingState() }
    var onTextEnteredState: OmniBarState { return SupportingCancelButtonHomeTextEditingState() }
    var onBrowsingStartedState: OmniBarState { return SupportingCancelButtonBrowsingNonEditingState() }
    var onBrowsingStoppedState: OmniBarState { return SupportingCancelButtonHomeNonEditingState() }
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
    var onEditingStoppedState: OmniBarState { return SupportingCancelButtonBrowsingNonEditingState() }
    var onEditingStartedState: OmniBarState { return self }
    var onTextClearedState: OmniBarState { return self }
    var onTextEnteredState: OmniBarState { return SupportingCancelButtonBrowsingTextEditingState() }
    var onBrowsingStartedState: OmniBarState { return self }
    var onBrowsingStoppedState: OmniBarState { return SupportingCancelButtonHomeEmptyEditingState() }
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
    var onEditingStoppedState: OmniBarState { return SupportingCancelButtonBrowsingNonEditingState() }
    var onEditingStartedState: OmniBarState { return self }
    var onTextClearedState: OmniBarState { return SupportingCancelButtonBrowsingEmptyEditingState() }
    var onTextEnteredState: OmniBarState { return self }
    var onBrowsingStartedState: OmniBarState { return self }
    var onBrowsingStoppedState: OmniBarState { return SupportingCancelButtonHomeEmptyEditingState() }
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
    var onEditingStartedState: OmniBarState { return SupportingCancelButtonBrowsingTextEditingState() }
    var onTextClearedState: OmniBarState { return SupportingCancelButtonBrowsingEmptyEditingState() }
    var onTextEnteredState: OmniBarState { return SupportingCancelButtonBrowsingTextEditingState() }
    var onBrowsingStartedState: OmniBarState { return self }
    var onBrowsingStoppedState: OmniBarState { return SupportingCancelButtonHomeNonEditingState() }
    var supportingCancelButtonState: OmniBarState { return self }
}
