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

    @Published var editableTheme: MutableTheme!
    var referenceTheme: MutableTheme!

    override func viewDidLoad() {
        super.viewDidLoad()

        editableTheme = ThemeManager.shared.currentTheme as? MutableTheme ??
                                MutableTheme(ThemeManager.shared.currentTheme)
        referenceTheme = MutableTheme(ThemeManager.makeTheme(name: AppDependencyProvider.shared.appSettings.currentThemeName))

        loadState()

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
        return section == 0 ? 3 : editableTheme.colorProperties.count
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

        case 1:
            let cell = tableView.dequeueCell(ofType: ThemeEditorButtonCell.self, for: indexPath)
            var config = cell.defaultContentConfiguration()
            config.text = "Reset"
            config.textProperties.color = .destructive
            cell.contentConfiguration = config
            return cell

        case 2:
            let cell = tableView.dequeueCell(ofType: ThemeEditorButtonCell.self, for: indexPath)
            var config = cell.defaultContentConfiguration()
            config.text = "Share Configuration"
            cell.contentConfiguration = config
            return cell

        default: fatalError("Unknown \(indexPath)")
        }
    }

    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        if indexPath.section == 1 {
            return UISwipeActionsConfiguration(actions: [
                .init(style: .destructive, title: "Reset") {
                    let property = self.editableTheme.colorProperties[indexPath.row]
                    self.resetColor(property)
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                    $2(true)
                }
            ])
        }

        return nil
    }

    func createThemeItemCell(_ tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ofType: ThemeEditorItemCell.self, for: indexPath)
        cell.present(themeItem: editableTheme.colorProperties[indexPath.row], fromTheme: editableTheme)
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
        case 2: shareSavedState()
        default: fatalError("Unexpected index \(indexPath)")
        }
    }

    func shareSavedState() {
        saveState()
        presentShareSheet(withItems: [stateFile], fromView: self.view)
    }
}

// MARK: Other logic
@available(iOS 16, *)
extension ThemeEditorViewController {

    var stateFile: URL {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileURL = documentsDirectory!.appendingPathComponent("state.json")
        return fileURL
    }

    func resetColor(_ property: String) {
        let userTheme = ThemeManager.makeTheme(name: AppDependencyProvider.shared.appSettings.currentThemeName)
        let mutableTheme = MutableTheme(userTheme)
        if let color = mutableTheme.colorForProperty(property) {
            self.editableTheme.setColor(color, forProperty: property)
        }
    }

    func toggleOverride() {
        let mgr = ThemeManager.shared
        if mgr.currentTheme is MutableTheme {
            mgr.restoreSetting()
        } else {
            mgr.overrideSetting(editableTheme)
        }
        saveState()
        tableView.reloadRows(at: [.init(row: 0, section: 0)], with: .automatic)
    }

    struct ThemeEditorState: Codable {

        var enabled: Bool
        var colors: [String: String]

    }

    func saveState() {
        var colors = [String: String]()
        editableTheme.colorProperties.forEach {
            colors[$0] = editableTheme.colorForProperty($0)?.forSaving ?? ""
        }
        let enabled = ThemeManager.shared.currentTheme is MutableTheme
        let state = ThemeEditorState(enabled: enabled, colors: colors)
        if let data = try? JSONEncoder().encode(state) {
            let json = String(data: data, encoding: .utf8)
            print(#function, json ?? "nil", stateFile)
            try? data.write(to: stateFile)
        }
    }

    func loadState() {
        if let data = try? Data(contentsOf: stateFile),
           let state = try? JSONDecoder().decode(ThemeEditorState.self, from: data) {

            state.colors.forEach {
                let property = $0.key
                let color = $0.value.color
                applyColor(color, toProperty: property, save: false)
            }

            let mgr = ThemeManager.shared
            if state.enabled {
                mgr.overrideSetting(editableTheme)
            }
        }
    }

    func resetOverride() {
        print(self, #function)
        let mgr = ThemeManager.shared
        mgr.restoreSetting()
        editableTheme = MutableTheme(mgr.currentTheme)
        tableView.reloadData()
        objectWillChange.send()
        saveState()
    }

    func editColorAtIndex(_ index: Int) {
        let property = editableTheme.colorProperties[index]
        let controller = UIHostingController(rootView: ColorEditorView(controller: self, colorProperty: property))
        navigationController?.pushViewController(controller, animated: true)
    }

    func applyColor(_ color: UIColor, toProperty name: String, save: Bool = true) {
        let mgr = ThemeManager.shared

        guard editableTheme.colorProperties.contains(name) else { return }

        editableTheme.setColor(color, forProperty: name)
        if mgr.currentTheme is MutableTheme {
            mgr.overrideSetting(editableTheme)
        }
        tableView.reloadData()
        objectWillChange.send()

        if save {
            saveState()
        }
    }

    struct DesignSystemColorItem {

        let color: UIColor
        let name: String

    }

    struct ColorEditorView: View {

        @ObservedObject var controller: ThemeEditorViewController
        let colorProperty: String

        var uiColor: UIColor? {
            controller.editableTheme.colorForProperty(colorProperty)
        }

        var themeColor: Color {
            Color(uiColor: uiColor ?? .clear)
        }

        var designSystemColors: [DesignSystemColorItem] = [
            .init(color: UIColor(designSystemColor: .accent), name: "accent"),
            .init(color: UIColor(designSystemColor: .background), name: "background"),
            .init(color: UIColor(designSystemColor: .container), name: "container"),
            .init(color: UIColor(designSystemColor: .icons), name: "icons"),
            .init(color: UIColor(designSystemColor: .lines), name: "lines"),
            .init(color: UIColor(designSystemColor: .panel), name: "panel"),
            .init(color: UIColor(designSystemColor: .surface), name: "surface"),
            .init(color: UIColor(designSystemColor: .textPrimary), name: "textPrimary"),
            .init(color: UIColor(designSystemColor: .textSecondary), name: "textSecondary"),
        ]

        @ViewBuilder func currentColorSection() -> some View {
            VStack {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(themeColor)
                    .frame(width: 64, height: 64)
                    .padding(.top, 16)

                Text(uiColor?.colorDescription ?? "")
                    .daxCaption()
            }
        }

        @ViewBuilder func primaryColorSection() -> some View {
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
        }

        @ViewBuilder func designSystemColorSection() -> some View {
            Section {

                ForEach(designSystemColors, id: \.name) { item in
                    Button {
                        controller.applyColor(item.color, toProperty: colorProperty)
                    } label: {
                        HStack {

                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(Color(item.color))
                                .frame(width: 50, height: 50)

                            Text(item.name)

                        }
                    }
                }


            } header: {
                Text("Apply Design System color")
                    .textCase(nil)
            }
        }

        var body: some View {
            VStack {

                currentColorSection()

                List {
                    primaryColorSection()

                    designSystemColorSection()
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
        var config = defaultContentConfiguration()
        config.text = "Override Theme"
        config.textProperties.color = UIColor(designSystemColor: .textPrimary)
        self.contentConfiguration = config

        if ThemeManager.shared.currentTheme is MutableTheme {
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

    weak var theme: MutableTheme!
    let reference = MutableTheme(ThemeManager.makeTheme(name: AppDependencyProvider.shared.appSettings.currentThemeName))

    var isAssigned: Bool {
        return reference.colorForProperty(themeItem) != theme.colorForProperty(themeItem)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
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
        self.theme = theme
        self.themeItem = themeItem
        self.color = theme.colorForProperty(themeItem)
    }

    @available(iOS 16, *)
    struct CellView: View {

        @ObservedObject var cell: ThemeEditorItemCell

        var body: some View {
            HStack {

                ZStack(alignment: .bottomTrailing) {
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(Color(cell.color ?? .clear))
                        .frame(width: 50, height: 50)

                    if cell.isAssigned {
                        Circle()
                            .fill(.orange)
                            .frame(width: 12, height: 12)
                            .padding(4)
                    } else if cell.color?.isDesignSystemColor == true {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .tint(.green)
                            .padding(2)
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
    @objc var searchBarBackgroundColor: UIColor
    @objc var searchBarTextColor: UIColor
    @objc var searchBarTextDeemphasisColor: UIColor
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
    @objc var faviconBackgroundColor: UIColor
    @objc var favoriteTextColor: UIColor
    @objc var feedbackPrimaryTextColor: UIColor
    @objc var feedbackSecondaryTextColor: UIColor
    @objc var feedbackSentimentButtonBackgroundColor: UIColor
    @objc var destructiveColor: UIColor
    @objc var ddgTextTintColor: UIColor
    @objc var daxDialogBackgroundColor: UIColor
    @objc var daxDialogTextColor: UIColor
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
        self.searchBarBackgroundColor = theme.searchBarBackgroundColor
        self.searchBarTextColor = theme.searchBarTextColor
        self.searchBarTextDeemphasisColor = theme.searchBarTextDeemphasisColor
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
//        self.favoritesPlusTintColor = theme.favoritesPlusTintColor
//        self.favoritesPlusBackgroundColor = theme.favoritesPlusBackgroundColor
        self.faviconBackgroundColor = theme.faviconBackgroundColor
        self.favoriteTextColor = theme.favoriteTextColor
        self.feedbackPrimaryTextColor = theme.feedbackPrimaryTextColor
        self.feedbackSecondaryTextColor = theme.feedbackSecondaryTextColor
        self.feedbackSentimentButtonBackgroundColor = theme.feedbackSentimentButtonBackgroundColor
        self.activityStyle = theme.activityStyle
        self.destructiveColor = theme.destructiveColor
        self.ddgTextTintColor = theme.ddgTextTintColor
        self.daxDialogBackgroundColor = theme.daxDialogBackgroundColor
        self.daxDialogTextColor = theme.daxDialogTextColor
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

    convenience init?(alphaHex: String) {
        var hexSanitized = alphaHex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        hexSanitized = hexSanitized.replacingOccurrences(of: "0x", with: "")

        var rgb: UInt64 = 0

        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        if hexSanitized.count == 6 {
            let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            let blue = CGFloat(rgb & 0x0000FF) / 255.0
            self.init(red: red, green: green, blue: blue, alpha: 1.0)
            return
        } else if hexSanitized.count == 8 {
            let red = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            let green = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            let blue = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            let alpha = CGFloat(rgb & 0x000000FF) / 255.0
            self.init(red: red, green: green, blue: blue, alpha: alpha)
            return
        } else {
            return nil
        }
    }

    var forSaving: String {
        if isCatalogColor,
            let bundle = (value(forKey: "_assetManager") as AnyObject).value(forKey: "_bundle") as? Bundle {
            return "\(bundle.name ?? "").\(catalogName ?? "")"
        } else {
            return hexString ?? ""
        }
    }

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

private extension String {

    var color: UIColor {
        let components = self.components(separatedBy: ".")
        if components.count > 1 {
            if components[0] == DesignResourcesKit.bundle.name {
                return UIColor(named: components[1], in: DesignResourcesKit.bundle, compatibleWith: nil)!
            } else {
                return UIColor(named: components[1])!
            }
        } else {
            return UIColor(alphaHex: self)!
        }
    }

}

// swiftlint:enable file_length
