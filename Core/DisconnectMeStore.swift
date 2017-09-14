//
//  DisconnectMeStore.swift
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

class DisconnectMeStore {

    static let shared = DisconnectMeStore()

    var hasData: Bool {
        return jsonString != "[]"
    }

    private(set) var jsonString: String = "[]"

    private var persistenceLocation: URL {
        get {
            let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let path = URL(fileURLWithPath: documentPath, isDirectory: true)
            return path.appendingPathComponent("disconnectme.json")
        }
    }

    private init() {
        _ = try? parse(data: Data(contentsOf: persistenceLocation))
    }

    func persist(data: Data) throws -> Int {
        let count = try parse(data: data)
        try! data.write(to: persistenceLocation, options: .atomic)
        return count
    }

    private func parse(data: Data) throws -> Int {
        let trackers = try DisconnectMeTrackersParser().convert(fromJsonData: data)
        let json = try JSONSerialization.data(withJSONObject: trackers, options: .prettyPrinted) 
        if let jsonString = String(data: json, encoding: .utf8) {
            self.jsonString = jsonString
        }
        return trackers.count
    }   

}
