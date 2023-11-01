//
//  FeatureFlagDebugView.swift
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
import BrowserServicesKit
import Core

struct FeatureFlagDebugView: View {
    @StateObject var viewModel: FeatureFlagDebugViewModel = FeatureFlagDebugViewModel()

    var body: some View {
        List {
            ForEach(viewModel.items) { item in
                self.featureConfigView(item)
            }
        }
        .navigationTitle("Feature Flags")
    }

    @ViewBuilder
    func featureConfigView(_ item: FeatureFlagDebugViewModel.Item) -> some View {
        VStack {
            HStack {
                Text(item.id)
                Picker("Feature override",
                    selection: Binding(
                        get: {
                            item.overrideState
                        },
                        set: { value in
                            viewModel.updateOverride(id: item.id, overrideState: value)
                        }
                    )
                ) {
                    ForEach(FeatureFlagDebugViewModel.Item.OverrideState.allCases) { state in
                        Text(state.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }
}

public final class FeatureFlagDebugViewModel: ObservableObject {
    @Published var items: [Item]
    private let featureFlagger: FeatureFlagger
    private let featureFlagOverrider: OverrideableFeatureFlagger

    convenience init(defaultFeatureFlagger: DefaultFeatureFlagger = AppDependencyProvider.shared.featureFlagger) {
        self.init(featureFlagger: defaultFeatureFlagger, featureFlagOverrider: defaultFeatureFlagger)
    }

    init(featureFlagger: FeatureFlagger,
         featureFlagOverrider: OverrideableFeatureFlagger) {
        self.featureFlagger = featureFlagger
        self.featureFlagOverrider = featureFlagOverrider
        for flag in FeatureFlag.allCases {
            items.append(
                Item(
                    id: flag.rawValue,
                    overrideState: Item.OverrideState(bool: featureFlagOverrider.overrideValue(for: flag)),
                    flagState: featureFlagger.isFeatureOn(flag)
                )
            )
        }
    }

    public struct Item: Identifiable {
        public var id: String

        public var overrideState: OverrideState
        public var flagState: Bool

        public enum OverrideState: String, Identifiable, CaseIterable {
            public var id: String {
                rawValue
            }

            init(bool: Bool?) {
                guard let bool else {
                    self = .noOverride
                }
                self = bool ? .overrideOn : .overrideOff
            }

            case overrideOn = "Override to On"
            case overrideOff = "Override to Off"
            case noOverride = "No Override"
        }
    }

    func updateOverride(id: String, overrideState: Item.OverrideState) {
        guard let flag = FeatureFlag(rawValue: id) else {
            return
        }
        let value: Bool?
        switch overrideState {
        case .overrideOn:
            value = true
        case .overrideOff:
            value = false
        case .noOverride:
            value = nil
        }
        featureFlagOverrider.setOverride(value: value, for: flag)
    }
}

#Preview {
    FeatureFlagDebugView()
}
