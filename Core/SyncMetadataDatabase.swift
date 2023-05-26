//
//  SyncMetadataDatabase.swift
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
import CoreData
import DDGSync
import Persistence
import Common

public final class SyncMetadataDatabase {

    private init() { }

    public static var defaultDBLocation: URL = {
        guard let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            os_log("SyncMetadataDatabase.make - OUT, failed to get location")
            fatalError("Failed to get location")
        }
        return url
    }()

    public static func make(location: URL = defaultDBLocation, readOnly: Bool = false) -> CoreDataDatabase {
        os_log("SyncMetadataDatabase.make - IN - %s", location.absoluteString)
        let bundle = DDGSync.bundle
        guard let model = CoreDataDatabase.loadModel(from: bundle, named: "SyncMetadata") else {
            os_log("SyncMetadataDatabase.make - OUT, failed to loadModel")
            fatalError("Failed to load model")
        }

        let db = CoreDataDatabase(name: "SyncMetadata",
                                  containerLocation: location,
                                  model: model,
                                  readOnly: readOnly)
        os_log("SyncMetadataDatabase.make - OUT")
        return db
    }

}
