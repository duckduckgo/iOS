//
//  Pixel.swift
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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
import Common
import Networking
import os.log

public struct PixelParameters {
    public static let url = "url"
    public static let duration = "dur"
    static let test = "test"
    public static let appVersion = "appVersion"

    public static let autocompleteBookmarkCapable = "bc"
    public static let autocompleteIncludedLocalResults = "sb"

    public static let originatedFromMenu = "om"

    public static let applicationState = "as"
    public static let dataAvailability = "dp"

    static let errorCode = "e"
    static let errorDomain = "d"
    static let errorDescription = "de"
    static let errorCount = "c"
    static let underlyingErrorCode = "ue"
    static let underlyingErrorDomain = "ud"

    static let coreDataErrorCode = "coreDataCode"
    static let coreDataErrorDomain = "coreDataDomain"
    static let coreDataErrorEntity = "coreDataEntity"
    static let coreDataErrorAttribute = "coreDataAttribute"

    public static let tabCount = "tc"

    public static let widgetSmall = "ws"
    public static let widgetMedium = "wm"
    public static let widgetLarge = "wl"
    public static let widgetError = "we"
    public static let widgetErrorCode = "ec"
    public static let widgetErrorDomain = "ed"
    public static let widgetUnavailable = "wx"

    static let removeCookiesTimedOut = "rc"
    static let clearWebDataTimedOut = "cd"

    public static let tabPreviewCountDelta = "cd"

    public static let etag = "et"

    public static let emailCohort = "cohort"
    public static let emailLastUsed = "duck_address_last_used"

    // Cookie clearing
    public static let storeInitialCount = "store_initial_count"
    public static let storeProtectedCount = "store_protected_count"
    public static let didStoreDeletionTimeOut = "did_store_deletion_time_out"
    public static let storageInitialCount = "storage_initial_count"
    public static let storageProtectedCount = "storage_protected_count"
    public static let storeAfterDeletionCount = "store_after_deletion_count"
    public static let storageAfterDeletionCount = "storage_after_deletion_count"
    public static let storeAfterDeletionDiffCount = "store_after_deletion_diff_count"
    public static let storageAfterDeletionDiffCount = "storage_after_deletion_diff_count"

    public static let tabsModelCount = "tabs_model_count"
    public static let tabControllerCacheCount = "tab_controller_cache_count"

    public static let count = "count"
    public static let source = "source"

    // Text size is the legacy name
    public static let textZoomInitial = "text_size_initial"
    public static let textZoomUpdated = "text_size_updated"

    public static let canAutoPreviewMIMEType = "can_auto_preview_mime_type"
    public static let mimeType = "mime_type"
    public static let fileSizeGreaterThan10MB = "file_size_greater_than_10mb"
    public static let downloadListCount = "download_list_count"

    public static let bookmarkCount = "bco"

    public static let isBackgrounded = "is_backgrounded"
    public static let isDataProtected = "is_data_protected"

    public static let isInternalUser = "is_internal_user"

    // Email manager
    public static let emailKeychainAccessType = "access_type"
    public static let emailKeychainError = "error"
    public static let emailKeychainKeychainStatus = "keychain_status"
    public static let emailKeychainKeychainOperation = "keychain_operation"

    public static let bookmarkErrorOrphanedFolderCount = "bookmark_error_orphaned_count"
    public static let bookmarksLastGoodVersion = "previous_app_version"

    // Remote messaging
    public static let message = "message"
    public static let sheetResult = "success"

    // Network Protection
    public static let keychainFieldName = "fieldName"
    public static let keychainErrorCode = errorCode
    public static let latency = "latency"
    public static let server = "server"
    public static let networkType = "network_type"
    public static let function = "function"
    public static let line = "line"
    public static let reason = "reason"
    public static let vpnCohort = "cohort"

    // Return user
    public static let returnUserErrorCode = "error_code"
    public static let returnUserOldATB = "old_atb"
    public static let returnUserNewATB = "new_atb"

    // Pixel Experiment
    public static let cohort = "cohort"

    // Ad Attribution
    public static let adAttributionOrgID = "org_id"
    public static let adAttributionCampaignID = "campaign_id"
    public static let adAttributionConversionType = "conversion_type"
    public static let adAttributionAdGroupID = "ad_group_id"
    public static let adAttributionCountryOrRegion = "country_or_region"
    public static let adAttributionKeywordID = "keyword_id"
    public static let adAttributionAdID = "ad_id"
    public static let adAttributionToken = "attribution_token"
    public static let adAttributionIsReinstall = "is_reinstall"

    // Autofill
    public static let countBucket = "count_bucket"
    public static let backfilled = "backfilled"
    public static let isExtension = "is_extension"

    // Privacy Dashboard
    public static let daysSinceInstall = "daysSinceInstall"
    public static let fromOnboarding = "from_onboarding"

    // Subscription
    public static let privacyProKeychainAccessType = "access_type"
    public static let privacyProKeychainError = "error"

    // Persistent pixel
    public static let originalPixelTimestamp = "originalPixelTimestamp"
    public static let retriedPixel = "retriedPixel"

    public static let time = "time"

    public static let appState = "state"
    public static let appEvent = "event"

    public static let didCallWillEnterForeground = "didCallWillEnterForeground"

    // Background Tasks
    public static let backgroundTaskCategory = "category"
}

public struct PixelValues {
    static let test = "1"
}

public class Pixel {

    private struct Constants {
        static let tablet = "tablet"
        static let phone = "phone"
    }

    public static var isDryRun = false

    private static var isInternalUser: Bool {
        DefaultInternalUserDecider(store: InternalUserStore()).isInternalUser
    }

    public static let defaultPixelUserAgent: String = {
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        // Strip patch version component as per https://app.asana.com/0/69071770703008/1209176655620013/f
        let trimmedOSVersion = "\(osVersion.majorVersion).\(osVersion.minorVersion)"
        return DefaultUserAgentManager.duckduckGoUserAgent(for: AppVersion.shared, osVersion: trimmedOSVersion)
    }()

    public enum QueryParameters: Codable {
        case atb
        case appVersion
    }
    
    
    private enum Constant {
        static let pixelStorageIdentifier = "com.duckduckgo.pixel.storage"
    }

    public static let storage = UserDefaults(suiteName: Constant.pixelStorageIdentifier)!
    
    private init() {
    }

    public static func fire(pixel: Pixel.Event,
                            forDeviceType deviceType: UIUserInterfaceIdiom? = UIDevice.current.userInterfaceIdiom,
                            withAdditionalParameters params: [String: String] = [:],
                            allowedQueryReservedCharacters: CharacterSet? = nil,
                            withHeaders headers: APIRequest.Headers = APIRequest.Headers(),
                            includedParameters: [QueryParameters] = [.appVersion],
                            onComplete: @escaping (Error?) -> Void = { _ in },
                            debounce: Int = 0) {
        
        let date = Date().addingTimeInterval(-TimeInterval(debounce))
        if !pixel.hasBeenFiredSince(pixelStorage: storage, date: date) {
            fire(
                pixelNamed: pixel.name,
                forDeviceType: deviceType,
                withAdditionalParameters: params,
                allowedQueryReservedCharacters: allowedQueryReservedCharacters,
                withHeaders: headers,
                includedParameters: includedParameters,
                onComplete: onComplete
            )
            updatePixelLastFireDate(pixel: pixel)
        } else {
            onComplete(nil)
        }
    }
    
    private static func updatePixelLastFireDate(pixel: Pixel.Event) {
        storage.set(Date(), forKey: pixel.name)
    }

    public static func fire(pixelNamed pixelName: String,
                            forDeviceType deviceType: UIUserInterfaceIdiom? = UIDevice.current.userInterfaceIdiom,
                            withAdditionalParameters params: [String: String] = [:],
                            allowedQueryReservedCharacters: CharacterSet? = nil,
                            withHeaders headers: APIRequest.Headers = APIRequest.Headers(userAgent: defaultPixelUserAgent),
                            includedParameters: [QueryParameters] = [.appVersion],
                            onComplete: @escaping (Error?) -> Void = { _ in }) {
        var newParams = params
        if includedParameters.contains(.appVersion) {
            newParams[PixelParameters.appVersion] = AppVersion.shared.versionAndBuildNumber
        }

        guard !isDryRun else {
            Logger.general.debug("Pixel fired \(pixelName.replacingOccurrences(of: "_", with: "."), privacy: .public) \(params.count > 0 ? "\(params)" : "", privacy: .public)")
            // simulate server response time for Dry Run mode
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onComplete(nil)
            }
            return
        }

        if isDebugBuild {
            newParams[PixelParameters.test] = PixelValues.test
        }
        if isInternalUser {
            newParams[PixelParameters.isInternalUser] = "true"
        }

        let url: URL
        if let deviceType = deviceType {
            let formFactor = deviceType == .pad ? Constants.tablet : Constants.phone
            url = URL.makePixelURL(pixelName: pixelName,
                                   formFactor: formFactor,
                                   includeATB: includedParameters.contains(.atb))
        } else {
            url = URL.makePixelURL(pixelName: pixelName, includeATB: includedParameters.contains(.atb) )
        }

        let configuration = APIRequest.Configuration(url: url,
                                                     queryParameters: newParams,
                                                     allowedQueryReservedCharacters: allowedQueryReservedCharacters,
                                                     headers: headers)
        let request = APIRequest(configuration: configuration, urlSession: .session(useMainThreadCallbackQueue: true))
        request.fetch { _, error in
            Logger.general.debug("Pixel fired \(pixelName, privacy: .public) \(params, privacy: .public)")
            onComplete(error)
        }
    }

}

extension Pixel {

    public static func fire(pixel: Pixel.Event,
                            error: Error?,
                            includedParameters: [QueryParameters] = [.appVersion],
                            withAdditionalParameters params: [String: String] = [:],
                            onComplete: @escaping (Error?) -> Void = { _ in }) {
        var newParams = params
        if let error {
            newParams.appendErrorPixelParams(error: error)
        }
        fire(pixel: pixel, withAdditionalParameters: newParams, includedParameters: includedParameters, onComplete: onComplete)
    }
}

private extension Pixel.Event {
    
    func hasBeenFiredSince(pixelStorage: UserDefaults, date: Date) -> Bool {
        if let lastFireDate = pixelStorage.object(forKey: name) as? Date {
            return lastFireDate >= date
        }
        return false
    }
    
    
}

extension Dictionary where Key == String, Value == String {

    mutating func appendErrorPixelParams(error: Error) {
        let nsError = error as NSError

        self[PixelParameters.errorCode] = "\(nsError.code)"
        self[PixelParameters.errorDomain] = nsError.domain

        let underlyingErrorParameters = underlyingErrorParameters(for: error as NSError)
        self.merge(underlyingErrorParameters) { first, _ in first }
    }

    private func underlyingErrorParameters(for nsError: NSError, level: Int = 0) -> [String: String] {
        if let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? NSError {
            let errorCodeParameterName = PixelParameters.underlyingErrorCode + (level == 0 ? "" : String(level + 1))
            let errorDomainParameterName = PixelParameters.underlyingErrorDomain + (level == 0 ? "" : String(level + 1))

            let currentUnderlyingErrorParameters = [
                errorCodeParameterName: "\(underlyingError.code)",
                errorDomainParameterName: underlyingError.domain
            ]

            let additionalParameters = underlyingErrorParameters(for: underlyingError, level: level + 1)
            return currentUnderlyingErrorParameters.merging(additionalParameters) { first, _ in first }
        } else if let sqlErrorCode = nsError.userInfo["NSSQLiteErrorDomain"] as? NSNumber {
            return [
                PixelParameters.underlyingErrorCode: "\(sqlErrorCode.intValue)",
                PixelParameters.underlyingErrorDomain: "NSSQLiteErrorDomain"
            ]
        }

        return [:]
    }

}
