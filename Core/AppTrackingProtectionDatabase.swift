//
//  AppTrackingProtectionDatabase.swift
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
import Persistence

public class AppTrackingProtectionDatabase {

    public enum Constants {
        public static let groupID = "\(Global.groupIdPrefix).apptp"
    }

    private init() { }

    public static var defaultDBLocation: URL = {
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.groupID) else {
            Pixel.fire(pixel: .appTPDBLocationFailed)
            Thread.sleep(forTimeInterval: 1)
            fatalError("Failed to get location")
        }

        return url
    }()

    public static func make(location: URL = defaultDBLocation, readOnly: Bool = false) -> CoreDataDatabase {
        let bundle = Bundle(for: AppTrackingProtectionDatabase.self)
        guard let model = CoreDataDatabase.loadModel(from: bundle, named: "AppTrackingProtectionModel") else {
            Pixel.fire(pixel: .appTPDBStoreLoadFailure)
            Thread.sleep(forTimeInterval: 1)
            fatalError("Failed to load model")
        }

        let options = [
            NSPersistentHistoryTrackingKey: true as NSNumber,
            NSPersistentStoreRemoteChangeNotificationPostOptionKey: true as NSNumber
        ]

        let db = CoreDataDatabase(name: "AppTrackingProtection",
                                  containerLocation: location,
                                  model: model,
                                  readOnly: readOnly,
                                  options: options)

        return db
    }

}
