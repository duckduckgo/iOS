//
//  ObservationsDataCleaning.swift
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

import Common
import GRDB
import os.log

public protocol ObservationsDataCleaning {

    func removeObservationsData() async

}

/// Used by data clearing.  Has no unit tests just now because getting the observation data is flakey, so we inject this for testing.
public class DefaultObservationsDataCleaner: ObservationsDataCleaning {

    public init() { }

    public func removeObservationsData() async {
        if let pool = getValidDatabasePool() {
            removeObservationsData(from: pool)
        } else {
            Logger.general.debug("Could not find valid pool to clear observations data")
        }
    }

    func getValidDatabasePool() -> DatabasePool? {
        let bundleID = Bundle.main.bundleIdentifier ?? ""

        let databaseURLs = [
            FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("WebKit/WebsiteData/ResourceLoadStatistics/observations.db"),
            FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("WebKit/\(bundleID)/WebsiteData/ResourceLoadStatistics/observations.db")
        ]

        guard let validURL = databaseURLs.first(where: { FileManager.default.fileExists(atPath: $0.path) }) else { return nil }

        return try? DatabasePool(path: validURL.absoluteString)
    }

    private func removeObservationsData(from pool: DatabasePool) {
        do {
            try pool.write { database in
                try database.execute(sql: "PRAGMA wal_checkpoint(TRUNCATE);")

                let tables = try String.fetchAll(database, sql: "SELECT name FROM sqlite_master WHERE type='table'")

                for table in tables {
                    try database.execute(sql: "DELETE FROM \(table)")
                }
            }
        } catch {
            Pixel.fire(pixel: .debugCannotClearObservationsDatabase, error: error)
        }
    }

}
