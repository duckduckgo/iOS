//
//  SupportingCancelButtonOmniBarState.swift
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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
