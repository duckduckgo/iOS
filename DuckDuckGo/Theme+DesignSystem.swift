//
//  Theme+DesignSystem.swift
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

import UIKit
import DesignResourcesKit

// Once all colours are from the design system we can consider removing having multiple themes.
extension Theme {

    var omniBarBackgroundColor: UIColor { UIColor(designSystemColor: .panel) }
    var backgroundColor: UIColor { UIColor(designSystemColor: .background) }
    var mainViewBackgroundColor: UIColor { UIColor(designSystemColor: .background) }
    var barBackgroundColor: UIColor { UIColor(designSystemColor: .panel) }
    var barTintColor: UIColor { UIColor(designSystemColor: .icons) }
    var browsingMenuBackgroundColor: UIColor { UIColor(designSystemColor: .surface) }
    var tableCellBackgroundColor: UIColor { UIColor(designSystemColor: .surface) }
    var tabSwitcherCellBackgroundColor: UIColor { UIColor(designSystemColor: .surface) }
    var searchBarTextPlaceholderColor: UIColor { UIColor(designSystemColor: .textSecondary) }

    // New:
    var autocompleteCellAccessoryColor: UIColor { UIColor(designSystemColor: .icons) }

    var autofillDefaultTitleTextColor: UIColor { UIColor(designSystemColor: .textPrimary) }
    var autofillDefaultSubtitleTextColor: UIColor { UIColor(designSystemColor: .textSecondary) }
    var autofillEmptySearchViewTextColor: UIColor { UIColor(designSystemColor: .textPrimary) }
    var autofillLockedViewTextColor: UIColor { UIColor(designSystemColor: .textPrimary) }

    var ddgTextTintColor: UIColor { UIColor(designSystemColor: .textPrimary) }

    var privacyDashboardWebviewBackgroundColor: UIColor { UIColor(designSystemColor: .surface) }

    var iconCellBorderColor: UIColor { UIColor(designSystemColor: .icons) }

    var browsingMenuTextColor: UIColor { UIColor(designSystemColor: .textPrimary) }
    var browsingMenuIconsColor: UIColor { UIColor(designSystemColor: .textPrimary) }
    var browsingMenuSeparatorColor: UIColor { UIColor(designSystemColor: .lines) }

    var feedbackSentimentButtonBackgroundColor: UIColor { UIColor(designSystemColor: .surface) }

    var aboutScreenButtonColor: UIColor { UIColor(designSystemColor: .accent) }

    var tabSwitcherCellBorderColor: UIColor { UIColor(designSystemColor: .surface) }
    var tabSwitcherCellTextColor: UIColor { UIColor(designSystemColor: .textPrimary) }
    var tabSwitcherCellSecondaryTextColor: UIColor { UIColor(designSystemColor: .textSecondary) }

    var textFieldFontColor: UIColor { UIColor(designSystemColor: .textPrimary) }
    var textFieldBackgroundColor: UIColor { UIColor(designSystemColor: .surface) }

    var buttonTintColor: UIColor { UIColor(designSystemColor: .accent) }

    var feedbackPrimaryTextColor: UIColor { UIColor(designSystemColor: .textPrimary) }
    var feedbackSecondaryTextColor: UIColor { UIColor(designSystemColor: .textSecondary) }

    var progressBarGradientDarkColor: UIColor { UIColor(designSystemColor: .accent) }
    var progressBarGradientLightColor: UIColor { UIColor(designSystemColor: .accent) }

    var daxDialogBackgroundColor: UIColor { UIColor(designSystemColor: .surface) }
    var daxDialogTextColor: UIColor { UIColor(designSystemColor: .textPrimary) }

    var placeholderColor: UIColor { UIColor(designSystemColor: .textSecondary) }
    var searchBarTextColor: UIColor { UIColor(designSystemColor: .textPrimary) }

    var navigationBarTitleColor: UIColor { UIColor(designSystemColor: .textPrimary) }
    var tableHeaderTextColor: UIColor {UIColor(designSystemColor: .textSecondary) }

    var faviconBackgroundColor: UIColor { UIColor(designSystemColor: .surface) }

    var favoriteTextColor: UIColor { UIColor(designSystemColor: .textSecondary) }
    var aboutScreenTextColor: UIColor { UIColor(designSystemColor: .textPrimary) }
    var autocompleteSuggestionTextColor: UIColor { UIColor(designSystemColor: .textPrimary) }

    var tableCellTextColor: UIColor { UIColor(designSystemColor: .textPrimary) }
    var tableCellSeparatorColor: UIColor { UIColor(designSystemColor: .lines) }

    // No design system colour yet, so fall back to SDK colours
    var tableCellAccessoryTextColor: UIColor { .secondaryLabel }

}
