//
//  DisconnectMeStore.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 12/09/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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
