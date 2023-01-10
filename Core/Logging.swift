//
//  Logging.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

public extension OSLog {
    
    static var generalLog: OSLog {
        Logging.generalLoggingEnabled ? Logging.generalLog : .disabled
    }
    
    static var contentBlockingLog: OSLog {
        Logging.contentBlockingLoggingEnabled ? Logging.contentBlockingLog : .disabled
    }

    static var adAttributionLog: OSLog {
        Logging.adAttributionLoggingEnabled ? Logging.adAttributionLog : .disabled
    }
    
    static var lifecycleLog: OSLog {
        Logging.lifecycleLoggingEnabled ? Logging.lifecycleLog : .disabled
    }
    
    static var autoconsentLog: OSLog {
        Logging.autoconsentLoggingEnabled ? Logging.autoconsentLog : .disabled
    }
}

struct Logging {
    fileprivate static let generalLoggingEnabled = true
    fileprivate static let generalLog: OSLog = OSLog(subsystem: Bundle.main.bundleIdentifier ?? AppVersion.shared.identifier,
                                                     category: "DDG General")
    
    fileprivate static let contentBlockingLoggingEnabled = true
    fileprivate static let contentBlockingLog: OSLog = OSLog(subsystem: Bundle.main.bundleIdentifier ?? AppVersion.shared.identifier,
                                                             category: "DDG Content Blocking")
    
    fileprivate static let adAttributionLoggingEnabled = true
    fileprivate static let adAttributionLog: OSLog = OSLog(subsystem: Bundle.main.bundleIdentifier ?? AppVersion.shared.identifier,
                                                           category: "DDG AdAttribution")
    
    fileprivate static let lifecycleLoggingEnabled = true
    fileprivate static let lifecycleLog: OSLog = OSLog(subsystem: Bundle.main.bundleIdentifier ?? AppVersion.shared.identifier,
                                                       category: "DDG Lifecycle")
    
    fileprivate static let autoconsentLoggingEnabled = false
    fileprivate static let autoconsentLog: OSLog = OSLog(subsystem: Bundle.main.bundleIdentifier ?? AppVersion.shared.identifier,
                                                         category: "DDG Autoconsent")
}
