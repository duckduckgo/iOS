//
//  ReaderModeOmniBarState.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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

extension OmniBarState {

    var showReaderModeButton: Bool {
        return self is ReaderModeOmniBarState
    }

    var onReaderModeAvailable: OmniBarState {
        guard !(self is ReaderModeOmniBarState) else { return self }
        return ReaderModeOmniBarState(wrappedState: self)
    }

    var onReaderModeUnavailable: OmniBarState {
        guard let readerModeState = self as? ReaderModeOmniBarState else { return self }
        return readerModeState.wrappedState
    }

}

struct ReaderModeOmniBarState: OmniBarState {

    let wrappedState: OmniBarState

    var name: String {
        "ReaderMode:" + wrappedState.name
    }

    var showShareButton: Bool {
        AppWidthObserver.shared.isLargeWidth ? wrappedState.showShareButton : false
    }

    var hasLargeWidth: Bool { wrappedState.hasLargeWidth }

    var showBackButton: Bool { wrappedState.showBackButton }

    var showForwardButton: Bool { wrappedState.showForwardButton }

    var showBookmarksButton: Bool { wrappedState.showBookmarksButton }

    var clearTextOnStart: Bool { wrappedState.clearTextOnStart }

    var allowsTrackersAnimation: Bool { wrappedState.allowsTrackersAnimation }

    var showSearchLoupe: Bool { wrappedState.showSearchLoupe }

    var showCancel: Bool { wrappedState.showCancel }

    var showSiteRating: Bool { wrappedState.showSiteRating }

    var showBackground: Bool { wrappedState.showBackground }

    var showClear: Bool { wrappedState.showClear }

    var showRefresh: Bool { wrappedState.showRefresh }

    var showMenu: Bool { wrappedState.showMenu }

    var showSettings: Bool { wrappedState.showSettings }

    var showVoiceSearch: Bool { wrappedState.showVoiceSearch }

    var onEditingStoppedState: OmniBarState {
        ReaderModeOmniBarState(wrappedState: wrappedState.onEditingStoppedState)
    }

    var onEditingStartedState: OmniBarState {
        ReaderModeOmniBarState(wrappedState: wrappedState.onEditingStartedState)
    }

    var onTextClearedState: OmniBarState {
        ReaderModeOmniBarState(wrappedState: wrappedState.onTextClearedState)
    }

    var onTextEnteredState: OmniBarState {
        ReaderModeOmniBarState(wrappedState: wrappedState.onTextEnteredState)
    }

    var onBrowsingStartedState: OmniBarState {
        ReaderModeOmniBarState(wrappedState: wrappedState.onBrowsingStartedState)
    }

    var onBrowsingStoppedState: OmniBarState {
        ReaderModeOmniBarState(wrappedState: wrappedState.onBrowsingStoppedState)
    }

    var onEnterPhoneState: OmniBarState {
        ReaderModeOmniBarState(wrappedState: wrappedState.onEnterPhoneState)
    }

    var onEnterPadState: OmniBarState {
        ReaderModeOmniBarState(wrappedState: wrappedState.onEnterPadState)
    }

    var onReloadState: OmniBarState {
        ReaderModeOmniBarState(wrappedState: wrappedState.onReloadState)
    }

}
