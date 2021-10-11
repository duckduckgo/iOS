//
//  ContentBlockerRulesInputManager.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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
import TrackerRadarKit

class ContentBlockerRulesInputIdentifiers {

    let tdsIdentifier: String

    var tempListIdentifier: String?

    var allowListIdentifier: String?

    var unprotectedSitesIdentifier: String?

    init(tdsIdentfier: String) {
        self.tdsIdentifier = tdsIdentfier
    }

    var rulesIdentifier: ContentBlockerRulesIdentifier {
        ContentBlockerRulesIdentifier(tdsEtag: tdsIdentifier,
                                      tempListEtag: tempListIdentifier,
                                      allowListEtag: allowListIdentifier,
                                      unprotectedSitesHash: unprotectedSitesIdentifier)
    }
}

class ContentBlockerRulesInputModel: ContentBlockerRulesInputIdentifiers {

    let tds: TrackerData

    var tempList = [String]()

    var allowList = [TrackerException]()

    var unprotectedSites = [String]()

    init(tdsIdentfier: String, tds: TrackerData) {
        self.tds = tds
        super.init(tdsIdentfier: tdsIdentfier)
    }
}

class ContentBlockerRulesInputManager {

    private let dataSource: ContentBlockerRulesSource

    public private(set) var brokenInputs: ContentBlockerRulesInputIdentifiers?

    init(dataSource: ContentBlockerRulesSource) {
        self.dataSource = dataSource
    }

    func prepareInputs() -> ContentBlockerRulesInputModel {

        // Fetch identifier up-front
        let tempListIdentifier = dataSource.tempListEtag
        let allowListIdentifier = dataSource.allowListEtag
        let unprotectedSites = dataSource.unprotectedSites
        let unprotectedSitesIdentifier = ContentBlockerRulesIdentifier.hash(domains: unprotectedSites)

        // In case of any broken input that has been changed, reset the broken state and retry full compilation
        if (brokenInputs?.tempListIdentifier != nil && brokenInputs?.tempListIdentifier != tempListIdentifier) ||
            brokenInputs?.unprotectedSitesIdentifier != nil && brokenInputs?.unprotectedSitesIdentifier != unprotectedSitesIdentifier ||
            brokenInputs?.allowListIdentifier != nil && brokenInputs?.allowListIdentifier != allowListIdentifier {
            brokenInputs = nil
        }

        // Check which Tracker Data Set to use
        let result: ContentBlockerRulesInputModel
        if let trackerData = dataSource.trackerData,
           trackerData.etag != brokenInputs?.tdsIdentifier {
            result = ContentBlockerRulesInputModel(tdsIdentfier: trackerData.etag,
                                                   tds: trackerData.tds)
        } else {
            result = ContentBlockerRulesInputModel(tdsIdentfier: dataSource.embeddedTrackerData.etag,
                                                   tds: dataSource.embeddedTrackerData.tds)
        }

        if tempListIdentifier != brokenInputs?.tempListIdentifier {
            let tempListDomains = dataSource.tempList
            if !tempListDomains.isEmpty {
                result.tempListIdentifier = tempListIdentifier
                result.tempList = tempListDomains
            }
        }

        if allowListIdentifier != brokenInputs?.allowListIdentifier {
            let allowList = dataSource.allowList
            if !allowList.isEmpty {
                result.allowListIdentifier = allowListIdentifier
                result.allowList = allowList
            }
        }

        if unprotectedSitesIdentifier != brokenInputs?.unprotectedSitesIdentifier {
            if !unprotectedSites.isEmpty {
                result.unprotectedSitesIdentifier = unprotectedSitesIdentifier
                result.unprotectedSites = unprotectedSites
            }
        }

        return result
    }

    func compilationFailed(for input: ContentBlockerRulesInputIdentifiers, with error: Error) {

        if input.tdsIdentifier != dataSource.embeddedTrackerData.etag {
            // We failed compilation for non-embedded TDS, marking as broken.
            brokenInputs = ContentBlockerRulesInputIdentifiers(tdsIdentfier: input.tdsIdentifier)
            Pixel.fire(pixel: .contentBlockingTDSCompilationFailed,
                       error: error,
                       withAdditionalParameters: [PixelParameters.etag: input.tdsIdentifier])
        } else if input.tempListIdentifier != nil {
            brokenInputs?.tempListIdentifier = input.tempListIdentifier
            Pixel.fire(pixel: .contentBlockingTempListCompilationFailed,
                       error: error,
                       withAdditionalParameters: [PixelParameters.etag: input.tempListIdentifier ?? "empty"])
        } else if input.allowListIdentifier != nil {
            brokenInputs?.allowListIdentifier = input.allowListIdentifier
            Pixel.fire(pixel: .contentBlockingAllowListCompilationFailed,
                       error: error,
                       withAdditionalParameters: [PixelParameters.etag: input.allowListIdentifier ?? "empty"])
        } else if input.unprotectedSitesIdentifier != nil {
            brokenInputs?.unprotectedSitesIdentifier = input.unprotectedSitesIdentifier
            Pixel.fire(pixel: .contentBlockingUnpSitesCompilationFailed,
                       error: error)
        } else {
            // We failed for embedded data, this is unlikely.
            // Include description - why built-in version of the TDS has failed to compile?
            let error = error as NSError
            let errorDesc = (error.userInfo[NSHelpAnchorErrorKey] as? String) ?? "missing"
            let params = [PixelParameters.errorDescription: errorDesc.isEmpty ? "empty" : errorDesc]
            Pixel.fire(pixel: .contentBlockingFallbackCompilationFailed, error: error, withAdditionalParameters: params) { _ in
                fatalError("Could not compile embedded rules list")
            }
        }
    }
}
