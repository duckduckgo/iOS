//
//  BookmarksStateValidation.swift
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

import Foundation
import CoreData
import Bookmarks
import Persistence

public protocol BookmarksStateValidation {

    func validateInitialState(context: NSManagedObjectContext,
                              validationError: BookmarksStateValidator.ValidationError) -> Bool

    func validateBookmarksStructure(context: NSManagedObjectContext)
}

public class BookmarksStateValidator: BookmarksStateValidation {

    enum Constants {
        static let bookmarksDBIsInitialized = "bookmarksDBIsInitialized"
    }

    public enum ValidationError {
        case bookmarksStructureLost
        case bookmarksStructureNotRecovered
        case bookmarksStructureBroken(additionalParams: [String: String])
        case validatorError(Error)
    }

    let keyValueStore: KeyValueStoring
    let errorHandler: (ValidationError) -> Void

    public init(keyValueStore: KeyValueStoring,
                errorHandler: @escaping (ValidationError) -> Void) {
        self.keyValueStore = keyValueStore
        self.errorHandler = errorHandler
    }

    public func validateInitialState(context: NSManagedObjectContext,
                                     validationError: ValidationError) -> Bool {
        guard keyValueStore.object(forKey: Constants.bookmarksDBIsInitialized) != nil else { return true }

        let fetch = BookmarkEntity.fetchRequest()
        do {
            let count = try context.count(for: fetch)
            if count == 0 {
                errorHandler(validationError)
                return false
            }
        } catch {
            errorHandler(.validatorError(error))
        }

        return true
    }

    public func validateBookmarksStructure(context: NSManagedObjectContext) {
        let isMarkedAsInitialized = keyValueStore.object(forKey: Constants.bookmarksDBIsInitialized) != nil
        if isMarkedAsInitialized == false {
            keyValueStore.set(true, forKey: Constants.bookmarksDBIsInitialized)
        }

        let rootUUIDs = [BookmarkEntity.Constants.rootFolderID,
                         FavoritesFolderID.unified.rawValue,
                         FavoritesFolderID.mobile.rawValue,
                         FavoritesFolderID.desktop.rawValue]

        let request = BookmarkEntity.fetchRequest()
        request.predicate = NSPredicate(format: "%K IN %@", #keyPath(BookmarkEntity.uuid), rootUUIDs)

        do {
            let roots = try context.fetch(request)
            if roots.count != rootUUIDs.count {
                var additionalParams = [String: String]()

                for uuid in rootUUIDs {
                    additionalParams[uuid] = "\(roots.filter({ $0.uuid == uuid }).count)"
                }

                additionalParams["is-marked-as-initialized"] = isMarkedAsInitialized ? "true" : "false"

                errorHandler(.bookmarksStructureBroken(additionalParams: additionalParams))
            }
        } catch {
            errorHandler(.validatorError(error))
        }
    }
}
