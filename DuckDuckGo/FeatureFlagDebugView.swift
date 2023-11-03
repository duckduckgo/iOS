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
import DesignResourcesKit

struct FeatureFlagDebugView: View {
    @StateObject var viewModel: FeatureFlagDebugViewModel = FeatureFlagDebugViewModel()

    var body: some View {
        List {
            ForEach(viewModel.items) { item in
                FeatureFlagItemView(viewModel: item)
            }
        }
        .navigationTitle("Feature Flags")
    }
}

struct FeatureFlagItemView: View {
    @StateObject var viewModel: FeatureFlagItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(viewModel.id).daxTitle3()
                Spacer()
                Text(viewModel.flagStateIndicator)
            }

            Picker("Local Override:", selection: $viewModel.overrideState) {
                ForEach(FeatureFlagItem.OverrideState.allCases) { state in
                    Text(state.rawValue).tag(state)
                }
            }.daxBodyBold()
            HStack {
                Text("Flag Source:")
                    .daxBodyBold()
                Spacer()
                Text(viewModel.sourceTitle)
                    .multilineTextAlignment(.trailing)
                    .daxBodyRegular()
            }
            if let configFeatureTitle = viewModel.configFeatureTitle {
                HStack {
                    Text("Config Feature:")
                        .daxBodyBold()
                    Spacer()
                    Text(configFeatureTitle)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(1)
                        .scaledToFit()
                        .minimumScaleFactor(0.2)
                        .if(true) {
                            if #available(iOS 15.0, *) {
                                $0.font(.body.monospaced())
                            } else {
                                $0.font(.body)
                            }
                        }
                }
            }
        }
    }
}

import Combine

public class FeatureFlagItem: ObservableObject, Identifiable {
    private let featureFlag: FeatureFlag
    private let featureFlagger: FeatureFlagger
    private let featureFlagOverrider: OverrideableFeatureFlagger
    private var cancellable: AnyCancellable?

    public var id: String {
        featureFlag.rawValue
    }

    public var flagTitle: String {
        featureFlag.rawValue
    }
    @Published public var flagStateIndicator: String
    @Published public var overrideState: OverrideState
    public var sourceTitle: String
    public var configFeatureTitle: String?

    init(featureFlag: FeatureFlag, featureFlagger: FeatureFlagger, featureFlagOverrider: OverrideableFeatureFlagger) {
        self.featureFlag = featureFlag
        self.featureFlagger = featureFlagger
        self.featureFlagOverrider = featureFlagOverrider
        overrideState = OverrideState(bool: featureFlagOverrider.overrideValue(for: featureFlag))
        flagStateIndicator = featureFlagger.isFeatureOn(featureFlag).emoji
        sourceTitle = featureFlag.source.presentableText.title
        configFeatureTitle = featureFlag.source.presentableText.configFeatureTitle
        cancellable = $overrideState.sink(receiveValue: updateOverride(overrideState:))
    }

    public enum OverrideState: String, Identifiable, CaseIterable {
        public var id: String {
            rawValue
        }

        init(bool: Bool?) {
            guard let bool else {
                self = .noOverride
                return
            }
            self = bool ? .overrideOn : .overrideOff
        }

        case overrideOn = "On"
        case overrideOff = "Off"
        case noOverride = "None"
    }

    private func updateOverride(overrideState: FeatureFlagItem.OverrideState) {
        let value: Bool?
        switch overrideState {
        case .overrideOn:
            value = true
        case .overrideOff:
            value = false
        case .noOverride:
            value = nil
        }
        featureFlagOverrider.setOverride(value: value, for: featureFlag)
        flagStateIndicator = featureFlagger.isFeatureOn(featureFlag).emoji
    }
}

private extension FeatureFlagSource {
    var presentableText: (title: String, configFeatureTitle: String?) {
        switch self {
        case .disabled:
            return (title: "Disabled", configFeatureTitle: nil)
        case .internalOnly:
            return (title: "Internal Only", configFeatureTitle: nil)
        case .remoteDevelopment(let level):
            return (title: "Remote Dev", configFeatureTitle: level.presentableText)
        case .remoteReleasable(let level):
            return (title: "Remote Release", configFeatureTitle: level.presentableText)
        }
    }
}


private extension PrivacyConfigFeatureLevel {
    var presentableText: String {
        switch self {
        case .feature(let feature):
            return feature.rawValue
        case .subfeature(let subfeature):
            return "\(subfeature.parent).\(subfeature)"
        }
    }
}

private extension Bool {
    var emoji: String {
        self ? "✅" : "❌"
    }
}

public final class FeatureFlagDebugViewModel: ObservableObject {
    @Published var items: [FeatureFlagItem] = []

    init(featureFlagger: FeatureFlagger = AppDependencyProvider.shared.featureFlagger,
         featureFlagOverrider: OverrideableFeatureFlagger = AppDependencyProvider.shared.featureFlagOverrider) {
        for flag in FeatureFlag.allCases {
            guard flag != .debugMenu else {
                continue
            }
            items.append(
                FeatureFlagItem(
                    featureFlag: flag,
                    featureFlagger: featureFlagger,
                    featureFlagOverrider: featureFlagOverrider
                )
            )
        }
    }
}
