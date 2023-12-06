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

protocol SettingsCell {
    var label: String { get set }
    var action: () -> Void { get set }
    var enabled: Bool { get set }
}

struct PlainCell: View, SettingsCell {
    
    var label: String
    var action: () -> Void = {}
    var disclosureIndicator: Bool = true
    var enabled: Bool = true
    
    var body: some View {
        Button(action: action) {
            Text(label)
        }.disabled(!enabled)
    }
}

struct RightDetailCell: View, SettingsCell {
    
    var label: String
    var value: String
    var action: () -> Void = {}
    var disclosureIndicator: Bool = true
    var enabled: Bool = true
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(label)
                Spacer()
                Text(value)
            }
        }.disabled(!enabled)
    }
}

struct ToggleCell: View, SettingsCell {
    
    var label: String
    var action: () -> Void = {}
    var disclosureIndicator: Bool = true
    var enabled: Bool = true
    @State var value: Bool = false
    
    var body: some View {
        Toggle(isOn: $value) {
            Text(label)
        }
    }
}

struct ImageCell: View, SettingsCell {
    
    var label: String
    var image: Image
    var action: () -> Void = {}
    var disclosureIndicator: Bool = true
    var enabled: Bool = true
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(label)
                Spacer()
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25) // Adjust the size as needed
            }
        }.disabled(!enabled)
    }
}

struct SubtitleCell: View, SettingsCell {
    
    var label: String
    var subtitle: String
    var action: () -> Void = {}
    var disclosureIndicator: Bool = true
    var enabled: Bool
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(label)
                Text(subtitle).font(.subheadline)
            }
            .disabled(!enabled)
        }
    }
}
