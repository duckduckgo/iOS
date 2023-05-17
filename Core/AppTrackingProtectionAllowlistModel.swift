//
//  AppTrackingProtectionAllowlistModel.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

public class AppTrackingProtectionAllowlistModel {
    public enum Constants {
        public static let groupID = "\(Global.groupIdPrefix).apptp"
        public static let fileName = "appTPallowlist"
    }
    
    private let filename: String
    
    lazy private var allowlistUrl: URL? = {
        let groupContainerUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.groupID)
        return groupContainerUrl?.appendingPathComponent(self.filename, conformingTo: .text)
    }()
    
    var allowedDomains: Set<String>
    
    public init(filename: String = Constants.fileName) {
        self.allowedDomains = Set<String>()
        self.filename = filename
        
        readFromFile()
    }
    
    func writeToFile() {
        guard let allowlistUrl = allowlistUrl else {
            fatalError("Unable to get file location")
        }
        
        // Write the allowlist as a textfile with one domain per line
        do {
            let string = allowedDomains.joined(separator: "\n")
            try string.write(to: allowlistUrl, atomically: true, encoding: .utf8)
            Task {
#if APP_TRACKING_PROTECTION
                await FirewallManager().notifyAllowlistChange()
#endif
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func readFromFile() {
        guard let allowlistUrl = allowlistUrl else {
            fatalError("Unable to get file location")
        }
        guard FileManager.default.fileExists(atPath: allowlistUrl.path) else {
            return
        }
        
        // Read allowlist from file. Break the string into array then cast to a set.
        do {
            let strData = try String(contentsOf: allowlistUrl)
            let list = strData.trimmingWhitespace().components(separatedBy: "\n")
            allowedDomains = Set<String>(list)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func allow(domain: String) {
        allowedDomains.insert(domain)
        writeToFile()
    }
    
    public func contains(domain: String) -> Bool {
        var check = domain
        while check.contains(".") {
            if allowedDomains.contains(check) {
                return true
            }
            
            check = String(check.components(separatedBy: ".").dropFirst().joined(separator: "."))
        }
        
        return false
    }
    
    public func remove(domain: String) {
        allowedDomains.remove(domain)
        writeToFile()
    }
    
    public func clearList() {
        allowedDomains.removeAll()
        writeToFile()
    }
}
