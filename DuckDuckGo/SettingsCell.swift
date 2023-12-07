//
//  SettingsCell.swift
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

import SwiftUI

/// Encapsulates a View representing a Cell with different configurations
struct SettingsCellView: View, Identifiable {
    
    enum Accesory {
        case none
        case rightDetail(String)
        case toggle(isOn: Binding<Bool>)
        case image(Image)
        case subtitle(String)
        case custom(AnyView)
    }
    
    var label: String
    var action: () -> Void = {}
    var enabled: Bool = true
    var accesory: Accesory
    var asLink: Bool
    var disclosureIndicator: Bool
    var id: UUID = UUID()
    
    /// Initializes a `SettingsCellView` with the specified label and accesory.
    ///
    /// Use this initializer for standard cell types that require a label.
    /// - Parameters:
    ///   - label: The text to display in the cell.
    ///   - action: The closure to execute when the view is tapped. (If not embedded in a NavigationLink)
    ///   - accesory: The type of cell to display. Excludes the custom cell type.
    ///   - enabled: A Boolean value that determines whether the cell is enabled.
    ///   - asLink: Wraps the view inside a Button.  Used for views not wrapped in a NavigationLink
    ///   - disclosureIndicator: Forces Adds a disclosure indicator on the right (chevron)
    init(label: String, action: @escaping () -> Void = {}, accesory: Accesory = .none, enabled: Bool = true, asLink: Bool = false, disclosureIndicator: Bool = false) {
        self.label = label
        self.action = action
        self.enabled = enabled
        self.accesory = accesory
        self.asLink = asLink
        self.disclosureIndicator = disclosureIndicator
    }

    /// Initializes a `SettingsCellView` for custom content.
    ///
    /// Use this initializer for creating a cell that displays custom content.
    /// This initializer does not require a label, as the content is entirely custom.
    /// - Parameters:
    ///   - action: The closure to execute when the view is tapped. (If not embedded in a NavigationLink)    
    ///   - customView: A closure that returns the custom view (`AnyView`) to be displayed in the cell.
    ///   - enabled: A Boolean value that determines whether the cell is enabled.
    init(action: @escaping () -> Void = {}, @ViewBuilder customView: () -> AnyView, enabled: Bool = true) {
        self.label = "" // Not used for custom cell
        self.action = action
        self.enabled = enabled
        self.accesory = .custom(customView())
        self.asLink = false
        self.disclosureIndicator = false
    }
    
    var body: some View {
        Group {
            switch accesory {
            case .custom(let customView):
                Button(action: action) { customView }
                    .buttonStyle(.plain)
                    .disabled(!enabled)

            default:
                if asLink {
                    Button(action: action) { defaultView }
                        .buttonStyle(.plain)
                } else {
                    defaultView
                }
            }
        }
    }
    
    private var defaultView: some View {
        Group {
            HStack {
                Text(label)
                Spacer()
                cellView()
                if disclosureIndicator {
                    Image(systemName: "chevron.forward")
                        .font(Font.system(.footnote).weight(.bold))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                }
            }
        }.contentShape(Rectangle())
    }
    
    @ViewBuilder
    private func cellView() -> some View {
        switch accesory {
        case .none:
            EmptyView()
        case .rightDetail(let value):
            Text(value).foregroundColor(Color(UIColor.tertiaryLabel))
        case .toggle(let isOn):
            Toggle("", isOn: isOn)
        case .image(let image):
            image
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
        case .subtitle(let subtitle):
            Text(subtitle).font(.subheadline)
        case .custom(let customView):
            customView
        }
    }
}

/// Encapsulates a Picker with options derived from a generic type that conforms to CustomStringConvertible.
struct SettingsPickerCellView<T: CaseIterable & Hashable & CustomStringConvertible>: View {
    let label: String
    let options: [T]
    @Binding var selectedOption: T
    
    /// Initializes a SettingsPickerCellView.
    /// - Parameters:
    ///   - label: The label to display above the Picker.
    ///   - options: An array of options of generic type `T` that conforms to CustomStringConvertible.
    ///   - selectedOption: A binding to a state variable that represents the selected option.
    init(label: String, options: [T], selectedOption: Binding<T>) {
        self.label = label
        self.options = options
        self._selectedOption = selectedOption
    }

    var body: some View {
        Picker(label, selection: $selectedOption) {
            ForEach(options, id: \.self) { option in
                Text(option.description).tag(option)
            }
        .pickerStyle(MenuPickerStyle())
        }
    }
}
