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
        guard case .didFinishLaunching(let isTesting) = event else { return handleUnexpectedEvent(event) }
        return isTesting ? Simulated() : Launching()
    }

}

extension Launching {

    func apply(event: AppEvent) -> any AppState {
        switch event {
        case .didBecomeActive:
            let foreground = Foreground(stateContext: makeStateContext())
            foreground.onTransition()
            foreground.didReturn()
            return foreground
        case .didEnterBackground:
            let background = Background(stateContext: makeStateContext())
            background.onTransition()
            background.didReturn()
            return background
        case .willEnterForeground:
            // This event *shouldn’t* happen in the Launching state, but apparently, it does in some cases:
            // https://developer.apple.com/forums/thread/769924
            // We don’t support this transition and instead stay in Launching.
            // From here, we can move to Foreground or Background, where resuming/suspension is handled properly.
            return self
        case .willTerminate(let terminationReason):
            return Terminating(terminationReason: terminationReason)
        default:
            return handleUnexpectedEvent(event)
        }
    }

}

extension Foreground {

    func apply(event: AppEvent) -> any AppState {
        switch event {
        case .willResignActive:
            willLeave()
            return self
        case .didBecomeActive:
            didReturn()
            return self
        case .didEnterBackground:
            let background = Background(stateContext: makeStateContext())
            background.onTransition()
            background.didReturn()
            return background
        case .willTerminate(let terminationReason):
            return Terminating(terminationReason: terminationReason)
        default:
            return handleUnexpectedEvent(event)
        }
    }

}

extension Background {

    func apply(event: AppEvent) -> any AppState {
        switch event {
        case .willEnterForeground:
            willLeave()
            return self
        case .didEnterBackground:
            didReturn()
            return self
        case .didBecomeActive:
            let foreground = Foreground(stateContext: makeStateContext())
            foreground.onTransition()
            foreground.didReturn()
            return foreground
        case .willTerminate:
            return Terminating()
        default:
            return handleUnexpectedEvent(event)
        }
    }

}

extension Terminating {

    func apply(event: AppEvent) -> any AppState { self }

}


extension Simulated {

    func apply(event: AppEvent) -> any AppState { self }

}

extension AppState {

    func handleUnexpectedEvent(_ event: AppEvent) -> Self {
        Logger.lifecycle.error("🔴 Unexpected [\(String(describing: event))] event while in [\(type(of: self))] state!")
        DailyPixel.fireDailyAndCount(pixel: .appDidTransitionToUnexpectedState,
                                     withAdditionalParameters: [PixelParameters.appState: String(describing: type(of: self)),
                                                                PixelParameters.appEvent: String(describing: event)])
        return self
    }

}
