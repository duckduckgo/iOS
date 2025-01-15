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
            return isTesting ? Testing(application: application) : Launching(stateContext: makeStateContext(application: application))
        default:
            return handleUnexpectedEvent(event)
        }
    }

}

extension Launching {

    func apply(event: AppEvent) -> any AppState {
        switch event {
        case .didBecomeActive:
            return Foreground(stateContext: makeStateContext())
        case .didEnterBackground:
            return Background(stateContext: makeStateContext())
        default:
            return handleUnexpectedEvent(event)
        }
    }

}

extension Foreground {

    func apply(event: AppEvent) -> any AppState {
        switch event {
        case .willResignActive:
            return Suspending(stateContext: makeStateContext())
        default:
            return handleUnexpectedEvent(event)
        }
    }

}

extension Suspending {

    func apply(event: AppEvent) -> any AppState {
        switch event {
        case .didEnterBackground:
            return Background(stateContext: makeStateContext())
        case .didBecomeActive:
            return Foreground(stateContext: makeStateContext())
        default:
            return handleUnexpectedEvent(event)
        }
    }

}

extension Background {

    func apply(event: AppEvent) -> any AppState {
        switch event {
        case .willEnterForeground:
            return Resuming(stateContext: makeStateContext())
        default:
            return handleUnexpectedEvent(event)
        }
    }

}

extension Resuming {

    func apply(event: AppEvent) -> any AppState {
        switch event {
        case .didBecomeActive:
            return Foreground(stateContext: makeStateContext())
        case .didEnterBackground:
            return Background(stateContext: makeStateContext())
        default:
            return handleUnexpectedEvent(event)
        }
    }

}

extension Testing {

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
