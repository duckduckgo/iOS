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
        print("-- Documents dir path: \(url)")
        
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

//MARK: memory
// See https://forums.developer.apple.com/thread/105088#357415
extension PersistentLogger {
    
    static private var memoryFootprint: mach_vm_size_t? {
        // The `TASK_VM_INFO_COUNT` and `TASK_VM_INFO_REV1_COUNT` macros are too
        // complex for the Swift C importer, so we have to define them ourselves.
        let TASKVMINFOCOUNT = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<integer_t>.size)
        let TASKVMINFOREV1COUNT = mach_msg_type_number_t(MemoryLayout.offset(of: \task_vm_info_data_t.min_address)! / MemoryLayout<integer_t>.size)
        var info = task_vm_info_data_t()
        var count = TASKVMINFOCOUNT
        let kr = withUnsafeMutablePointer(to: &info) { infoPtr in
            infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), intPtr, &count)
            }
        }
        guard
            kr == KERN_SUCCESS,
            count >= TASKVMINFOREV1COUNT
        else { return nil }
        return info.phys_footprint
    }
    
    static public func logMemoryFootprint() {
        guard let footprint = memoryFootprint else {
            log("Could not read memory footprint")
            return
        }
        
        let MB = Double(footprint) / 1024 / 1024
        log("Memory usage: \(MB)MB")
    }
    
}
