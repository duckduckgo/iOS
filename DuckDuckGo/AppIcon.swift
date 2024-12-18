//
//  AppIcon.swift
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

enum AppIcon: String, CaseIterable {
    case red = "AppIcon-red"
    case yellow = "AppIcon-yellow"
    case green = "AppIcon-green"
    case blue = "AppIcon-blue"
    case purple = "AppIcon-purple"
    case black = "AppIcon-black"

    var accessibilityName: String {
        switch self {
        case .red: "red"
        case .yellow: "yellow"
        case .green: "green"
        case .blue: "blue"
        case .purple: "purple"
        case .black: "black"
        }
    }

    static var defaultAppIcon: AppIcon {
        return .red
    }

    var smallImage: UIImage? {
        UIImage(named: "\(rawValue)-small")
    }

    var mediumImage: UIImage? {
        UIImage(named: "\(rawValue)-medium")
    }

}
