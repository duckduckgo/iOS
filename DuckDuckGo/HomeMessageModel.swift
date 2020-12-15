//
//  HomeMessageModel.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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
import UIKit

enum HomeMessage: String {
    case defaultBrowserPrompt
}

struct HomeMessageModel {
    var homeMessage: HomeMessage
    var header: String
    var subheader: String
    var topText: String
    var buttonText: String
    
    static func homeMessageModel(forHomeMessage homeMessage: HomeMessage) -> HomeMessageModel {
        switch homeMessage {
        case .defaultBrowserPrompt:
            return HomeMessageModel(homeMessage: .defaultBrowserPrompt,
                                    header: UserText.defaultBrowserHomeMessageHeader,
                                    subheader: UserText.defaultBrowserHomeMessageSubheader,
                                    topText: UserText.defaultBrowserHomeMessageTopText,
                                    buttonText: UserText.defaultBrowserHomeMessageButtonText)
        }
    }
}
