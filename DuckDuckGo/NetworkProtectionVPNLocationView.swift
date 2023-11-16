//
//  NetworkProtectionVPNLocationView.swift
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

#if NETWORK_PROTECTION

import Foundation
import SwiftUI

@available(iOS 15, *)
struct NetworkProtectionVPNLocationView: View {
    @StateObject var model = NetworkProtectionVPNLocationViewModel()

    var body: some View {
        List {
            switch model.state {
            case .loading:
                EmptyView()
            case .loaded(let isNearestSelected, let countryItems):
                nearest(isSelected: isNearestSelected)
                countries(itemModels: countryItems)
                    .animation(.default, value: countryItems.isEmpty)
            }
        }
        .applyInsetGroupedListStyle()
        .navigationTitle(UserText.netPVPNLocationTitle)
        .onAppear {
            Task {
                await model.onViewAppeared()
            }
        }
    }

    @ViewBuilder
    private func nearest(isSelected: Bool) -> some View {
        Section {
            ChecklistItem(
                isSelected: isSelected,
                action: {
                    Task {
                        await model.onNearestItemSelection()
                    }
                }, label: {
                    Text(UserText.netPPreferredLocationNearest)
                        .foregroundStyle(Color.textPrimary)
                        .font(.system(size: 16))
                }
            )
        } header: {
            Text(UserText.netPVPNLocationRecommendedSectionTitle)
        } footer: {
            Text(UserText.netPVPNLocationRecommendedSectionFooter)
                .foregroundColor(.textSecondary)
                .font(.system(size: 13))
                .padding(.top, 6)
        }
    }

    @ViewBuilder
    private func countries(itemModels: [NetworkProtectionVPNCountryItemModel]) -> some View {
        Section {
            ForEach(itemModels) { item in
                CountryItem(itemModel: item) {
                    Task {
                        await model.onCountryItemSelection(id: item.id)
                    }
                } cityPickerAction: { cityId in
                    Task {
                        await model.onCountryItemSelection(id: item.id, cityId: cityId)
                    }
                }

            }
        } header: {
            Text(UserText.netPVPNLocationAllCountriesSectionTitle)
        }
    }
}

@available(iOS 15, *)
private struct CountryItem: View {
    let itemModel: NetworkProtectionVPNCountryItemModel
    let action: () -> Void
    let cityPickerAction: (String?) -> Void

    init(itemModel: NetworkProtectionVPNCountryItemModel, action: @escaping () -> Void, cityPickerAction: @escaping (String?) -> Void) {
        self.itemModel = itemModel
        self.action = action
        self.cityPickerAction = cityPickerAction
    }

    var body: some View {
        ChecklistItem(
            isSelected: itemModel.isSelected,
            action: action,
            label: {
                Text(itemModel.emoji)
                VStack(alignment: .leading) {
                    Text(itemModel.title)
                        .font(.system(size: 16))
                        .foregroundStyle(Color.textPrimary)
                    if let subtitle = itemModel.subtitle {
                        Text(subtitle)
                            .font(.system(size: 13))
                            .foregroundStyle(Color.textSecondary)
                    }
                }
                .padding(.vertical, 1)
                if itemModel.shouldShowPicker {
                    Spacer()
                    Menu {
                        ForEach(itemModel.cityPickerItems) { cityItem in
                            MenuItem(isSelected: cityItem.isSelected, title: cityItem.name) {
                                cityPickerAction(cityItem.id)
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        )
    }
}

@available(iOS 15, *)
private struct ChecklistItem<Content>: View where Content: View {
    let isSelected: Bool
    let action: () -> Void
    @ViewBuilder let label: () -> Content

    var body: some View {
        Button(
            action: action,
            label: {
                HStack(spacing: 12) {
                    Image("Check-24")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .tint(.controlColor)
                        .if(!isSelected) {
                            $0.hidden()
                        }
                    label()
                }
            }
        )
        .tint(Color(designSystemColor: .textPrimary))
        .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
    }
}

@available(iOS 15, *)
private struct MenuItem: View {
    let isSelected: Bool
    let title: String
    let action: () -> Void

    var body: some View {
        Button(
            action: action,
            label: {
                HStack(spacing: 12) {
                    Text(title)
                    Spacer()
                    Image("Check-24")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .if(!isSelected) {
                            $0.hidden()
                        }
                }
            }
        )
        .tint(Color(designSystemColor: .textPrimary))
        .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
    }
}

private extension Color {
    static let textPrimary = Color(designSystemColor: .textPrimary)
    static let textSecondary = Color(designSystemColor: .textSecondary)
    static let controlColor = Color(designSystemColor: .accent)
}

#endif
