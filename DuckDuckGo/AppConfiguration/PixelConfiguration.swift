//
//  PixelConfiguration.swift
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

import Foundation
import PixelKit
import PixelExperimentKit
import UIKit
import Networking
import Common
import Core
import BrowserServicesKit

final class PixelConfiguration {

    static func configure(with featureFlagger: FeatureFlagger) {

#if DEBUG
        Pixel.isDryRun = true
#else
        Pixel.isDryRun = false
#endif
        let isPhone = UIDevice.current.userInterfaceIdiom == .phone
        let source = isPhone ? PixelKit.Source.iOS : PixelKit.Source.iPadOS
        PixelKit.setUp(dryRun: Pixel.isDryRun,
                       appVersion: AppVersion.shared.versionNumber,
                       source: source.rawValue,
                       defaultHeaders: [:],
                       defaults: UserDefaults(suiteName: "\(Global.groupIdPrefix).app-configuration") ?? UserDefaults()) { (pixelName: String, headers: [String: String], parameters: [String: String], _, _, onComplete: @escaping PixelKit.CompletionBlock) in

            let url = URL.pixelUrl(forPixelNamed: pixelName)
            let apiHeaders = APIRequestV2.HeadersV2(additionalHeaders: headers)
            guard let request = APIRequestV2(url: url, method: .get, queryItems: parameters.toQueryItems(), headers: apiHeaders) else {
                assertionFailure("Invalid Pixel request")
                onComplete(false, nil)
                return
            }
            Task {
                do {
                    _ = try await DefaultAPIService().fetch(request: request)
                    onComplete(true, nil)
                } catch {
                    onComplete(false, error)
                }
            }
        }
        PixelKit.configureExperimentKit(featureFlagger: featureFlagger,
                                        eventTracker: ExperimentEventTracker(store: UserDefaults(suiteName: "\(Global.groupIdPrefix).app-configuration") ?? UserDefaults()))
    }

}
