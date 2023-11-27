//
//  BookmarksDatabase.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import Foundation
import CoreData
import Persistence
import Bookmarks

public class BookmarksDatabase {

    public enum Constants {
        public static let bookmarksGroupID = "\(Global.groupIdPrefix).bookmarks"
    }

    private init() { }
    
    public static var defaultDBLocation: URL = {
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.bookmarksGroupID) else {
            os_log("BookmarksDatabase.make - OUT, failed to get location %{public}s", Constants.bookmarksGroupID)
            fatalError("Failed to get location")
        }
        return url
    }()

    public static var defaultDBFileURL: URL = {
        return defaultDBLocation.appendingPathComponent("Bookmarks.sqlite", conformingTo: .database)
    }()

    public static func make(location: URL = defaultDBLocation, readOnly: Bool = false) -> CoreDataDatabase {
        os_log("BookmarksDatabase.make - IN - %s", location.absoluteString)
        let bundle = Bookmarks.bundle
        guard let model = CoreDataDatabase.loadModel(from: bundle, named: "BookmarksModel") else {
            os_log("BookmarksDatabase.make - OUT, failed to loadModel")
            fatalError("Failed to load model")
        }

        let db = CoreDataDatabase(name: "Bookmarks",
                                  containerLocation: location,
                                  model: model,
                                  readOnly: readOnly)
        os_log("BookmarksDatabase.make - OUT")
        return db
    }
}
