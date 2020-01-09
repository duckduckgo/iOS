//
//  PersistentLogger.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

public class PersistentLogger {
    
    class LogHandle: TextOutputStream {
        
        private let handle: FileHandle
        
        init?(url: URL) {
            if !FileManager.default.fileExists(atPath: url.path) {
                FileManager.default.createFile(atPath: url.path,
                                               contents: nil,
                                               attributes: [FileAttributeKey.protectionKey: FileProtectionType.none])
            }
            
            guard let handle = try? FileHandle(forWritingTo: url) else { return nil }
            handle.seekToEndOfFile()
            
            self.handle = handle
        }
        
        func write(_ string: String) {
            guard let data = string.data(using: .utf8) else { return }
            handle.write(data)
        }
        
        deinit {
            handle.closeFile()
        }
    }
    
    static var currentLogfileExpirationDate = Date()
    
    static private var _logfile: LogHandle?
    static private var logfile: LogHandle? {
        guard let url = logsDirectoryURL()?.appendingPathComponent(currentLogfileName()) else { return nil }
        
        let handle: LogHandle?
        if let logfile = _logfile {
            handle = logfile
        } else {
            print("---> \(url)")
            handle = LogHandle(url: url)
            _logfile = handle
        }

        return handle
    }
    
    public static func logsDirectoryURL() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
    }
    
    public static func currentLogfileName() -> String {
        return "log.log"
    }
    
    private static let dateFormatter: ISO8601DateFormatter = {
        let dateFormatter = ISO8601DateFormatter()
        if #available(iOSApplicationExtension 11.0, *) {
            dateFormatter.formatOptions = [
                .withInternetDateTime, .withFractionalSeconds
            ]
        } else {
            dateFormatter.formatOptions = [
                .withInternetDateTime
            ]
        }
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter
    }()
    
    public static func log(_ items: String...) {
        guard let handle = logfile else { return }
        
        let dateString = dateFormatter.string(from: Date())
        handle.write(dateString + " - " + items.joined(separator: " ") + "\n")
    }
}
