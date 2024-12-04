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
        case .launching(let application, let launchOptions):
            return Launched(appContext: AppContext(application: application, launchOptions: launchOptions))
        default:
            return handleUnexpectedEvent(event)
        }
    }

}

extension Launched {

    func apply(event: AppEvent) -> any AppState {
        switch event {
        case .activating:
            return Active(appContext: appContext,
                          transitionContext: TransitionContext(event: event, sourceState: self)
                          appDependencies: appDependencies)
        case .openURL(let url):
            appContext.urlToOpen = url
            return self
        case .launching, .suspending, .backgrounding:
            return handleUnexpectedEvent(event)
        }
    }

}

extension Active {

    func apply(event: AppEvent) -> any AppState {
        switch event {
        case .suspending:
            return Inactive(appContext: appContext,
                            appDependencies: appDependencies)
        case .launching, .activating, .backgrounding, .openURL:
            return handleUnexpectedEvent(event)
        }
    }

}

extension Inactive {

    func apply(event: AppEvent) -> any AppState {
        switch event {
        case .backgrounding:
            return Background(appContext: appContext,
                              appDependencies: appDependencies)
        case .activating:
            return Active(appContext: appContext,
                          transitionContext: TransitionContext(event: event, sourceState: self),
                          appDependencies: appDependencies)
        case .launching, .suspending, .openURL:
            return handleUnexpectedEvent(event)
        }
    }

}

extension Background {

    func apply(event: AppEvent) -> any AppState {
        switch event {
        case .activating:
            return Active(appContext: appContext,
                          transitionContext: TransitionContext(event: event, sourceState: self),
                          appDependencies: appDependencies)
        case .openURL(let url):
            appContext.urlToOpen = url
            return self
        case .launching, .suspending, .backgrounding:
            return handleUnexpectedEvent(event)
        }
    }

}

extension AppEvent {

    var rawValue: String {
        switch self {
        case .launching: return "launching"
        case .activating: return "activating"
        case .backgrounding: return "backgrounding"
        case .suspending: return "suspending"
        case .openURL: return "openURL"
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
