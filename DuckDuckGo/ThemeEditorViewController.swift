//
//  ThemeEditorViewController.swift
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

class ThemeEditorViewController: UITableViewController {

    var mutableTheme = MutableTheme(ThemeManager.shared.overrideTheme ?? ThemeManager.shared.currentTheme)

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerCell(ofType: ThemeEditorItemCell.self)
        tableView.registerCell(ofType: ThemeOverrideCell.self)
    }

}

// MARK: UITableView configuration
extension ThemeEditorViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : mutableTheme.colorProperties.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return tableView.dequeueCell(ofType: ThemeOverrideCell.self, for: indexPath)
        } else {
            return createThemeItemCell(tableView, for: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? nil : "Theme Colors"
    }

    func createThemeItemCell(_ tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ofType: ThemeEditorItemCell.self, for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = mutableTheme.colorProperties[indexPath.row]
        cell.contentConfiguration = config
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            toggleOverride()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

// MARK: Other logic
extension ThemeEditorViewController {

    func toggleOverride() {
        let mgr = ThemeManager.shared
        print(self, #function, mgr.overrideTheme == nil ? "enabling" : "disabling")
        mgr.overrideTheme = mgr.overrideTheme == nil ? mutableTheme : nil
        tableView.reloadRows(at: [.init(row: 0, section: 0)], with: .automatic)
    }

}


// MARK: Cells

private class ThemeOverrideCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        print(self, #function)
        var config = defaultContentConfiguration()
        config.text = "Override Theme"
        config.textProperties.color = UIColor(designSystemColor: .textPrimary)
        self.contentConfiguration = config

        if ThemeManager.shared.overrideTheme != nil {
            accessoryType = .checkmark
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

private class ThemeEditorItemCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print(self, #function)
    }

}

// MARK: Mutable Theme

class MutableTheme: Theme {

    var name: ThemeName

    var currentImageSet: ThemeManager.ImageSet

    var statusBarStyle: UIStatusBarStyle

    var keyboardAppearance: UIKeyboardAppearance

    var tabsBarBackgroundColor: UIColor

    var tabsBarSeparatorColor: UIColor

    var navigationBarTitleColor: UIColor

    var navigationBarTintColor: UIColor

    var tintOnBlurColor: UIColor

    var searchBarBackgroundColor: UIColor

    var centeredSearchBarBackgroundColor: UIColor

    var searchBarTextColor: UIColor

    var searchBarTextDeemphasisColor: UIColor

    var searchBarBorderColor: UIColor

    var searchBarClearTextIconColor: UIColor

    var searchBarVoiceSearchIconColor: UIColor

    var browsingMenuTextColor: UIColor

    var browsingMenuIconsColor: UIColor

    var browsingMenuSeparatorColor: UIColor

    var browsingMenuHighlightColor: UIColor

    var progressBarGradientDarkColor: UIColor

    var progressBarGradientLightColor: UIColor

    var autocompleteSuggestionTextColor: UIColor

    var autocompleteCellAccessoryColor: UIColor

    var tableCellSelectedColor: UIColor

    var tableCellSeparatorColor: UIColor

    var tableCellTextColor: UIColor

    var tableCellAccessoryTextColor: UIColor

    var tableCellAccessoryColor: UIColor

    var tableCellHighlightedBackgroundColor: UIColor

    var tableHeaderTextColor: UIColor

    var tabSwitcherCellBorderColor: UIColor

    var tabSwitcherCellTextColor: UIColor

    var tabSwitcherCellSecondaryTextColor: UIColor

    var iconCellBorderColor: UIColor

    var buttonTintColor: UIColor

    var placeholderColor: UIColor

    var textFieldBackgroundColor: UIColor

    var textFieldFontColor: UIColor

    var homeRowPrimaryTextColor: UIColor

    var homeRowSecondaryTextColor: UIColor

    var homeRowBackgroundColor: UIColor

    var homePrivacyCellTextColor: UIColor

    var homePrivacyCellSecondaryTextColor: UIColor

    var aboutScreenTextColor: UIColor

    var aboutScreenButtonColor: UIColor

    var favoritesPlusTintColor: UIColor

    var favoritesPlusBackgroundColor: UIColor

    var faviconBackgroundColor: UIColor

    var favoriteTextColor: UIColor

    var feedbackPrimaryTextColor: UIColor

    var feedbackSecondaryTextColor: UIColor

    var feedbackSentimentButtonBackgroundColor: UIColor

    var privacyReportCellBackgroundColor: UIColor

    var activityStyle: UIActivityIndicatorView.Style

    var destructiveColor: UIColor

    var ddgTextTintColor: UIColor

    var daxDialogBackgroundColor: UIColor

    var daxDialogTextColor: UIColor

    var homeMessageBackgroundColor: UIColor

    var homeMessageHeaderTextColor: UIColor

    var homeMessageSubheaderTextColor: UIColor

    var homeMessageTopTextColor: UIColor

    var homeMessageButtonColor: UIColor

    var homeMessageButtonTextColor: UIColor

    var homeMessageDismissButtonColor: UIColor

    var autofillDefaultTitleTextColor: UIColor

    var autofillDefaultSubtitleTextColor: UIColor

    var autofillEmptySearchViewTextColor: UIColor

    var autofillLockedViewTextColor: UIColor

    var privacyDashboardWebviewBackgroundColor: UIColor

    // swiftlint:disable function_body_length
    init(_ theme: Theme) {
        self.name = theme.name
        self.currentImageSet = theme.currentImageSet
        self.statusBarStyle = theme.statusBarStyle
        self.keyboardAppearance = theme.keyboardAppearance
        self.tabsBarBackgroundColor = theme.tabsBarBackgroundColor
        self.tabsBarSeparatorColor = theme.tabsBarSeparatorColor
        self.navigationBarTitleColor = theme.navigationBarTitleColor
        self.navigationBarTintColor = theme.navigationBarTintColor
        self.tintOnBlurColor = theme.tintOnBlurColor
        self.searchBarBackgroundColor = theme.searchBarBackgroundColor
        self.centeredSearchBarBackgroundColor = theme.centeredSearchBarBackgroundColor
        self.searchBarTextColor = theme.searchBarTextColor
        self.searchBarTextDeemphasisColor = theme.searchBarTextDeemphasisColor
        self.searchBarBorderColor = theme.searchBarBorderColor
        self.searchBarClearTextIconColor = theme.searchBarClearTextIconColor
        self.searchBarVoiceSearchIconColor = theme.searchBarVoiceSearchIconColor
        self.browsingMenuTextColor = theme.browsingMenuTextColor
        self.browsingMenuIconsColor = theme.browsingMenuIconsColor
        self.browsingMenuSeparatorColor = theme.browsingMenuSeparatorColor
        self.browsingMenuHighlightColor = theme.browsingMenuHighlightColor
        self.progressBarGradientDarkColor = theme.progressBarGradientDarkColor
        self.progressBarGradientLightColor = theme.progressBarGradientLightColor
        self.autocompleteSuggestionTextColor = theme.autocompleteSuggestionTextColor
        self.autocompleteCellAccessoryColor = theme.autocompleteCellAccessoryColor
        self.tableCellSelectedColor = theme.tableCellSelectedColor
        self.tableCellSeparatorColor = theme.tableCellSeparatorColor
        self.tableCellTextColor = theme.tableCellTextColor
        self.tableCellAccessoryTextColor = theme.tableCellAccessoryTextColor
        self.tableCellAccessoryColor = theme.tableCellAccessoryColor
        self.tableCellHighlightedBackgroundColor = theme.tableCellHighlightedBackgroundColor
        self.tableHeaderTextColor = theme.tableHeaderTextColor
        self.tabSwitcherCellBorderColor = theme.tabSwitcherCellBorderColor
        self.tabSwitcherCellTextColor = theme.tabSwitcherCellTextColor
        self.tabSwitcherCellSecondaryTextColor = theme.tabSwitcherCellSecondaryTextColor
        self.iconCellBorderColor = theme.iconCellBorderColor
        self.buttonTintColor = theme.buttonTintColor
        self.placeholderColor = theme.placeholderColor
        self.textFieldBackgroundColor = theme.textFieldBackgroundColor
        self.textFieldFontColor = theme.textFieldFontColor
        self.homeRowPrimaryTextColor = theme.homeRowPrimaryTextColor
        self.homeRowSecondaryTextColor = theme.homeRowSecondaryTextColor
        self.homeRowBackgroundColor = theme.homeRowBackgroundColor
        self.homePrivacyCellTextColor = theme.homePrivacyCellTextColor
        self.homePrivacyCellSecondaryTextColor = theme.homePrivacyCellSecondaryTextColor
        self.aboutScreenTextColor = theme.aboutScreenTextColor
        self.aboutScreenButtonColor = theme.aboutScreenButtonColor
        self.favoritesPlusTintColor = theme.favoritesPlusTintColor
        self.favoritesPlusBackgroundColor = theme.favoritesPlusBackgroundColor
        self.faviconBackgroundColor = theme.faviconBackgroundColor
        self.favoriteTextColor = theme.favoriteTextColor
        self.feedbackPrimaryTextColor = theme.feedbackPrimaryTextColor
        self.feedbackSecondaryTextColor = theme.feedbackSecondaryTextColor
        self.feedbackSentimentButtonBackgroundColor = theme.feedbackSentimentButtonBackgroundColor
        self.privacyReportCellBackgroundColor = theme.privacyReportCellBackgroundColor
        self.activityStyle = theme.activityStyle
        self.destructiveColor = theme.destructiveColor
        self.ddgTextTintColor = theme.ddgTextTintColor
        self.daxDialogBackgroundColor = theme.daxDialogBackgroundColor
        self.daxDialogTextColor = theme.daxDialogTextColor
        self.homeMessageBackgroundColor = theme.homeMessageBackgroundColor
        self.homeMessageHeaderTextColor = theme.homeMessageHeaderTextColor
        self.homeMessageSubheaderTextColor = theme.homeMessageSubheaderTextColor
        self.homeMessageTopTextColor = theme.homeMessageTopTextColor
        self.homeMessageButtonColor = theme.homeMessageButtonColor
        self.homeMessageButtonTextColor = theme.homeMessageButtonTextColor
        self.homeMessageDismissButtonColor = theme.homeMessageDismissButtonColor
        self.autofillDefaultTitleTextColor = theme.autofillDefaultTitleTextColor
        self.autofillDefaultSubtitleTextColor = theme.autofillDefaultSubtitleTextColor
        self.autofillEmptySearchViewTextColor = theme.autofillEmptySearchViewTextColor
        self.autofillLockedViewTextColor = theme.autofillLockedViewTextColor
        self.privacyDashboardWebviewBackgroundColor = theme.privacyDashboardWebviewBackgroundColor
    }
    // swiftlint:enable function_body_length

    lazy var colorProperties: [String] = {
        properties(of: UIColor.self, from: self).sorted()
    }()

    func properties<T>(of type: T.Type, from object: Any) -> [String] {
        let mirror = Mirror(reflecting: object)
        var propertyNames: [String] = []

        for child in mirror.children {
            if let childType = child.value as? T {
                propertyNames.append(child.label!)
            }
        }

        return propertyNames
    }

}
