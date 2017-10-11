//
//  UIFontExtension.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

extension UIFont {
    
    private enum Name: String {
        case ProximaNovaRegular = "ProximaNova-Regular"
        case ProximaNovaLight = "ProximaNova-Light"
        case ProximaNovaSemibold = "ProximaNova-Semibold"
        case ProximaNovaBold = "ProximaNova-Bold"
    }

    public static func appFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: Name.ProximaNovaRegular.rawValue, size: size) ??
               UIFont.systemFont(ofSize: size)
    }
    
    public static func lightAppFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: Name.ProximaNovaLight.rawValue, size: size) ??
               UIFont.systemFont(ofSize: size, weight: UIFont.Weight.light)
    }

    public static func semiBoldAppFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: Name.ProximaNovaSemibold.rawValue, size: size) ??
               UIFont.systemFont(ofSize: size, weight: UIFont.Weight.semibold)
    }
    
    public static func boldAppFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: Name.ProximaNovaBold.rawValue, size: size) ??
               UIFont.boldSystemFont(ofSize: size)
    }
}
