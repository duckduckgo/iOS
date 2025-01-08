//
//  CrashReportSenderExtensions.swift
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

import Crashes
import Common
import Core

extension CrashReportSender {

    static let pixelEvents: EventMapping<CrashReportSenderError> = .init { event, _, _, _ in
        switch event {
        case CrashReportSenderError.crcidMissing:
            Pixel.fire(pixel: .crashReportCRCIDMissing)

        case CrashReportSenderError.submissionFailed(let error):
            if let error {
                Pixel.fire(pixel: .crashReportingSubmissionFailed,
                           withAdditionalParameters: ["HTTPStatusCode": "\(error.statusCode)"])
            } else {
                Pixel.fire(pixel: .crashReportingSubmissionFailed)
            }
        }
    }
}
