//
//  SurveyURLBuilder.swift
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
import BrowserServicesKit
import Core
import Common

protocol SurveyURLBuilder {
    func addSurveyParameters(to url: URL) -> URL
}

struct DefaultSurveyURLBuilder: SurveyURLBuilder {

    enum SurveyURLParameters: String, CaseIterable {
        case atb = "atb"
        case atbVariant = "var"
        case daysSinceActivated = "delta"
        case iosVersion = "mv"
        case appVersion = "ddgv"
        case hardwareModel = "mo"
        case lastActiveDate = "da"
    }

    private let statisticsStore: StatisticsStore
    private let activationDateStore: VPNWaitlistActivationDateStore

    init(statisticsStore: StatisticsStore = StatisticsUserDefaults(),
         activationDateStore: VPNWaitlistActivationDateStore = DefaultVPNWaitlistActivationDateStore()) {
        self.statisticsStore = statisticsStore
        self.activationDateStore = activationDateStore
    }

    // swiftlint:disable:next cyclomatic_complexity
    func addSurveyParameters(to surveyURL: URL) -> URL {
        guard var components = URLComponents(string: surveyURL.absoluteString) else {
            assertionFailure("Could not build URL components from survey URL")
            return surveyURL
        }

        var queryItems = components.queryItems ?? []

        for parameter in SurveyURLParameters.allCases {
            switch parameter {
            case .atb:
                if let atb = statisticsStore.atb {
                    queryItems.append(URLQueryItem(name: parameter.rawValue, value: atb))
                }
            case .atbVariant:
                if let variant = statisticsStore.variant {
                    queryItems.append(URLQueryItem(name: parameter.rawValue, value: variant))
                }
            case .daysSinceActivated:
                if let daysSinceActivated = activationDateStore.daysSinceActivation() {
                    queryItems.append(URLQueryItem(name: parameter.rawValue, value: String(describing: daysSinceActivated)))
                }
            case .iosVersion:
                queryItems.append(URLQueryItem(name: parameter.rawValue, value: AppVersion.shared.osVersion))
            case .appVersion:
                queryItems.append(URLQueryItem(name: parameter.rawValue, value: AppVersion.shared.versionAndBuildNumber))
            case .hardwareModel:
                let model = hardwareModel().addingPercentEncoding(withAllowedCharacters: .alphanumerics)
                queryItems.append(URLQueryItem(name: parameter.rawValue, value: model))
            case .lastActiveDate:
                if let daysSinceLastActive = activationDateStore.daysSinceLastActive() {
                    queryItems.append(URLQueryItem(name: parameter.rawValue, value: String(describing: daysSinceLastActive)))
                }
            }
        }

        components.queryItems = queryItems

        return components.url ?? surveyURL
    }

    private func hardwareModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)

        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        return identifier
    }

}

#endif
