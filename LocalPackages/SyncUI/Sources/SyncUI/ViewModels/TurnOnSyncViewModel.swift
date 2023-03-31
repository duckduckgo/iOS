//
//  TurnOnSyncViewModel.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

public class TurnOnSyncViewModel: ObservableObject {

    let finished: () -> Void

    public init(finished: @escaping () -> Void) {
        self.finished = finished
    }

    @Published var state: Result = .doNothing

    enum Result {

        case doNothing, turnOn, syncWithAnotherDevice, recoverData

    }

    func turnOnSyncAction() {
        state = .turnOn
    }

    func syncWithAnotherDeviceAction() {
        state = .syncWithAnotherDevice
        finished()
    }

    func notNowAction() {
        finished()
    }

    func recoverDataAction() {
        state = .recoverData
        finished()
    }

    func cancelAction() {
        state = .doNothing
        finished()
    }
    
}
