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
        let expiresAt: Date
        
        init?(url: URL, expirationDate: Date) {
            if !FileManager.default.fileExists(atPath: url.path) {
                FileManager.default.createFile(atPath: url.path,
                                               contents: nil,
                                               attributes: [FileAttributeKey.protectionKey: FileProtectionType.none])
            }
            
            guard let handle = try? FileHandle(forWritingTo: url) else { return nil }
            handle.seekToEndOfFile()
            
            self.handle = handle
            self.expiresAt = expirationDate
        }
        
        func write(_ string: String) {
            guard let data = string.data(using: .utf8) else { return }
            handle.write(data)
        }
        
        deinit {
            handle.closeFile()
        }
    }
    
    static let lock = NSLock()
    
    static private var _logfile: LogHandle?
    static private func logfile(with date: Date) -> LogHandle? {
        lock.lock()
        let handle: LogHandle?
        if let logfile = _logfile {
            if logfile.expiresAt <= date {
                handle = prepareLogHandle(with: date)
            } else {
                handle = logfile
            }
        } else {
            handle = prepareLogHandle(with: date)
            _logfile = handle
        }
        lock.unlock()
        return handle
    }
    
    static private func prepareLogHandle(with date: Date) -> LogHandle? {
        guard let url = logsDirectoryURL()?.appendingPathComponent(logfileName(for: date)) else { return nil }
        print("---> \(url)")
        
        let calendar = Calendar.current
        let nextDay = calendar.date(byAdding: .day, value: 1, to: date)!
        let components = calendar.dateComponents([.day, .month, .year], from: nextDay)
        let startOfNextDay = calendar.date(from: components)!
        
        return LogHandle(url: url, expirationDate: startOfNextDay)
    }
    
    public static func logsDirectoryURL() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
    }
    
    public static func logfileName(for date: Date) -> String {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]
        dateFormatter.timeZone = TimeZone.current
        return "\(dateFormatter.string(from: date)).log"
    }
    
    private static let dateFormatter: ISO8601DateFormatter = {
        let dateFormatter = ISO8601DateFormatter()
        if #available(iOSApplicationExtension 11.0, *) {
            dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        } else {
            dateFormatter.formatOptions = [.withInternetDateTime]
        }
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter
    }()
    
    public static func log(_ items: Any...) {
        let date = Date()
        guard let handle = logfile(with: date) else { return }
        
        let dateString = dateFormatter.string(from: date)
        let stringItems = items.map { String(describing: $0) }
        handle.write(dateString + " - " + stringItems.joined(separator: " ") + "\n")
    }
}
