//
//  PersistentStoresConfiguration.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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
import Core
import Persistence

public extension NSNotification.Name {

    static let databaseDidEncounterInsufficientDiskSpace = Notification.Name("com.duckduckgo.database.insufficient.disk.space")

}

final class PersistentStoresConfiguration {

    let database = Database.shared
    let bookmarksDatabase = BookmarksDatabase.make()
    private let application: UIApplication
    private let notificationCenter: NotificationCenter

    init(application: UIApplication = .shared,
         notificationCenter: NotificationCenter = .default) {
        self.application = application
        self.notificationCenter = notificationCenter
    }

    func configure() {
        clearTemporaryDirectory()
        loadAndMigrateDatabase()
        loadAndMigrateBookmarksDatabase()
    }

    private func clearTemporaryDirectory() {
        let tmp = FileManager.default.temporaryDirectory
        do {
            try FileManager.default.removeItem(at: tmp)
        } catch {
            Logger.general.error("Failed to delete tmp dir")
        }
    }

    private func loadAndMigrateDatabase() {
        database.loadStore { [application] context, error in
            guard let context = context else {
                let parameters = [PixelParameters.applicationState: "\(application.applicationState.rawValue)",
                                  PixelParameters.dataAvailability: "\(application.isProtectedDataAvailable)"]
                switch error {
                case .none:
                    fatalError("Could not create database stack: Unknown Error")
                case .some(CoreDataDatabase.Error.containerLocationCouldNotBePrepared(let underlyingError)):
                    Pixel.fire(pixel: .dbContainerInitializationError,
                               error: underlyingError,
                               withAdditionalParameters: parameters)
                    Thread.sleep(forTimeInterval: 1)
                    fatalError("Could not create database stack: \(underlyingError.localizedDescription)")
                case .some(let error):
                    Pixel.fire(pixel: .dbInitializationError,
                               error: error,
                               withAdditionalParameters: parameters)
                    if error.isDiskFull {
                        NotificationCenter.default.post(name: .databaseDidEncounterInsufficientDiskSpace, object: nil)
                        return
                    } else {
                        Thread.sleep(forTimeInterval: 1)
                        fatalError("Could not create database stack: \(error.localizedDescription)")
                    }
                }
            }
            DatabaseMigration.migrate(to: context)
        }
    }

    private func loadAndMigrateBookmarksDatabase() {
        switch BookmarksDatabaseSetup().loadStoreAndMigrate(bookmarksDatabase: bookmarksDatabase) {
        case .success:
            break
        case .failure(let error):
            Pixel.fire(pixel: .bookmarksCouldNotLoadDatabase,
                       error: error)
            if error.isDiskFull {
                NotificationCenter.default.post(name: .databaseDidEncounterInsufficientDiskSpace, object: nil)
            } else {
                Thread.sleep(forTimeInterval: 1)
                fatalError("Could not create database stack: \(error.localizedDescription)")
            }
        }
    }

}

extension Error {

    var isDiskFull: Bool {
        let nsError = self as NSError
        if let underlyingError = nsError.userInfo["NSUnderlyingError"] as? NSError, underlyingError.code == 13 {
            return true
        } else if nsError.userInfo["NSSQLiteErrorDomain"] as? Int == 13 {
            return true
        }
        return false
    }

}
