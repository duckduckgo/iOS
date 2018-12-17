//
//  OmniBarState.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

protocol OmniBarState {
    var clearTextOnStart: Bool { get }
    var showSearchLoupe: Bool { get }
    var showCancel: Bool { get }
    var showSiteRating: Bool { get }
    var showBackground: Bool { get }
    var showClear: Bool { get }
    var showMenu: Bool { get }
    var showBookmarks: Bool { get }
    var showSettings: Bool { get }
    var name: String { get }
    var onEditingStoppedState: OmniBarState { get }
    var onEditingStartedState: OmniBarState { get }
    var onTextClearedState: OmniBarState { get }
    var onTextEnteredState: OmniBarState { get }
    var onBrowsingStartedState: OmniBarState { get }
    var onBrowsingStoppedState: OmniBarState { get }
    var supportingCancelButtonState: OmniBarState { get }
}

struct HomeEmptyEditingState: OmniBarState {
    let clearTextOnStart = true
    let showSearchLoupe = false
    let showCancel = false
    let showSiteRating = false
    let showBackground = true
    let showClear = false
    let showMenu = false
    let showBookmarks = true
    let showSettings = true
    var name: String { return Type.name(self) }
    var onEditingStoppedState: OmniBarState { return HomeNonEditingState() }
    var onEditingStartedState: OmniBarState { return self }
    var onTextClearedState: OmniBarState { return self }
    var onTextEnteredState: OmniBarState { return HomeTextEditingState() }
    var onBrowsingStartedState: OmniBarState { return BrowsingNonEditingState() }
    var onBrowsingStoppedState: OmniBarState { return self }
    var supportingCancelButtonState: OmniBarState { return SupportingCancelButtonHomeEmptyEditingState() }
}

struct HomeTextEditingState: OmniBarState {
    let clearTextOnStart = true
    let showSearchLoupe = false
    let showCancel = false
    let showSiteRating = false
    let showBackground = true
    let showClear = true
    let showMenu = false
    let showBookmarks = false
    let showSettings = false
    var name: String { return Type.name(self) }
    var onEditingStoppedState: OmniBarState { return HomeNonEditingState() }
    var onEditingStartedState: OmniBarState { return self }
    var onTextClearedState: OmniBarState { return HomeEmptyEditingState() }
    var onTextEnteredState: OmniBarState { return self }
    var onBrowsingStartedState: OmniBarState { return BrowsingNonEditingState() }
    var onBrowsingStoppedState: OmniBarState { return HomeEmptyEditingState() }
    var supportingCancelButtonState: OmniBarState { return SupportingCancelButtonHomeTextEditingState() }
}

struct HomeNonEditingState: OmniBarState {
    let clearTextOnStart = true
    let showSearchLoupe = false
    let showCancel = false
    let showSiteRating = false
    let showBackground = false
    let showClear = false
    let showMenu = false
    let showBookmarks = false
    let showSettings = true
    var name: String { return Type.name(self) }
    var onEditingStoppedState: OmniBarState { return self }
    var onEditingStartedState: OmniBarState { return HomeEmptyEditingState() }
    var onTextClearedState: OmniBarState { return HomeEmptyEditingState() }
    var onTextEnteredState: OmniBarState { return HomeTextEditingState() }
    var onBrowsingStartedState: OmniBarState { return BrowsingNonEditingState() }
    var onBrowsingStoppedState: OmniBarState { return HomeNonEditingState() }
    var supportingCancelButtonState: OmniBarState { return SupportingCancelButtonHomeNonEditingState() }
}

struct BrowsingEmptyEditingState: OmniBarState {
    let clearTextOnStart = true
    let showSearchLoupe = false
    let showCancel = false
    let showSiteRating = true
    let showBackground = true
    let showClear = false
    let showMenu = false
    let showBookmarks = false
    let showSettings = false
    var name: String { return Type.name(self) }
    var onEditingStoppedState: OmniBarState { return BrowsingNonEditingState() }
    var onEditingStartedState: OmniBarState { return self }
    var onTextClearedState: OmniBarState { return self }
    var onTextEnteredState: OmniBarState { return BrowsingTextEditingState() }
    var onBrowsingStartedState: OmniBarState { return self }
    var onBrowsingStoppedState: OmniBarState { return HomeEmptyEditingState() }
    var supportingCancelButtonState: OmniBarState { return SupportingCancelButtonBrowsingEmptyEditingState() }
}

struct BrowsingTextEditingState: OmniBarState {
    let clearTextOnStart = false
    let showSearchLoupe = false
    let showCancel = false
    let showSiteRating = true
    let showBackground = true
    let showClear = true
    let showMenu = false
    let showBookmarks = false
    let showSettings = false
    var name: String { return Type.name(self) }
    var onEditingStoppedState: OmniBarState { return BrowsingNonEditingState() }
    var onEditingStartedState: OmniBarState { return self }
    var onTextClearedState: OmniBarState { return BrowsingEmptyEditingState() }
    var onTextEnteredState: OmniBarState { return self }
    var onBrowsingStartedState: OmniBarState { return self }
    var onBrowsingStoppedState: OmniBarState { return HomeEmptyEditingState() }
    var supportingCancelButtonState: OmniBarState { return SupportingCancelButtonBrowsingTextEditingState() }
}

struct BrowsingNonEditingState: OmniBarState {
    let clearTextOnStart = false
    let showSearchLoupe = false
    let showCancel = false
    let showSiteRating = true
    let showBackground = false
    let showClear = false
    let showMenu = true
    let showBookmarks = false
    let showSettings = false
    var name: String { return Type.name(self) }
    var onEditingStoppedState: OmniBarState { return self }
    var onEditingStartedState: OmniBarState { return BrowsingTextEditingState() }
    var onTextClearedState: OmniBarState { return BrowsingEmptyEditingState() }
    var onTextEnteredState: OmniBarState { return BrowsingTextEditingState() }
    var onBrowsingStartedState: OmniBarState { return self }
    var onBrowsingStoppedState: OmniBarState { return HomeNonEditingState() }
    var supportingCancelButtonState: OmniBarState { return SupportingCancelButtonBrowsingNonEditingState() }
}
