//
//  CrashCollectionService.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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

import Core
import Crashes

final class CrashCollectionService {

    private let appSettings: AppSettings
    private let application: UIApplication
    init(appSettings: AppSettings = AppUserDefaults(),
         application: UIApplication = UIApplication.shared) {
        self.appSettings = appSettings
        self.application = application
    }

    private lazy var crashCollection = CrashCollection(crashReportSender: CrashReportSender(platform: .iOS,
                                                                                            pixelEvents: CrashReportSender.pixelEvents),
                                                       crashCollectionStorage: UserDefaults())
    private lazy var crashReportUploaderOnboarding = CrashCollectionOnboarding(appSettings: appSettings)

    func onLaunching() {
        startAttachingCrashLogMessages()
    }

    private func startAttachingCrashLogMessages() {
        crashCollection.startAttachingCrashLogMessages { [weak self] pixelParameters, payloads, sendReport in
            pixelParameters.forEach { params in
                Pixel.fire(pixel: .dbCrashDetected, withAdditionalParameters: params, includedParameters: [])

                // Each crash comes with an `appVersion` parameter representing the version that the crash occurred on.
                // This is to disambiguate the situation where a crash occurs, but isn't sent until the next update.
                // If for some reason the parameter can't be found, fall back to the current version.
                if let crashAppVersion = params[PixelParameters.appVersion] {
                    let dailyParameters = [PixelParameters.appVersion: crashAppVersion]
                    DailyPixel.fireDaily(.dbCrashDetectedDaily, withAdditionalParameters: dailyParameters)
                } else {
                    DailyPixel.fireDaily(.dbCrashDetectedDaily)
                }
            }

            // Async dispatch because rootViewController may otherwise be nil here
            DispatchQueue.main.async {
                guard let viewController = self?.application.window?.rootViewController else { return }
                self?.crashReportUploaderOnboarding.presentOnboardingIfNeeded(for: payloads, from: viewController, sendReport: sendReport)
            }
        }
    }

}
