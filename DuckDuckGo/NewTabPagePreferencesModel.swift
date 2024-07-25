//
//  NewTabPagePreferencesModel.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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
import SwiftUI

final class NewTabPagePreferencesModel: ObservableObject {

    /// Preferences page settings collection with bindings
    @Published private(set) var sectionsSettings: [NTPSectionSetting] = []

    /// Sections set visible for New Tab Page, ordered.
    @Published private(set) var visibleSections: [NewTabPageSection] = []

    private let newTabPagePreferencesStorage: NewTabPageSectionsPreferencesStorage

    init(newTabPagePreferencesStorage: NewTabPageSectionsPreferencesStorage) {
        self.newTabPagePreferencesStorage = newTabPagePreferencesStorage

        updatePublishedValues()
    }

    func moveSections(from: IndexSet, to: Int) {
        newTabPagePreferencesStorage.moveSections(from, toOffset: to)
        updatePublishedValues()
    }

    private func updatePublishedValues() {
        populateSectionsSettings()
        populateVisibleSections()
    }

    private func populateVisibleSections() {
        visibleSections = newTabPagePreferencesStorage.sectionsOrder.compactMap { section in
            newTabPagePreferencesStorage.isEnabled(section) ? section : nil
        }
    }

    private func populateSectionsSettings() {
        sectionsSettings = newTabPagePreferencesStorage.sectionsOrder.map { section in
            NTPSectionSetting(section: section, isEnabled: Binding(get: {
                self.newTabPagePreferencesStorage.isEnabled(section)
            }, set: { newValue in
                self.newTabPagePreferencesStorage.setSection(section, enabled: newValue)
                self.updatePublishedValues()
            }))
        }
    }
}

extension NewTabPagePreferencesModel {
    struct NTPSectionSetting {
        let section: NewTabPageSection
        let isEnabled: Binding<Bool>
    }
}
