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
import DesignResourcesKit

struct SettingsCellComponents {
    static var chevron: some View {
        Image(systemName: "chevron.forward")
            .font(Font.system(.footnote).weight(.bold))
            .foregroundColor(Color(UIColor.tertiaryLabel))
    }
}
/// Encapsulates a View representing a Cell with different configurations
struct SettingsCellView: View, Identifiable {
    
    enum Accessory {
        case none
        case rightDetail(String)
        case toggle(isOn: Binding<Bool>)
        case image(Image)
        case custom(AnyView)
    }
    
    var label: String
    var subtitle: String?
    var image: Image?
    var action: () -> Void = {}
    var enabled: Bool = true
    var accesory: Accessory
    var asLink: Bool
    var disclosureIndicator: Bool
    var id: UUID = UUID()
    
    /// Initializes a `SettingsCellView` with the specified label and accesory.
    ///
    /// Use this initializer for standard cell types that require a label.
    /// - Parameters:
    ///   - label: The text to display in the cell.
    ///   - subtitle: Displayed below title (if present)
    ///   - image: Image displayed to the left of label
    ///   - action: The closure to execute when the view is tapped. (If not embedded in a NavigationLink)
    ///   - accesory: The type of cell to display. Excludes the custom cell type.
    ///   - enabled: A Boolean value that determines whether the cell is enabled.
    ///   - asLink: Wraps the view inside a Button.  Used for views not wrapped in a NavigationLink
    ///   - disclosureIndicator: Forces Adds a disclosure indicator on the right (chevron)
    init(label: String, subtitle: String? = nil, image: Image? = nil, action: @escaping () -> Void = {}, accesory: Accessory = .none, enabled: Bool = true, asLink: Bool = false, disclosureIndicator: Bool = false) {
        self.label = label
        self.subtitle = subtitle
        self.image = image
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
        if asLink {
            Button(action: action) {
                cellContent
                .disabled(!enabled)
            }
            .buttonStyle(PlainButtonStyle())
            .contentShape(Rectangle())
        } else {
            cellContent
        }
    }
    
    private var cellContent: some View {
        Group {
            switch accesory {
            case .custom(let customView):
                customView
            default:
                defaultView
            }
        }
    }
    
    private var defaultView: some View {
        Group {
            HStack {
                if let image {
                    image
                }
                VStack(alignment: .leading) {
                    Text(label)
                        .daxBodyRegular()
                        .foregroundColor(Color(designSystemColor: .textPrimary))
                    if let subtitleText = subtitle {
                        Text(subtitleText)
                            .daxFootnoteRegular()
                            .foregroundColor(Color(designSystemColor: .textSecondary))
                    }
                }.fixedSize(horizontal: false, vertical: true)
                    .layoutPriority(0.7)
                
                Spacer()
                
                accesoryView()
                
                if disclosureIndicator {
                    SettingsCellComponents.chevron
                }
            }.padding(EdgeInsets(top: 2, leading: 0, bottom: 2, trailing: 0))
        }.contentShape(Rectangle())
    }
    
    @ViewBuilder
    private func accesoryView() -> some View {
        switch accesory {
        case .none:
            EmptyView()
        case .rightDetail(let value):
            Text(value)
                .daxSubheadRegular()
                .foregroundColor(Color(designSystemColor: .textSecondary))
                .layoutPriority(1)
        case .toggle(let isOn):
            Toggle("", isOn: isOn)
                .toggleStyle(SwitchToggleStyle(tint: Color(designSystemColor: .accent)))
        case .image(let image):
            image
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                .cornerRadius(4)
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
    /// Use a custom picker that mimics the MenuPickerStyle
    /// But with specific design
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
        HStack {
            Text(label)
                .daxBodyRegular()
                .foregroundColor(Color(designSystemColor: .textPrimary))
            Spacer()
            Menu {
                ForEach(options, id: \.self) { option in
                    Group {
                        getButtonWithAction(action: { self.selectedOption = option },
                                            option: option.description,
                                            selected: option == selectedOption)
                    }
                }
            } label: {
                HStack {
                    Text(selectedOption.description)
                        .daxSubheadRegular()
                        .foregroundColor(Color(designSystemColor: .textSecondary))
                    Image(systemName: "chevron.up.chevron.down")
                        .font(Font.system(.footnote).weight(.bold))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                        .padding(.trailing, -2)
                }
            }
        }
    }
    
    private func getButtonWithAction(action: @escaping () -> Void,
                                     option: String,
                                     selected: Bool) -> some View {
        return Group {
            Button(action: action) {
                HStack {
                    if selected {
                        Image(systemName: "checkmark")
                    }
                    Text(option)
                }
            }
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
        if asLink {
            Button(action: action) {
                cellContent
            }
            .buttonStyle(PlainButtonStyle())
            .contentShape(Rectangle())
        } else {
            cellContent
        }
    }

    
    private var cellContent: some View {
        HStack {
            content
            Spacer()
            if disclosureIndicator {
                SettingsCellComponents.chevron
            }
        }
    }
}

#if DEBUG
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
                
                SettingsCellView(label: "Proin tempor urna",
                                 subtitle: "Fusce elementum quis",
                                 accesory: .toggle(isOn: .constant(true)),
                                 asLink: false,
                                 disclosureIndicator: false)
                    .previewLayout(.sizeThatFits)
                
                let cellContent: () -> some View = {
                    HStack(spacing: 15) {
                        Image(systemName: "hand.wave")
                            .foregroundColor(.orange)
                            .imageScale(.large)
                        Image(systemName: "hand.wave")
                            .foregroundColor(.orange)
                            .imageScale(.medium)
                      
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("LOREM IPSUM")
                                .font(.headline)
                        }
                        Spacer()
                        Image(systemName: "hand.wave")
                            .foregroundColor(.orange)
                            .imageScale(.medium)
                        Image(systemName: "hand.wave")
                            .foregroundColor(.orange)
                            .imageScale(.large)
                    }
                }
                // For some unknown reason, this breaks on CI, but works normally
                // Perhaps an XCODE version issue?
                // SettingsCustomCell(content: cellContent)
                    // .previewLayout(.sizeThatFits)

                               
            }
        }
    }
}
#endif
