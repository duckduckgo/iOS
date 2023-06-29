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
import BrowserServicesKit

struct HomeMessageViewModel: Equatable {
    enum ButtonAction {
        case close
        case primaryAction
        case secondaryAction
    }

    let messageId: String
    let image: String?
    let topText: String?
    let title: String
    let subtitle: String
    let buttons: [HomeMessageButtonViewModel]
    
    let onDidClose: (ButtonAction?, RemoteAction) -> Void
    let onDidAppear: () -> Void

    var hasSharing: Bool {
        for button in buttons {
            if case .share = button.actionStyle {
                return true
            }
        }
        return false
    }

    static func == (lhs: HomeMessageViewModel, rhs: HomeMessageViewModel) -> Bool {
        return lhs.image == rhs.image &&
               lhs.topText == rhs.topText &&
               lhs.title == rhs.title &&
               lhs.subtitle == rhs.subtitle &&
               lhs.buttons == rhs.buttons
    }
}

struct HomeMessageButtonViewModel: Equatable {
    enum ActionStyle: Equatable {
        case `default`
        case share(url: URL, title: String)
        case cancel
    }
    
    let title: String
    var actionStyle: ActionStyle = .default
    let action: () -> Void

    static func == (lhs: HomeMessageButtonViewModel, rhs: HomeMessageButtonViewModel) -> Bool {
        return lhs.title == rhs.title &&
               lhs.actionStyle == rhs.actionStyle
    }
}
