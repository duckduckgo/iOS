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
import os.log
import BrowserServicesKit
import Common
import Networking

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

    public static let textSizeInitial = "text_size_initial"
    public static let textSizeUpdated = "text_size_updated"
    
    public static let canAutoPreviewMIMEType = "can_auto_preview_mime_type"
    public static let mimeType = "mime_type"
    public static let fileSizeGreaterThan10MB = "file_size_greater_than_10mb"
    public static let downloadListCount = "download_list_count"
    
    public static let bookmarkCount = "bco"
    
    public static let isBackgrounded = "is_backgrounded"
    
    public static let isInternalUser = "is_internal_user"
    
    // Email manager
    public static let emailKeychainAccessType = "access_type"
    public static let emailKeychainError = "error"
    public static let emailKeychainKeychainStatus = "keychain_status"
    public static let emailKeychainKeychainOperation = "keychain_operation"

    public static let bookmarkErrorOrphanedFolderCount = "bookmark_error_orphaned_count"

    public static let ctaShown = "cta"
}

public struct PixelValues {
    static let test = "1"
}

public class Pixel {

    private struct Constants {
        static let tablet = "tablet"
        static let phone = "phone"
    }
    
    private static var isInternalUser: Bool {
        DefaultInternalUserDecider(store: InternalUserStore()).isInternalUser
    }

    public enum QueryParameters {
        case atb
        case appVersion
    }
    
    private init() {
    }
    
    public static func fire(pixel: Pixel.Event,
                            forDeviceType deviceType: UIUserInterfaceIdiom? = UIDevice.current.userInterfaceIdiom,
                            withAdditionalParameters params: [String: String] = [:],
                            allowedQueryReservedCharacters: CharacterSet? = nil,
                            withHeaders headers: HTTPHeaders = APIRequest.Headers().default,
                            includedParameters: [QueryParameters] = [.atb, .appVersion],
                            onComplete: @escaping (Error?) -> Void = { _ in }) {
        
        var newParams = params
        if includedParameters.contains(.appVersion) {
            newParams[PixelParameters.appVersion] = AppVersion.shared.versionAndBuildNumber
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
            url = URL.makePixelURL(pixelName: pixel.name,
                                   formFactor: formFactor,
                                   includeATB: includedParameters.contains(.atb))
        } else {
            url = URL.makePixelURL(pixelName: pixel.name, includeATB: includedParameters.contains(.atb) )
        }
        
        let configuration = APIRequest.Configuration(url: url,
                                                     queryParameters: newParams,
                                                     allowedQueryReservedCharacters: allowedQueryReservedCharacters,
                                                     headers: headers)
        let request = APIRequest(configuration: configuration, urlSession: .session(useMainThreadCallbackQueue: true))
        request.fetch { _, error in
            os_log("Pixel fired %s %s", log: .generalLog, type: .debug, pixel.name, "\(params)")
            onComplete(error)
        }
    }
    
}

extension Pixel {
    
    public static func fire(pixel: Pixel.Event,
                            error: Error,
                            withAdditionalParameters params: [String: String] = [:],
                            onComplete: @escaping (Error?) -> Void = { _ in }) {
        let nsError = error as NSError
        var newParams = params
        newParams[PixelParameters.errorCode] = "\(nsError.code)"
        newParams[PixelParameters.errorDomain] = nsError.domain
        
        if let underlyingError = nsError.userInfo["NSUnderlyingError"] as? NSError {
            newParams[PixelParameters.underlyingErrorCode] = "\(underlyingError.code)"
            newParams[PixelParameters.underlyingErrorDomain] = underlyingError.domain
        } else if let sqlErrorCode = nsError.userInfo["NSSQLiteErrorDomain"] as? NSNumber {
            newParams[PixelParameters.underlyingErrorCode] = "\(sqlErrorCode.intValue)"
            newParams[PixelParameters.underlyingErrorDomain] = "NSSQLiteErrorDomain"
        }
        
        fire(pixel: pixel, withAdditionalParameters: newParams, includedParameters: [], onComplete: onComplete)
    }
}
