//
//  UnifiedFeedbackSender.swift
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
import Core

protocol UnifiedFeedbackSender {
    func sendFeatureRequestPixel(description: String, source: String) async throws
    func sendGeneralFeedbackPixel(description: String, source: String) async throws
    func sendReportIssuePixel<T: UnifiedFeedbackMetadata>(source: String, category: String, subcategory: String, description: String, metadata: T?) async throws

    func sendFormShowPixel() async
    func sendSubmitScreenShowPixel(source: String, reportType: String, category: String, subcategory: String) async
    func sendActionsScreenShowPixel(source: String) async
    func sendCategoryScreenShow(source: String, reportType: String) async
    func sendSubcategoryScreenShow(source: String, reportType: String, category: String) async
    func sendSubmitScreenFAQClickPixel(source: String, reportType: String, category: String, subcategory: String) async

    static func additionalParameters(for pixel: Pixel.Event) -> [String: String]
}

enum UnifiedFeedbackSenderFrequency {
    case regular
    case dailyAndCount
}

extension UnifiedFeedbackSender {
    static func additionalParameters(for pixel: Pixel.Event) -> [String: String] {
        [:]
    }

    func sendPixel(_ pixel: Pixel.Event, frequency: UnifiedFeedbackSenderFrequency) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            let completionHandler: (Error?) -> Void = { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }

            switch frequency {
            case .regular:
                Pixel.fire(pixel: pixel,
                           withAdditionalParameters: Self.additionalParameters(for: pixel),
                           onComplete: completionHandler)
            case .dailyAndCount:
                DailyPixel.fireDailyAndCount(pixel: pixel,
                                             pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
                                             withAdditionalParameters: Self.additionalParameters(for: pixel),
                                             onDailyComplete: { _ in },
                                             onCountComplete: completionHandler)
            }
        }
    }
}

protocol StringRepresentable: RawRepresentable {
    static var `default`: Self { get }
}

extension StringRepresentable where RawValue == String {
    static func from(_ text: String) -> String {
        (Self(rawValue: text) ?? .default).rawValue
    }
}

struct DefaultFeedbackSender: UnifiedFeedbackSender {
    enum Source: String, StringRepresentable {
        case settings, ppro, vpn, pir, itr, unknown
        static var `default` = Source.unknown
    }

    enum ReportType: String, StringRepresentable {
        case general, reportIssue, requestFeature
        static var `default` = ReportType.general
    }

    enum Category: String, StringRepresentable {
        case subscription, vpn, pir, itr, unknown
        static var `default` = Category.unknown
    }

    enum Subcategory: String, StringRepresentable {
        case otp
        case unableToInstall, failsToConnect, tooSlow, issueWithAppOrWebsite, appCrashesOrFreezes, cantConnectToLocalDevice
        case nothingOnSpecificSite, notMe, scanStuck, removalStuck
        case accessCode, cantContactAdvisor, advisorUnhelpful
        case somethingElse
        static var `default` = Subcategory.somethingElse
    }

    func sendFeatureRequestPixel(description: String, source: String) async throws {
        try await sendPixel(.pproFeedbackFeatureRequest(description: description,
                                                        source: Source.from(source)),
                            frequency: .regular)
    }

    func sendGeneralFeedbackPixel(description: String, source: String) async throws {
        try await sendPixel(.pproFeedbackGeneralFeedback(description: description,
                                                         source: Source.from(source)),
                            frequency: .regular)
    }

    func sendReportIssuePixel<T: UnifiedFeedbackMetadata>(source: String, category: String, subcategory: String, description: String, metadata: T?) async throws {
        try await sendPixel(.pproFeedbackReportIssue(source: Source.from(source),
                                                     category: Category.from(category),
                                                     subcategory: Subcategory.from(subcategory),
                                                     description: description,
                                                     metadata: metadata?.toBase64() ?? ""),
                            frequency: .regular)
    }

    func sendFormShowPixel() async {
        try? await sendPixel(.pproFeedbackFormShow, frequency: .regular)
    }

    func sendSubmitScreenShowPixel(source: String, reportType: String, category: String, subcategory: String) async {
        try? await sendPixel(.pproFeedbackSubmitScreenShow(source: source,
                                                           reportType: ReportType.from(reportType),
                                                           category: Category.from(category),
                                                           subcategory: Subcategory.from(subcategory)),
                             frequency: .dailyAndCount)
    }

    func sendActionsScreenShowPixel(source: String) async {
        try? await sendPixel(.pproFeedbackActionsScreenShow(source: source),
                             frequency: .dailyAndCount)
    }

    func sendCategoryScreenShow(source: String, reportType: String) async {
        try? await sendPixel(.pproFeedbackCategoryScreenShow(source: source,
                                                             reportType: ReportType.from(reportType)),
                             frequency: .dailyAndCount)
    }

    func sendSubcategoryScreenShow(source: String, reportType: String, category: String) async {
        try? await sendPixel(.pproFeedbackSubcategoryScreenShow(source: source,
                                                                reportType: ReportType.from(reportType),
                                                                category: Category.from(category)),
                             frequency: .dailyAndCount)
    }

    func sendSubmitScreenFAQClickPixel(source: String, reportType: String, category: String, subcategory: String) async {
        try? await sendPixel(.pproFeedbackSubmitScreenShow(source: source,
                                                           reportType: ReportType.from(reportType),
                                                           category: Category.from(category),
                                                           subcategory: Subcategory.from(subcategory)),
                             frequency: .dailyAndCount)
    }

    static func additionalParameters(for pixel: Pixel.Event) -> [String: String] {
        switch pixel {
        case .pproFeedbackFeatureRequest(let description, let source):
            return [
                "description": description,
                "source": source,
            ]
        case .pproFeedbackGeneralFeedback(let description, let source):
            return [
                "description": description,
                "source": source,
            ]
        case .pproFeedbackReportIssue(let source, let category, let subcategory, let description, let metadata):
            return [
                "description": description,
                "source": source,
                "category": category,
                "subcategory": subcategory,
                "customMetadata": metadata,
            ]
        case .pproFeedbackActionsScreenShow(let source):
            return [
                "source": source,
            ]
        case .pproFeedbackCategoryScreenShow(let source, let reportType):
            return [
                "source": source,
                "reportType": reportType,
            ]
        case .pproFeedbackSubcategoryScreenShow(let source, let reportType, let category):
            return [
                "source": source,
                "reportType": reportType,
                "category": category,
            ]
        case .pproFeedbackSubmitScreenShow(let source, let reportType, let category, let subcategory):
            return [
                "source": source,
                "reportType": reportType,
                "category": category,
                "subcategory": subcategory,
            ]
        case .pproFeedbackSubmitScreenFAQClick(let source, let reportType, let category, let subcategory):
            return [
                "source": source,
                "reportType": reportType,
                "category": category,
                "subcategory": subcategory,
            ]
        default:
            return [:]
        }
    }
}
