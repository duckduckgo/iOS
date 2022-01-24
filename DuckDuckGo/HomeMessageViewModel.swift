//
//  HomeMessageViewModel.swift
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

struct HomeMessageViewModel {
    let image: String?
    let topText: String?
    let title: String
    let subtitle: String
    let buttons: [HomeMessageButtonViewModel]
    
    let onDidClose: () -> Void
}

struct HomeMessageButtonViewModel {
    enum ActionStyle {
        case `default`
        case cancel
    }
    
    let title: String
    let action: () -> Void
    var actionStyle: ActionStyle = .default
}
