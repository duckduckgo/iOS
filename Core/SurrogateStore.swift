//
//  SurrogateStore.swift
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

class SurrogateStore {

    private let groupIdentifier: String

    public private(set) var jsFunctions: [String: String]?

    init(groupIdentifier: String = ContentBlockerStoreConstants.groupName) {
        self.groupIdentifier = groupIdentifier
        jsFunctions = NSDictionary(contentsOf: persistenceLocation()) as? [String: String]
    }

    func parseAndPersist(data: Data) {
        guard let surrogateFile = String(data: data, encoding: .utf8) else { return }
        jsFunctions = SurrogateParser.parse(lines: surrogateFile.components(separatedBy: .newlines))
        guard let plist = jsFunctions as NSDictionary? else { return }
        plist.write(to: persistenceLocation(), atomically: true)
    }

    private func persistenceLocation() -> URL {
        let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)
        return path!.appendingPathComponent("surrogate.js")
    }

}

class SurrogateParser {

    static func parse(lines: [String]) -> [String: String] {
        var jsDict = [String: String]()

        var resourceName: String?
        var jsFunction: String?

        for line in lines {

            guard !line.hasPrefix("#") else { continue }

            // We can only cope with scripts anyway, see contentblocker.js -> loadSurrogate(url)
            if line.hasSuffix("application/javascript") {
                resourceName = line.components(separatedBy: " ")[0]
                jsFunction = ""
                continue
            }

            guard jsFunction != nil else { continue }

            jsFunction = "\(jsFunction!)\(line)\n"

            if line.trimWhitespace() == "" {
                jsDict[resourceName!] = jsFunction?.trimWhitespace()
                jsFunction = nil
                resourceName = nil
            }
        }

        if let resourceName = resourceName {
            jsDict[resourceName] = jsFunction?.trimWhitespace()
        }

        return jsDict
    }

}
