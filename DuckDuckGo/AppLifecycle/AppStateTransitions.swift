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

extension Initializing {

    func apply(event: AppEvent) -> any AppState {
        switch event {
        case .didFinishLaunching(let application, let isTesting):
            if isTesting {
                return Testing(application: application)
            }
            return Launching(stateContext: makeStateContext(application: application))
        default:
            return handleUnexpectedEvent(event)
        }
    }

}

extension Launching {

    mutating func apply(event: AppEvent) -> any AppState {
        switch event {
        case .didBecomeActive:
            return Foreground(stateContext: makeStateContext())
        case .didEnterBackground:
            return Background(stateContext: makeStateContext())
        case .openURL(let url):
            urlToOpen = url
            return self
        case .handleShortcutItem(let shortcutItem):
            shortcutItemToHandle = shortcutItem
            return self
        case .didFinishLaunching, .willResignActive, .willEnterForeground:
            return handleUnexpectedEvent(event)
        }
    }

}

extension Foreground {

    func apply(event: AppEvent) -> any AppState {
        switch event {
        case .willResignActive:
            return Suspending(stateContext: makeStateContext())
        case .openURL(let url):
            openURL(url)
            return self
        case .handleShortcutItem(let shortcutItem):
            handleShortcutItem(shortcutItem)
            return self
        case .didFinishLaunching, .didBecomeActive, .didEnterBackground, .willEnterForeground:
            return handleUnexpectedEvent(event)
        }
    }

}

extension Suspending {

    mutating func apply(event: AppEvent) -> any AppState {
        switch event {
        case .didEnterBackground:
            return Background(stateContext: makeStateContext())
        case .didBecomeActive:
            return Foreground(stateContext: makeStateContext())
        case .openURL(let url):
            urlToOpen = url
            return self
        case .handleShortcutItem(let shortcutItem):
            shortcutItemToHandle = shortcutItem
            return self
        case .didFinishLaunching, .willResignActive, .willEnterForeground:
            return handleUnexpectedEvent(event)
        }
    }

}

extension Background {

    mutating func apply(event: AppEvent) -> any AppState {
        switch event {
        case .willEnterForeground:
            return Resuming(stateContext: makeStateContext())
        case .openURL(let url):
            urlToOpen = url
            return self
        case .handleShortcutItem(let shortcutItem):
            shortcutItemToHandle = shortcutItem
            return self
        case .didFinishLaunching, .didBecomeActive, .willResignActive, .didEnterBackground:
            return handleUnexpectedEvent(event)
        }
    }

}

extension Resuming {

    mutating func apply(event: AppEvent) -> any AppState {
        switch event {
        case .didBecomeActive:
            return Foreground(stateContext: makeStateContext())
        case .didEnterBackground:
            return Background(stateContext: makeStateContext())
        case .openURL(let url):
            urlToOpen = url
            return self
        case .handleShortcutItem(let shortcutItem):
            shortcutItemToHandle = shortcutItem
            return self
        case .didFinishLaunching, .willResignActive, .willEnterForeground:
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
        case .didFinishLaunching: return "launching"
        case .didBecomeActive: return "activating"
        case .didEnterBackground: return "backgrounding"
        case .willResignActive: return "suspending"
        case .willEnterForeground: return "resuming"
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
