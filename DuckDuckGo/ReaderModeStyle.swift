//
//  ReaderModeStyle.swift
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
import UIKit

enum ReaderModeTheme: String {
    case light
    case dark
    case sepia

    static func preferredTheme(for theme: ReaderModeTheme? = nil) -> ReaderModeTheme {
        // If there is no reader theme provided than we default to light theme
        let readerTheme = theme ?? .light
        // Get current Firefox theme (Dark vs Normal)
        // Normal means light theme. This is the overall theme used
        // by Firefox iOS app
        let appWideTheme = ThemeManager.shared.currentTheme.name
        // We check for 3 basic themes we have Light / Dark / Sepia
        // Theme: Dark - app-wide dark overrides all
        if appWideTheme == .dark {
            return .dark
        // Theme: Sepia - special case for when the theme is sepia.
        // For this we only check the them supplied and not the app wide theme
        } else if readerTheme == .sepia {
            return .sepia
        }
        // Theme: Light - Default case for when there is no theme supplied i.e. nil and we revert to light
        return readerTheme
    }
}

private struct FontFamily {
    static let serifFamily = [ReaderModeFontType.serif, ReaderModeFontType.serifBold]
    static let sansFamily = [ReaderModeFontType.sansSerif, ReaderModeFontType.sansSerifBold]
    static let families = [serifFamily, sansFamily]
}

enum ReaderModeFontType: String {
    case serif = "serif"
    case serifBold = "serif-bold"
    case sansSerif = "sans-serif"
    case sansSerifBold = "sans-serif-bold"

    init(type: String) {
        let font = ReaderModeFontType(rawValue: type)
        let isBoldFontEnabled = UIAccessibility.isBoldTextEnabled

        switch font {
        case .serif,
             .serifBold:
            self = isBoldFontEnabled ? .serifBold : .serif
        case .sansSerif,
             .sansSerifBold:
            self = isBoldFontEnabled ? .sansSerifBold : .sansSerif
        case .none:
            self = .sansSerif
        }
    }

    func isSameFamily(_ font: ReaderModeFontType) -> Bool {
        return FontFamily.families.contains(where: { $0.contains(font) && $0.contains(self) })
    }
}

enum ReaderModeFontSize: Int {
    case size1 = 1
    case size2 = 2
    case size3 = 3
    case size4 = 4
    case size5 = 5
    case size6 = 6
    case size7 = 7
    case size8 = 8
    case size9 = 9
    case size10 = 10
    case size11 = 11
    case size12 = 12
    case size13 = 13

    func isSmallest() -> Bool {
        return self == ReaderModeFontSize.size1
    }

    func smaller() -> ReaderModeFontSize {
        if isSmallest() {
            return self
        } else {
            return ReaderModeFontSize(rawValue: self.rawValue - 1)!
        }
    }

    func isLargest() -> Bool {
        return self == ReaderModeFontSize.size13
    }

    static var defaultSize: ReaderModeFontSize {
        switch UIApplication.shared.preferredContentSizeCategory {
        case .extraSmall:
            return .size1
        case .small:
            return .size2
        case .medium:
            return .size3
        case .large:
            return .size5
        case .extraLarge:
            return .size7
        case .extraExtraLarge:
            return .size9
        case .extraExtraExtraLarge:
            return .size12
        default:
            return .size5
        }
    }

    func bigger() -> ReaderModeFontSize {
        if isLargest() {
            return self
        } else {
            return ReaderModeFontSize(rawValue: self.rawValue + 1)!
        }
    }
}

struct ReaderModeStyle {

    static let `default` = ReaderModeStyle(theme: .light, fontType: .sansSerif, fontSize: ReaderModeFontSize.defaultSize)

    var theme: ReaderModeTheme
    var fontType: ReaderModeFontType
    var fontSize: ReaderModeFontSize

    /// Encode the style to a JSON dictionary that can be passed to ReaderMode.js
    func encode() -> String {
        let dict = encodeAsDictionary()
        guard let json = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted) else { return "" }
        return String(data: json, encoding: .utf8)!
    }

    /// Encode the style to a dictionary that can be stored in the profile
    func encodeAsDictionary() -> [String: Any] {
        return ["theme": theme.rawValue, "fontType": fontType.rawValue, "fontSize": fontSize.rawValue]
    }

    init(theme: ReaderModeTheme, fontType: ReaderModeFontType, fontSize: ReaderModeFontSize) {
        self.theme = theme
        self.fontType = fontType
        self.fontSize = fontSize
    }

    /// Initialize the style from a dictionary, taken from the profile. Returns nil if the object cannot be decoded.
    init?(dict: [String: Any]) {
        let themeRawValue = dict["theme"] as? String
        let fontTypeRawValue = dict["fontType"] as? String
        let fontSizeRawValue = dict["fontSize"] as? Int
        if themeRawValue == nil || fontTypeRawValue == nil || fontSizeRawValue == nil {
            return nil
        }

        let theme = ReaderModeTheme(rawValue: themeRawValue!)
        let fontType = ReaderModeFontType(type: fontTypeRawValue!)
        let fontSize = ReaderModeFontSize(rawValue: fontSizeRawValue!)
        if theme == nil || fontSize == nil {
            return nil
        }

        self.theme = theme ?? ReaderModeTheme.preferredTheme()
        self.fontType = fontType
        self.fontSize = fontSize!
    }

    mutating func ensurePreferredColorThemeIfNeeded() {
        self.theme = ReaderModeTheme.preferredTheme(for: self.theme)
    }
}
