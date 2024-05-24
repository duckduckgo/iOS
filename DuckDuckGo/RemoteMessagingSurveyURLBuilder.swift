//
//  RemoteMessagingSurveyURLBuilder.swift
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

import Foundation
import BrowserServicesKit
import RemoteMessaging
import Core
import Common

struct DefaultRemoteMessagingSurveyURLBuilder: RemoteMessagingSurveyActionMapping {

    private let statisticsStore: StatisticsStore
    private let activationDateStore: VPNActivationDateStore

    init(statisticsStore: StatisticsStore = StatisticsUserDefaults(),
         activationDateStore: VPNActivationDateStore = DefaultVPNActivationDateStore()) {
        self.statisticsStore = statisticsStore
        self.activationDateStore = activationDateStore
    }

    // swiftlint:disable:next cyclomatic_complexity
    func add(parameters: [RemoteMessagingSurveyActionParameter], to surveyURL: URL) -> URL {
        guard var components = URLComponents(string: surveyURL.absoluteString) else {
            assertionFailure("Could not build URL components from survey URL")
            return surveyURL
        }

        var queryItems = components.queryItems ?? []

        for parameter in parameters {
            switch parameter {
            case .atb:
                if let atb = statisticsStore.atb {
                    queryItems.append(URLQueryItem(name: parameter.rawValue, value: atb))
                }
            case .atbVariant:
                if let variant = statisticsStore.variant {
                    queryItems.append(URLQueryItem(name: parameter.rawValue, value: variant))
                }
            case .osVersion:
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
            case .daysInstalled:
                if let installDate = statisticsStore.installDate,
                      let daysSinceInstall = Calendar.current.numberOfDaysBetween(installDate, and: Date()) {
                    queryItems.append(URLQueryItem(name: parameter.rawValue, value: String(describing: daysSinceInstall)))
                }
            }
        }

        components.queryItems = queryItems

        return components.url ?? surveyURL
    }

    func addPasswordsCountSurveyParameter(to surveyURL: URL) -> URL {
        let surveyURLWithParameters = add(parameters: RemoteMessagingSurveyActionParameter.allCases, to: surveyURL)

        guard var components = URLComponents(string: surveyURLWithParameters.absoluteString), let bucket = passwordsCountBucket() else {
            return surveyURLWithParameters
        }

        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: "saved_passwords", value: bucket))

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

    private func passwordsCountBucket() -> String? {
        guard let secureVault = try? AutofillSecureVaultFactory.makeVault(reporter: SecureVaultReporter.shared),
                let bucket = try? secureVault.accountsCountBucket() else {
            return nil
        }

        return bucket
    }

}
