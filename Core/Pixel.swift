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

// swiftlint:enable type_body_length
// swiftlint:enable identifier_name

public struct PixelParameters {
    public static let url = "url"
    public static let duration = "dur"
    static let test = "test"
    static let appVersion = "appVersion"
    
    public static let autocompleteBookmarkCapable = "bc"
    public static let autocompleteIncludedLocalResults = "sb"
    
    public static let originatedFromMenu = "om"
    
    static let applicationState = "as"
    static let dataAvailiability = "dp"
    
    static let errorCode = "e"
    static let errorDomain = "d"
    static let errorDescription = "de"
    static let errorCount = "c"
    static let underlyingErrorCode = "ue"
    static let underlyingErrorDomain = "ud"

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
    
    public static let count = "count"

    public static let textSizeInitial = "text_size_initial"
    public static let textSizeUpdated = "text_size_updated"
    
    public static let canAutoPreviewMIMEType = "can_auto_preview_mime_type"
    public static let mimeType = "mime_type"
    public static let fileSizeGreaterThan10MB = "file_size_greater_than_10mb"
    
    public static let bookmarkCount = "bco"
    
    public static let isBackgrounded = "is_backgrounded"
    
    public static let isInternalUser = "is_internal_user"
}

public struct PixelValues {
    static let test = "1"
}

public class Pixel {

    private static let appUrls = AppUrls()
    
    private struct Constants {
        static let tablet = "tablet"
        static let phone = "phone"
    }
    
    private static var isInternalUser: Bool {
        DefaultFeatureFlagger().isInternalUser
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
                            withHeaders headers: HTTPHeaders = APIHeaders().defaultHeaders,
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
            url = appUrls.pixelUrl(forPixelNamed: pixel.name,
                                   formFactor: formFactor,
                                   includeATB: includedParameters.contains(.atb))
        } else {
            url = appUrls.pixelUrl(forPixelNamed: pixel.name, includeATB: includedParameters.contains(.atb) )
        }
        
        APIRequest.request(url: url, parameters: newParams, headers: headers, callBackOnMainThread: true) { (_, error) in
            
            os_log("Pixel fired %s %s", log: generalLog, type: .debug, pixel.name, "\(params)")
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
        if isInternalUser {
            newParams[PixelParameters.isInternalUser] = "true"
        }
        
        fire(pixel: pixel, withAdditionalParameters: newParams, includedParameters: [], onComplete: onComplete)
    }
}

public class TimedPixel {
    
    let pixel: Pixel.Event
    let date: Date
    
    public init(_ pixel: Pixel.Event, date: Date = Date()) {
        self.pixel = pixel
        self.date = date
    }
    
    public func fire(_ fireDate: Date = Date(), withAdditionalParameters params: [String: String] = [:]) {
        let duration = String(fireDate.timeIntervalSince(date))
        var newParams = params
        newParams[PixelParameters.duration] = duration
        Pixel.fire(pixel: pixel, withAdditionalParameters: newParams)
    }
    
}
// swiftlint:enable file_length
