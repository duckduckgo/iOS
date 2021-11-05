//
//  ContentBlockerRulesSourceManager.swift
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

/**
 Encapsulates revision of the Content Blocker Rules source - id/etag of each of the resources used for compilation.
 */
class ContentBlockerRulesSourceIdentifiers {

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

/**
 Model used to compile Content Blocking Rules along with Identifiers.
 */
class ContentBlockerRulesSourceModel: ContentBlockerRulesSourceIdentifiers {

    let tds: TrackerData

    var tempList = [String]()

    var allowList = [TrackerException]()

    var unprotectedSites = [String]()

    init(tdsIdentfier: String, tds: TrackerData) {
        self.tds = tds
        super.init(tdsIdentfier: tdsIdentfier)
    }
}

/**
 Manages sources that are used to compile Content Blocking Rules, handles possible broken state by filtering out sources that are potentially corrupted.
 */
class ContentBlockerRulesSourceManager {

    /**
     Data source for all of the inputs used for compilation.
     */
    private let dataSource: ContentBlockerRulesSource

    /**
     Identifiers of sources that have caused compilation process to fail.
     */
    public private(set) var brokenSources: ContentBlockerRulesSourceIdentifiers?

    init(dataSource: ContentBlockerRulesSource) {
        self.dataSource = dataSource
    }

    /**
     Create Source Model based on data source and knowne broken sources.

     This method takes into account changes to `dataSource` that could fix previously corrupted data set - in such case `brokenSources` state is updated.
     */
    func makeModel() -> ContentBlockerRulesSourceModel {

        // Fetch identifiers up-front
        let tempListIdentifier = dataSource.tempListEtag
        let allowListIdentifier = dataSource.allowListEtag
        let unprotectedSites = dataSource.unprotectedSites
        let unprotectedSitesIdentifier = ContentBlockerRulesIdentifier.hash(domains: unprotectedSites)

        // In case of any broken input that has been changed, reset the broken state and retry full compilation
        if (brokenSources?.tempListIdentifier != nil && brokenSources?.tempListIdentifier != tempListIdentifier) ||
            brokenSources?.unprotectedSitesIdentifier != nil && brokenSources?.unprotectedSitesIdentifier != unprotectedSitesIdentifier ||
            brokenSources?.allowListIdentifier != nil && brokenSources?.allowListIdentifier != allowListIdentifier {
            brokenSources = nil
        }

        // Check which Tracker Data Set to use - fallback to embedded one in case of any issues.
        let result: ContentBlockerRulesSourceModel
        if let trackerData = dataSource.trackerData,
           trackerData.etag != brokenSources?.tdsIdentifier {
            result = ContentBlockerRulesSourceModel(tdsIdentfier: trackerData.etag,
                                                   tds: trackerData.tds)
        } else {
            result = ContentBlockerRulesSourceModel(tdsIdentfier: dataSource.embeddedTrackerData.etag,
                                                   tds: dataSource.embeddedTrackerData.tds)
        }

        if tempListIdentifier != brokenSources?.tempListIdentifier {
            let tempListDomains = dataSource.tempList
            if !tempListDomains.isEmpty {
                result.tempListIdentifier = tempListIdentifier
                result.tempList = tempListDomains
            }
        }

        if allowListIdentifier != brokenSources?.allowListIdentifier {
            let allowList = dataSource.allowList
            if !allowList.isEmpty {
                result.allowListIdentifier = allowListIdentifier
                result.allowList = allowList
            }
        }

        if unprotectedSitesIdentifier != brokenSources?.unprotectedSitesIdentifier {
            if !unprotectedSites.isEmpty {
                result.unprotectedSitesIdentifier = unprotectedSitesIdentifier
                result.unprotectedSites = unprotectedSites
            }
        }

        return result
    }

    /**
     Process information about last failed compilation in order to update `brokenSources` state.
     */
    func compilationFailed(for input: ContentBlockerRulesSourceIdentifiers, with error: Error) {

        if input.tdsIdentifier != dataSource.embeddedTrackerData.etag {
            // We failed compilation for non-embedded TDS, marking it as broken.
            brokenSources = ContentBlockerRulesSourceIdentifiers(tdsIdentfier: input.tdsIdentifier)
            Pixel.fire(pixel: .contentBlockingTDSCompilationFailed,
                       error: error,
                       withAdditionalParameters: [PixelParameters.etag: input.tdsIdentifier])
        } else if input.tempListIdentifier != nil {
            brokenSources?.tempListIdentifier = input.tempListIdentifier
            Pixel.fire(pixel: .contentBlockingTempListCompilationFailed,
                       error: error,
                       withAdditionalParameters: [PixelParameters.etag: input.tempListIdentifier ?? "empty"])
        } else if input.allowListIdentifier != nil {
            brokenSources?.allowListIdentifier = input.allowListIdentifier
            Pixel.fire(pixel: .contentBlockingAllowListCompilationFailed,
                       error: error,
                       withAdditionalParameters: [PixelParameters.etag: input.allowListIdentifier ?? "empty"])
        } else if input.unprotectedSitesIdentifier != nil {
            brokenSources?.unprotectedSitesIdentifier = input.unprotectedSitesIdentifier
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
