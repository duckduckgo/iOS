//
//  AutofillSurveyManager.swift
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
import BrowserServicesKit
import Core
import RemoteMessaging

protocol AutofillSurveyManaging {
    func surveyToPresent(settings: PrivacyConfigurationData.PrivacyFeature.FeatureSettings) -> AutofillSurveyManager.AutofillSurvey?
    func markSurveyAsCompleted(id: String)
    func resetSurveys()
    func buildSurveyUrl(_ url: String, accountsCount: Int) -> URL?
}

final class AutofillSurveyManager: AutofillSurveyManaging {

    struct AutofillSurvey {
        let id: String
        let url: String
    }

    @UserDefaultsWrapper(key: .autofillSurveysCompleted, defaultValue: [])
    private var autofillSurveysCompleted: [String]

    private enum BucketName: String {
        case none
        case few
        case some
        case many
        case lots
    }

    private enum Constants {
        static let surveysSettingsKey = "surveys"
        static let surveysIdSettingsKey = "id"
        static let surveysUrlSettingsKey = "url"
        static let savedPasswordsQueryParam = "saved_passwords"
        static let listQueryParam = "list"
    }

    func surveyToPresent(settings: PrivacyConfigurationData.PrivacyFeature.FeatureSettings) -> AutofillSurvey? {
        guard let surveys = settings[Constants.surveysSettingsKey] as? [[String: Any]] else {
            return nil
        }

        for survey in surveys {
            guard let id = survey[Constants.surveysIdSettingsKey] as? String,
                  let url = survey[Constants.surveysUrlSettingsKey] as? String,
                  !hasCompletedSurvey(id: id) else {
                continue
            }
            return AutofillSurvey(id: id, url: url)
        }

        return nil
    }

    func markSurveyAsCompleted(id: String) {
        autofillSurveysCompleted.append(id)
    }

    func resetSurveys() {
        autofillSurveysCompleted.removeAll()
    }

    func buildSurveyUrl(_ url: String, accountsCount: Int) -> URL? {
        guard let surveyURL = URL(string: url) else {
            return nil
        }

        let surveyURLBuilder = DefaultRemoteMessagingSurveyURLBuilder(statisticsStore: StatisticsUserDefaults(),
                                                                      vpnActivationDateStore: DefaultVPNActivationDateStore(),
                                                                      subscription: nil)
        let url = surveyURLBuilder.add(parameters: [.appVersion, .atb, .atbVariant, .daysInstalled, .hardwareModel, .osVersion, .vpnFirstUsed, .vpnLastUsed], to: surveyURL)
        return addPasswordsCountSurveyParameter(to: url, accountsCount: accountsCount)
    }

    private func hasCompletedSurvey(id: String) -> Bool {
        autofillSurveysCompleted.contains(id)
    }

    private func addPasswordsCountSurveyParameter(to surveyURL: URL, accountsCount: Int) -> URL {
        guard var components = URLComponents(string: surveyURL.absoluteString) else {
            assertionFailure("Could not build URL components from survey URL")
            return surveyURL
        }

        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: Constants.savedPasswordsQueryParam,
                                       value: bucketNameFrom(count: accountsCount)))
        components.queryItems = queryItems

        return components.url ?? surveyURL
    }

    private func bucketNameFrom(count: Int) -> String {
        if count == 0 {
            return BucketName.none.rawValue
        } else if count < 4 {
            return BucketName.few.rawValue
        } else if count < 11 {
            return BucketName.some.rawValue
        } else if count < 50 {
            return BucketName.many.rawValue
        } else {
            return BucketName.lots.rawValue
        }
    }
}
