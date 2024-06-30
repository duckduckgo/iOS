//
//  BookmarksStateRepair.swift
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

public class BookmarksStateRepair {

    enum Constants {
        static let pendingDeletionRepaired = "stateRepair_pendingDeletionRepaired"
    }

    public enum RepairStatus: Equatable {
        case alreadyPerformed
        case noBrokenData
        case dataRepaired
        case repairError(Error)

        public static func == (lhs: BookmarksStateRepair.RepairStatus, rhs: BookmarksStateRepair.RepairStatus) -> Bool {
            switch (lhs, rhs) {
            case (.alreadyPerformed, .alreadyPerformed), (.noBrokenData, .noBrokenData), (.dataRepaired, .dataRepaired), (.repairError, .repairError):
                return true
            default:
                return false
            }
        }
    }

    let keyValueStore: KeyValueStoring

    public init(keyValueStore: KeyValueStoring) {
        self.keyValueStore = keyValueStore
    }

    public func validateAndRepairPendingDeletionState(in context: NSManagedObjectContext) -> RepairStatus {

        guard keyValueStore.object(forKey: Constants.pendingDeletionRepaired) == nil else {
            return .alreadyPerformed
        }

        do {
            let fr = BookmarkEntity.fetchRequest()
            fr.predicate = NSPredicate(format: "%K == nil", #keyPath(BookmarkEntity.isPendingDeletion))

            let result = try context.fetch(fr)

            if !result.isEmpty {
                for obj in result {
                    obj.setValue(false, forKey: #keyPath(BookmarkEntity.isPendingDeletion))
                }

                try context.save()

                keyValueStore.set(true, forKey: Constants.pendingDeletionRepaired)
                return .dataRepaired
            } else {
                keyValueStore.set(true, forKey: Constants.pendingDeletionRepaired)
                return .noBrokenData
            }
        } catch {
            return .repairError(error)
        }
    }

}
