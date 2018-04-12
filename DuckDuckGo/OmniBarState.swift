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
    var showSiteRating: Bool { get }
    var showEditingBackground: Bool { get }
    var showClear: Bool { get }
    var showMenu: Bool { get }
    var showBookmarks: Bool { get }
    var name: String { get }
    var onEditingStoppedState: OmniBarState { get }
    var onEditingStartedState: OmniBarState { get }
    var onTextClearedState: OmniBarState { get }
    var onTextEnteredState: OmniBarState { get }
    var onBrowsingStartedState: OmniBarState { get }
    var onBrowsingStoppedState: OmniBarState { get }
}

struct HomeEmptyEditingState: OmniBarState {
    let showSiteRating = false
    let showEditingBackground = true
    let showClear = false
    let showMenu = false
    let showBookmarks = true
    var name: String { return Type.name(self) }
    var onEditingStoppedState: OmniBarState { return HomeNonEditingState() }
    var onEditingStartedState: OmniBarState { return self }
    var onTextClearedState: OmniBarState { return self }
    var onTextEnteredState: OmniBarState { return HomeTextEditingState() }
    var onBrowsingStartedState: OmniBarState { return BrowsingNonEditingState() }
    var onBrowsingStoppedState: OmniBarState { return self }
}

struct HomeTextEditingState: OmniBarState {
    let showSiteRating = false
    let showEditingBackground = true
    let showClear = true
    let showMenu = false
    let showBookmarks = false
    var name: String { return Type.name(self) }
    var onEditingStoppedState: OmniBarState{ return HomeNonEditingState() }
    var onEditingStartedState: OmniBarState { return self }
    var onTextClearedState: OmniBarState { return HomeEmptyEditingState() }
    var onTextEnteredState: OmniBarState { return self }
    var onBrowsingStartedState: OmniBarState { return BrowsingNonEditingState() }
    var onBrowsingStoppedState: OmniBarState { return HomeEmptyEditingState() }
}

struct HomeNonEditingState: OmniBarState {
    let showSiteRating = false
    let showEditingBackground = false
    let showClear = false
    let showMenu = false
    let showBookmarks = true
    var name: String { return Type.name(self) }
    var onEditingStoppedState: OmniBarState{ return self }
    var onEditingStartedState: OmniBarState { return HomeEmptyEditingState() }
    var onTextClearedState: OmniBarState { return HomeEmptyEditingState() }
    var onTextEnteredState: OmniBarState { return HomeTextEditingState() }
    var onBrowsingStartedState: OmniBarState { return BrowsingNonEditingState() }
    var onBrowsingStoppedState: OmniBarState { return HomeEmptyEditingState() }
}

struct BrowsingEmptyEditingState: OmniBarState {
    let showSiteRating = true
    let showEditingBackground = true
    let showClear = false
    let showMenu = false
    let showBookmarks = false
    var name: String { return Type.name(self) }
    var onEditingStoppedState: OmniBarState{ return BrowsingNonEditingState() }
    var onEditingStartedState: OmniBarState { return self }
    var onTextClearedState: OmniBarState { return self }
    var onTextEnteredState: OmniBarState { return BrowsingTextEditingState() }
    var onBrowsingStartedState: OmniBarState { return self }
    var onBrowsingStoppedState: OmniBarState { return HomeEmptyEditingState() }
}

struct BrowsingTextEditingState: OmniBarState {
    let showSiteRating = true
    let showEditingBackground = true
    let showClear = true
    let showMenu = false
    let showBookmarks = false
    var name: String { return Type.name(self) }
    var onEditingStoppedState: OmniBarState{ return BrowsingNonEditingState() }
    var onEditingStartedState: OmniBarState { return self }
    var onTextClearedState: OmniBarState { return BrowsingEmptyEditingState() }
    var onTextEnteredState: OmniBarState { return self }
    var onBrowsingStartedState: OmniBarState { return self }
    var onBrowsingStoppedState: OmniBarState { return HomeEmptyEditingState() }
}

struct BrowsingNonEditingState: OmniBarState {
    let showSiteRating = true
    let showEditingBackground = false
    let showClear = false
    let showMenu = true
    let showBookmarks = false
    var name: String { return Type.name(self) }
    var onEditingStoppedState: OmniBarState{ return self }
    var onEditingStartedState: OmniBarState { return BrowsingTextEditingState() }
    var onTextClearedState: OmniBarState { return BrowsingEmptyEditingState() }
    var onTextEnteredState: OmniBarState { return BrowsingTextEditingState() }
    var onBrowsingStartedState: OmniBarState { return self }
    var onBrowsingStoppedState: OmniBarState { return HomeEmptyEditingState() }
}
