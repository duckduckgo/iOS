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
        case custom(AnyView)
    }
    
    var label: String
    var subtitle: String?
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
    ///   - subtitle: Displayed below title (if present)
    ///   - action: The closure to execute when the view is tapped. (If not embedded in a NavigationLink)
    ///   - accesory: The type of cell to display. Excludes the custom cell type.
    ///   - enabled: A Boolean value that determines whether the cell is enabled.
    ///   - asLink: Wraps the view inside a Button.  Used for views not wrapped in a NavigationLink
    ///   - disclosureIndicator: Forces Adds a disclosure indicator on the right (chevron)
    init(label: String, subtitle: String? = nil, action: @escaping () -> Void = {}, accesory: Accesory = .none, enabled: Bool = true, asLink: Bool = false, disclosureIndicator: Bool = false) {
        self.label = label
        self.subtitle = subtitle
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
                
                VStack(alignment: .leading) {
                    Text(label)
                    if let subtitleText = subtitle {
                        Text(subtitleText).font(.subheadline)
                            .foregroundColor(Color(UIColor.secondaryLabel))
                    }
                }.fixedSize(horizontal: false, vertical: true)
                    .layoutPriority(0.7)
                
                Spacer()
                
                accesoryView()
                
                if disclosureIndicator {
                    Image(systemName: "chevron.forward")
                        .font(Font.system(.footnote).weight(.bold))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                        .padding(.leading, 8)
                }
            }
        }.contentShape(Rectangle())
    }
    
    @ViewBuilder
    private func accesoryView() -> some View {
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


/// A simple settings cell that can act as a link and include a disclosure indicator
struct SettingsCustomCell<Content: View>: View {
    var content: Content
    var action: () -> Void
    var asLink: Bool
    var disclosureIndicator: Bool

    /// Initializes a `SettingsCustomCell`.
    /// - Parameters:
    ///   - content: A SwiftUI View to be displayed in the cell.
    ///   - action: The closure to execute when the view is tapped.
    ///   - asLink: A Boolean value that determines if the cell behaves like a link.
    ///   - disclosureIndicator: A Boolean value that determines if the cell shows a disclosure indicator.
    init(@ViewBuilder content: () -> Content, action: @escaping () -> Void = {}, asLink: Bool = false, disclosureIndicator: Bool = false) {
        self.content = content()
        self.action = action
        self.asLink = asLink
        self.disclosureIndicator = disclosureIndicator
    }

    var body: some View {
        HStack {
            content
            
            Spacer()

            Image(systemName: "chevron.forward")
                .font(Font.system(.footnote).weight(.bold))
                .foregroundColor(Color(UIColor.tertiaryLabel))
                .padding(.leading, 8)
        }
        .onTapGesture(perform: action)
    }
}


struct SettingsCellView_Previews: PreviewProvider {
    enum SampleOption: String, CaseIterable, Hashable, CustomStringConvertible {
        case optionOne = "Lorem"
        case optionTwo = "Ipsum"
        case optionThree = "Dolor"

        var description: String {
            return self.rawValue
        }
    }
    
    static var previews: some View {
        Group {
            List {
                SettingsCellView(label: "Nulla commodo augue nec",
                                 asLink: true,
                                 disclosureIndicator: true)
                    .previewLayout(.sizeThatFits)
                
                SettingsCellView(label: "Nulla commodo augue nec",
                                 subtitle: "Curabitur erat massa, cursus sed velit",
                                 asLink: true,
                                 disclosureIndicator: true)
                    .previewLayout(.sizeThatFits)
                
                SettingsCellView(label: "Maecenas ac purus",
                                 accesory: .image(Image(systemName: "person.circle")),
                                 asLink: true,
                                 disclosureIndicator: true)
                    .previewLayout(.sizeThatFits)
                
                SettingsCellView(label: "Maecenas ac purus",
                                 subtitle: "Curabitur erat massa",
                                 accesory: .image(Image(systemName: "person.circle")),
                                 asLink: true,
                                 disclosureIndicator: true)
                    .previewLayout(.sizeThatFits)
                
                SettingsCellView(label: "Curabitur erat",
                                 accesory: .rightDetail("Curabi"),
                                 asLink: true,
                                 disclosureIndicator: true)
                    .previewLayout(.sizeThatFits)

                SettingsCellView(label: "Curabitur erat",
                                 subtitle: "Nulla commodo augue",
                                 accesory: .rightDetail("Aagittis"),
                                 asLink: true,
                                 disclosureIndicator: true)
                    .previewLayout(.sizeThatFits)
                
                SettingsCellView(label: "Proin tempor urna",
                                 accesory: .toggle(isOn: .constant(true)),
                                 asLink: false,
                                 disclosureIndicator: false)
                    .previewLayout(.sizeThatFits)
                
                SettingsCellView(label: "Proin tempor urna",
                                 subtitle: "Fusce elementum quis",
                                 accesory: .toggle(isOn: .constant(true)),
                                 asLink: false,
                                 disclosureIndicator: false)
                    .previewLayout(.sizeThatFits)
                
                @State var selectedOption: SampleOption = .optionOne
                SettingsPickerCellView(label: "Proin tempor urna", options: SampleOption.allCases, selectedOption: $selectedOption)
                    .previewLayout(.sizeThatFits)
                
                SettingsCustomCell(content: {
                    HStack(spacing: 15) {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.orange)
                            .imageScale(.large)

                        VStack(alignment: .leading) {
                            Text("Notifications")
                                .font(.headline)
                            Text("Manage alerts and sounds")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }, disclosureIndicator: true)
                .previewLayout(.sizeThatFits)

                               
            }
        }
    }
}
