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

// swiftlint:disable file_length

import UIKit
import DesignResourcesKit
import SwiftUI

@available(iOS 16, *)
class ThemeEditorViewController: UITableViewController {

    var mutableTheme = MutableTheme(ThemeManager.shared.overrideTheme ?? ThemeManager.shared.currentTheme)

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerCell(ofType: ThemeEditorItemCell.self)
        tableView.registerCell(ofType: ThemeOverrideCell.self)
        tableView.registerCell(ofType: ThemeEditorButtonCell.self)
    }

}

// MARK: UITableView configuration
@available(iOS 16, *)
extension ThemeEditorViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : mutableTheme.colorProperties.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return createManagerCell(tableView, for: indexPath)
        } else {
            return createThemeItemCell(tableView, for: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? nil : "Theme Colors"
    }

    func createManagerCell(_ tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return tableView.dequeueCell(ofType: ThemeOverrideCell.self, for: indexPath)
        default:
            let cell = tableView.dequeueCell(ofType: ThemeEditorButtonCell.self, for: indexPath)
            var config = cell.defaultContentConfiguration()
            config.text = "Reset"
            config.textProperties.color = .destructive
            cell.contentConfiguration = config
            return cell
        }
    }

    func createThemeItemCell(_ tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ofType: ThemeEditorItemCell.self, for: indexPath)
        cell.present(themeItem: mutableTheme.colorProperties[indexPath.row], fromTheme: mutableTheme)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            onManagementCellSelected(atIndexPath: indexPath)
        } else {
            editColorAtIndex(indexPath.row)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func onManagementCellSelected(atIndexPath indexPath: IndexPath) {
        switch indexPath.row {
        case 0: toggleOverride()
        case 1: resetOverride()
        default: fatalError("Unexpected index \(indexPath)")
        }
    }

}

// MARK: Other logic
@available(iOS 16, *)
extension ThemeEditorViewController {

    func toggleOverride() {
        let mgr = ThemeManager.shared
        print(self, #function, mgr.overrideTheme == nil ? "enabling" : "disabling")
        mgr.overrideTheme = mgr.overrideTheme == nil ? mutableTheme : nil
        tableView.reloadRows(at: [.init(row: 0, section: 0)], with: .automatic)
    }

    func resetOverride() {
        print(self, #function)
        let mgr = ThemeManager.shared
        mutableTheme = MutableTheme(mgr.currentTheme)
        mgr.overrideTheme = nil
        tableView.reloadRows(at: [.init(row: 0, section: 0)], with: .automatic)
    }

    func editColorAtIndex(_ index: Int) {
        let property = mutableTheme.colorProperties[index]
        let controller = UIHostingController(rootView: ColorEditorView(controller: self, colorProperty: property))
        navigationController?.pushViewController(controller, animated: true)
    }

    func applyColor(_ color: UIColor, toProperty name: String) {
        print(#function, color, name)
        mutableTheme.setColor(color, forProperty: name)
        ThemeManager.shared.overrideTheme = mutableTheme
    }

    struct ColorEditorView: View {

        @ObservedObject var controller: ThemeEditorViewController
        let colorProperty: String

        var uiColor: UIColor? {
            controller.mutableTheme.colorForProperty(colorProperty)
        }

        var themeColor: Color {
            Color(uiColor: uiColor ?? .clear)
        }

        var body: some View {
            VStack {

                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(themeColor)
                    .frame(width: 64, height: 64)
                    .padding(.top, 16)

                Text(uiColor?.colorDescription ?? "")
                    .daxCaption()

                List {
                    Section {
                        HStack {
                            Spacer()

                            Button {
                                controller.applyColor(.red, toProperty: colorProperty)
                            } label: {
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(.red)
                                    .frame(width: 50, height: 50)
                            }
                            .buttonStyle(.borderless)

                            Spacer()

                            Button {
                                controller.applyColor(.green, toProperty: colorProperty)
                            } label: {
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(.green)
                                    .frame(width: 50, height: 50)
                            }
                            .buttonStyle(.borderless)

                            Spacer()

                            Button {
                                controller.applyColor(.blue, toProperty: colorProperty)
                            } label: {
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(.blue)
                                    .frame(width: 50, height: 50)
                            }
                            .buttonStyle(.borderless)

                            Spacer()

                            Button {
                                controller.applyColor(.yellow, toProperty: colorProperty)
                            } label: {
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(.yellow)
                                    .frame(width: 50, height: 50)
                            }
                            .buttonStyle(.borderless)

                            Spacer()
                        }
                    } header: {
                        Text("Apply color (useful for seeing in the UI)")
                            .textCase(nil)
                    }

                    Section {
                        Button {

                        } label: {
                            Text("Button")
                        }
                    } header: {
                        Text("Apply Design System color")
                            .textCase(nil)
                    }
                }

            }
            .navigationTitle(colorProperty)
        }

    }

}

@available(iOS 16, *)
extension ThemeEditorViewController: ObservableObject {

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

private class ThemeEditorButtonCell: UITableViewCell {

}

private class ThemeEditorItemCell: UITableViewCell, ObservableObject {

    @Published private var themeItem: String = ""
    @Published private var color: UIColor?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        print(self, #function)
        if #available(iOS 16, *) {
            contentConfiguration = UIHostingConfiguration {
                CellView(cell: self)
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func present(themeItem: String, fromTheme theme: MutableTheme) {
        self.themeItem = themeItem
        self.color = theme.colorForProperty(themeItem)
    }

    @available(iOS 16, *)
    struct CellView: View {

        @ObservedObject var cell: ThemeEditorItemCell

        var body: some View {
            HStack {

                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(Color(cell.color ?? .clear))
                        .frame(width: 50, height: 50)

                    if cell.color?.isDesignSystemColor == true {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .tint(.green)
                    }
                }

                VStack(alignment: .leading) {
                    Text(cell.themeItem)
                    Text(cell.color?.colorDescription ?? "")
                        .daxCaption()
                }

            }
        }
    }

}

// MARK: Mutable Theme

class MutableTheme: NSObject, Theme {

    // Not colours
    var name: ThemeName
    var currentImageSet: ThemeManager.ImageSet
    var statusBarStyle: UIStatusBarStyle
    var keyboardAppearance: UIKeyboardAppearance
    var activityStyle: UIActivityIndicatorView.Style

    // Already in design system
    @objc var omniBarBackgroundColor: UIColor
    @objc var backgroundColor: UIColor
    @objc var mainViewBackgroundColor: UIColor
    @objc var barBackgroundColor: UIColor
    @objc var barTintColor: UIColor
    @objc var browsingMenuBackgroundColor: UIColor
    @objc var tableCellBackgroundColor: UIColor
    @objc var tabSwitcherCellBackgroundColor: UIColor
    @objc var searchBarTextPlaceholderColor: UIColor

    // To be changed to design system
    @objc var tabsBarBackgroundColor: UIColor
    @objc var tabsBarSeparatorColor: UIColor
    @objc var navigationBarTitleColor: UIColor
    @objc var navigationBarTintColor: UIColor
    @objc var tintOnBlurColor: UIColor
    @objc var searchBarBackgroundColor: UIColor
    @objc var centeredSearchBarBackgroundColor: UIColor
    @objc var searchBarTextColor: UIColor
    @objc var searchBarTextDeemphasisColor: UIColor
    @objc var searchBarBorderColor: UIColor
    @objc var searchBarClearTextIconColor: UIColor
    @objc var searchBarVoiceSearchIconColor: UIColor
    @objc var browsingMenuTextColor: UIColor
    @objc var browsingMenuIconsColor: UIColor
    @objc var browsingMenuSeparatorColor: UIColor
    @objc var browsingMenuHighlightColor: UIColor
    @objc var progressBarGradientDarkColor: UIColor
    @objc var progressBarGradientLightColor: UIColor
    @objc var autocompleteSuggestionTextColor: UIColor
    @objc var autocompleteCellAccessoryColor: UIColor
    @objc var tableCellSelectedColor: UIColor
    @objc var tableCellSeparatorColor: UIColor
    @objc var tableCellTextColor: UIColor
    @objc var tableCellAccessoryTextColor: UIColor
    @objc var tableCellAccessoryColor: UIColor
    @objc var tableCellHighlightedBackgroundColor: UIColor
    @objc var tableHeaderTextColor: UIColor
    @objc var tabSwitcherCellBorderColor: UIColor
    @objc var tabSwitcherCellTextColor: UIColor
    @objc var tabSwitcherCellSecondaryTextColor: UIColor
    @objc var iconCellBorderColor: UIColor
    @objc var buttonTintColor: UIColor
    @objc var placeholderColor: UIColor
    @objc var textFieldBackgroundColor: UIColor
    @objc var textFieldFontColor: UIColor
    @objc var homeRowPrimaryTextColor: UIColor
    @objc var homeRowSecondaryTextColor: UIColor
    @objc var homeRowBackgroundColor: UIColor
    @objc var homePrivacyCellTextColor: UIColor
    @objc var homePrivacyCellSecondaryTextColor: UIColor
    @objc var aboutScreenTextColor: UIColor
    @objc var aboutScreenButtonColor: UIColor
    @objc var favoritesPlusTintColor: UIColor
    @objc var favoritesPlusBackgroundColor: UIColor
    @objc var faviconBackgroundColor: UIColor
    @objc var favoriteTextColor: UIColor
    @objc var feedbackPrimaryTextColor: UIColor
    @objc var feedbackSecondaryTextColor: UIColor
    @objc var feedbackSentimentButtonBackgroundColor: UIColor
    @objc var privacyReportCellBackgroundColor: UIColor
    @objc var destructiveColor: UIColor
    @objc var ddgTextTintColor: UIColor
    @objc var daxDialogBackgroundColor: UIColor
    @objc var daxDialogTextColor: UIColor
    @objc var homeMessageBackgroundColor: UIColor
    @objc var homeMessageHeaderTextColor: UIColor
    @objc var homeMessageSubheaderTextColor: UIColor
    @objc var homeMessageTopTextColor: UIColor
    @objc var homeMessageButtonColor: UIColor
    @objc var homeMessageButtonTextColor: UIColor
    @objc var homeMessageDismissButtonColor: UIColor
    @objc var autofillDefaultTitleTextColor: UIColor
    @objc var autofillDefaultSubtitleTextColor: UIColor
    @objc var autofillEmptySearchViewTextColor: UIColor
    @objc var autofillLockedViewTextColor: UIColor
    @objc var privacyDashboardWebviewBackgroundColor: UIColor

    // swiftlint:disable function_body_length
    init(_ theme: Theme) {
        self.name = theme.name
        self.currentImageSet = theme.currentImageSet
        self.statusBarStyle = theme.statusBarStyle
        self.keyboardAppearance = theme.keyboardAppearance
        self.omniBarBackgroundColor = theme.omniBarBackgroundColor
        self.backgroundColor = theme.backgroundColor
        self.mainViewBackgroundColor = theme.mainViewBackgroundColor
        self.barBackgroundColor = theme.barBackgroundColor
        self.barTintColor = theme.barTintColor
        self.browsingMenuBackgroundColor = theme.browsingMenuBackgroundColor
        self.tableCellBackgroundColor = theme.tableCellBackgroundColor
        self.tabSwitcherCellBackgroundColor = theme.tabSwitcherCellBackgroundColor
        self.searchBarTextPlaceholderColor = theme.searchBarTextPlaceholderColor
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

        for child in mirror.children where child.value as? T != nil {
            propertyNames.append(child.label!)
        }

        return propertyNames
    }

    func colorForProperty(_ property: String) -> UIColor? {
        let mirror = Mirror(reflecting: self)
        return mirror.children.first(where: { $0.label == property })?.value as? UIColor
    }

    func setColor(_ color: UIColor, forProperty name: String) {
        setValue(color, forKeyPath: name)
    }

}

extension UIColor {

    var hexString: String? {
        guard let cgColor = self.cgColor.converted(to: CGColorSpace(name: CGColorSpace.sRGB)!, intent: .defaultIntent, options: nil) else {
            return nil
        }

        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }

        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        let a: Float = components.count >= 4 ? Float(components[3]) : 1.0

        return String(format: "%02lX%02lX%02lX%02lX",
                      lroundf(r * 255),
                      lroundf(g * 255),
                      lroundf(b * 255),
                      lroundf(a * 255))
    }

    var isCatalogColor: Bool {
        let colorType = String(describing: type(of: self))
        return colorType == "UIDynamicCatalogColor"
    }

    var isDesignSystemColor: Bool {
        if isCatalogColor {
            let bundle = (value(forKey: "_assetManager") as AnyObject).value(forKey: "_bundle") as? Bundle
            return bundle == DesignResourcesKit.bundle
        }
        return false
    }

    var catalogName: String? {
        guard isCatalogColor else { return nil }
        return value(forKey: "name") as? String
    }

    var colorDescription: String {
        var desc = hexString ?? "<error>"

        if let name = catalogName {
            if isDesignSystemColor {
                desc += " (Design System: \(name))"
            } else {
                desc += " (Asset: \(name))"
            }
        }

        return desc
    }

}

// swiftlint:enable file_length

