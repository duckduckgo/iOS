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
import Subscription

struct DefaultRemoteMessagingSurveyURLBuilder: RemoteMessagingSurveyActionMapping {

    private let statisticsStore: StatisticsStore
    private let vpnActivationDateStore: VPNActivationDateStore
    private let subscription: Subscription?

    init(statisticsStore: StatisticsStore = StatisticsUserDefaults(),
         vpnActivationDateStore: VPNActivationDateStore = DefaultVPNActivationDateStore(),
         subscription: Subscription?) {
        self.statisticsStore = statisticsStore
        self.vpnActivationDateStore = vpnActivationDateStore
        self.subscription = subscription
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
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
            case .lastActiveDate: break
            case .daysInstalled:
                if let installDate = statisticsStore.installDate,
                   let daysSinceInstall = Calendar.current.numberOfDaysBetween(installDate, and: Date()) {
                    queryItems.append(URLQueryItem(name: parameter.rawValue, value: String(describing: daysSinceInstall)))
                }
            case .privacyProStatus:
                switch subscription?.status {
                case .autoRenewable: queryItems.append(URLQueryItem(name: parameter.rawValue, value: "auto_renewable"))
                case .notAutoRenewable: queryItems.append(URLQueryItem(name: parameter.rawValue, value: "not_auto_renewable"))
                case .gracePeriod: queryItems.append(URLQueryItem(name: parameter.rawValue, value: "grace_period"))
                case .inactive: queryItems.append(URLQueryItem(name: parameter.rawValue, value: "inactive"))
                case .expired: queryItems.append(URLQueryItem(name: parameter.rawValue, value: "expired"))
                case .unknown: queryItems.append(URLQueryItem(name: parameter.rawValue, value: "unknown"))
                case nil: break
                }
            case .privacyProPlatform:

                switch subscription?.platform {
                case .apple: queryItems.append(URLQueryItem(name: parameter.rawValue, value: "apple"))
                case .google: queryItems.append(URLQueryItem(name: parameter.rawValue, value: "google"))
                case .stripe: queryItems.append(URLQueryItem(name: parameter.rawValue, value: "stripe"))
                case .unknown: queryItems.append(URLQueryItem(name: parameter.rawValue, value: "unknown"))
                case nil: break
                }
            case .privacyProBilling:
                switch subscription?.billingPeriod {
                case .monthly: queryItems.append(URLQueryItem(name: parameter.rawValue, value: "monthly"))
                case .yearly: queryItems.append(URLQueryItem(name: parameter.rawValue, value: "yearly"))
                case .unknown: queryItems.append(URLQueryItem(name: parameter.rawValue, value: "unknown"))
                case nil: break
                }

            case .privacyProDaysSincePurchase:
                if let startDate = subscription?.startedAt,
                   let daysSincePurchase = Calendar.current.numberOfDaysBetween(startDate, and: Date()) {
                    queryItems.append(URLQueryItem(name: parameter.rawValue, value: String(describing: daysSincePurchase)))
                }
            case .privacyProDaysUntilExpiry:
                if let expiryDate = subscription?.expiresOrRenewsAt,
                   let daysUntilExpiry = Calendar.current.numberOfDaysBetween(Date(), and: expiryDate) {
                    queryItems.append(URLQueryItem(name: parameter.rawValue, value: String(describing: daysUntilExpiry)))
                }
            case .vpnFirstUsed:
                if let vpnFirstUsed = vpnActivationDateStore.daysSinceActivation() {
                    queryItems.append(URLQueryItem(name: parameter.rawValue, value: String(describing: vpnFirstUsed)))
                }
            case .vpnLastUsed:
                if let vpnLastUsed = vpnActivationDateStore.daysSinceLastActive() {
                    queryItems.append(URLQueryItem(name: parameter.rawValue, value: String(describing: vpnLastUsed)))
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
