//
//  OmniBarState.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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
    
    var hasLargeWidth: Bool { get }
    var showBackButton: Bool { get }
    var showForwardButton: Bool { get }
    var showBookmarksButton: Bool { get }
    var showShareButton: Bool { get }
    
    var clearTextOnStart: Bool { get }
    var allowsTrackersAnimation: Bool { get }
    var showSearchLoupe: Bool { get }
    var showCancel: Bool { get }
    var showPrivacyIcon: Bool { get }
    var showBackground: Bool { get }
    var showClear: Bool { get }
    var showRefresh: Bool { get }
    var showMenu: Bool { get }
    var showSettings: Bool { get }
    var showVoiceSearch: Bool { get }
    var name: String { get }
    var onEditingStoppedState: OmniBarState { get }
    var onEditingStartedState: OmniBarState { get }
    var onTextClearedState: OmniBarState { get }
    var onTextEnteredState: OmniBarState { get }
    var onBrowsingStartedState: OmniBarState { get }
    var onBrowsingStoppedState: OmniBarState { get }
    var onEnterPhoneState: OmniBarState { get }
    var onEnterPadState: OmniBarState { get }
    var onReloadState: OmniBarState { get }
}
