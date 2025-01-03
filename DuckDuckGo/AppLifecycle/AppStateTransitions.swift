//
//  AppStateTransitions.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

import os.log
import Core

extension Init {

    func apply(event: AppEvent) -> any AppState {
        switch event {
        case .launching(let application, let isTesting):
            if isTesting {
                return Testing(application: application)
            }
            return Launched(stateContext: makeStateContext(application: application))
        default:
            return handleUnexpectedEvent(event)
        }
    }

}

extension Launched {

    mutating func apply(event: AppEvent) -> any AppState {
        switch event {
        case .activating:
            return Active(stateContext: makeStateContext())
        case .openURL(let url):
            urlToOpen = url
            return self
        case .handleShortcutItem(let shortcutItem):
            shortcutItemToHandle = shortcutItem
            return self
        case .backgrounding:
            return Background(stateContext: makeStateContext())
        case .launching, .suspending:
            return handleUnexpectedEvent(event)
        }
    }

}

extension Active {

    func apply(event: AppEvent) -> any AppState {
        switch event {
        case .suspending:
            return Inactive(stateContext: makeStateContext())
        case .openURL(let url):
            openURL(url)
            return self
        case .handleShortcutItem(let shortcutItem):
            handleShortcutItem(shortcutItem)
            return self
        case .launching, .activating, .backgrounding:
            return handleUnexpectedEvent(event)
        }
    }

}

extension Inactive {

    mutating func apply(event: AppEvent) -> any AppState {
        switch event {
        case .backgrounding:
            return Background(stateContext: makeStateContext())
        case .activating:
            return Active(stateContext: makeStateContext())
        case .openURL(let url):
            urlToOpen = url
            return self
        case .launching, .suspending, .handleShortcutItem:
            return handleUnexpectedEvent(event)
        }
    }

}

extension Background {

    mutating func apply(event: AppEvent) -> any AppState {
        switch event {
        case .activating:
            return Active(stateContext: makeStateContext())
        case .openURL(let url):
            urlToOpen = url
            return self
        case .backgrounding:
            run()
            return self
        case .handleShortcutItem(let shortcutItem):
            shortcutItemToHandle = shortcutItem
            return self
        case .launching, .suspending:
            return handleUnexpectedEvent(event)
        }
    }

}

extension Testing {

    func apply(event: AppEvent) -> any AppState { self }

}

extension AppEvent {

    var rawValue: String {
        switch self {
        case .launching: return "launching"
        case .activating: return "activating"
        case .backgrounding: return "backgrounding"
        case .suspending: return "suspending"
        case .openURL: return "openURL"
        case .handleShortcutItem: return "handleShortcutItem"
        }
    }

}

extension AppState {

    func handleUnexpectedEvent(_ event: AppEvent) -> Self {
        Logger.lifecycle.error("Invalid transition (\(event.rawValue)) for state (\(type(of: self)))")
        DailyPixel.fireDailyAndCount(pixel: .appDidTransitionToUnexpectedState,
                                     withAdditionalParameters: [PixelParameters.appState: String(describing: type(of: self)),
                                                                PixelParameters.appEvent: event.rawValue])
        return self
    }

}
