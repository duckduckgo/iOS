//
//  BookmarksDebugViewController.swift
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

import UIKit
import SwiftUI
import Core
import Combine
import Persistence
import Bookmarks
import CoreData

class BookmarksDebugViewController: UIHostingController<BookmarksDebugRootView> {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: BookmarksDebugRootView())
    }

}

struct BookmarksDebugRootView: View {

    @ObservedObject var model = BookmarksDebugViewModel()
    @State private var showingDestructiveAlert = false

    var body: some View {
        List(model.bookmarks, id: \.id) { entry in
            VStack(alignment: .leading) {
                Text(entry.title ?? "empty!")
                    .font(.system(size: 16))
                Text("Is unified fav: " + (entry.isFavorite(on: .unified) ? "true" : "false") )
                    .font(.system(size: 12))
                Text("Is mobile fav: " + (entry.isFavorite(on: .mobile) ? "true" : "false") )
                    .font(.system(size: 12))
                Text("Is desktop fav: " + (entry.isFavorite(on: .desktop) ? "true" : "false") )
                    .font(.system(size: 12))
                ForEach(model.bookmarkAttributes, id: \.self) { attr in
                    Text(entry.formattedValue(for: attr))
                        .font(.system(size: 12))
                }

            }
        }
        .navigationTitle("\(model.bookmarks.count) Bookmarks")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingDestructiveAlert = true
                } label: {
                    Text("Delete All")
                }
            }
        }
        .alert("Confirm Delete", isPresented: $showingDestructiveAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                model.deleteAll()
            }
        } message: {
            Text("Are you sure you want to delete all bookmarks? This action cannot be undone.")
        }
    }

}

extension BookmarkEntity {

    func formattedValue(for key: String) -> String {
        key + ": \'" + String(describing: value(forKey: key)) + "'"
    }
}

class BookmarksDebugViewModel: ObservableObject {

    @Published var bookmarks = [BookmarkEntity]()
    let bookmarkAttributes: [String]

    let database: CoreDataDatabase
    let context: NSManagedObjectContext

    /// All entities within the bookmarks store must exist under this root level folder. Because this value is used so frequently, it is cached here.
    private var rootLevelFolderObjectID: NSManagedObjectID?

    /// All favorites must additionally be children of this special folder. Because this value is used so frequently, it is cached here.
    private var favoritesFolderObjectID: NSManagedObjectID?

    init() {
        database = BookmarksDatabase.make()
        database.loadStore()

        context = database.makeContext(concurrencyType: .mainQueueConcurrencyType)
        bookmarkAttributes = Array(BookmarkEntity.entity(in: context).attributesByName.keys)

        fetch()
    }

    func fetch() {

        let fetchRequest = BookmarkEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(BookmarkEntity.title),
                                                         ascending: false)]
        fetchRequest.returnsObjectsAsFaults = false
        bookmarks = (try? context.fetch(fetchRequest)) ?? []
    }

    func deleteAll() {
        resetBookmarks { [weak self] _ in
            self?.fetch()
        }
    }

    private func cacheReadOnlyTopLevelBookmarksFolders() {
        context.performAndWait {
            guard let folder = BookmarkUtils.fetchRootFolder(context) else {
                fatalError("Top level folder missing")
            }

            self.rootLevelFolderObjectID = folder.objectID
            let favoritesFolderUUID = AppDependencyProvider.shared.appSettings.favoritesDisplayMode.displayedFolder.rawValue
            self.favoritesFolderObjectID = BookmarkUtils.fetchFavoritesFolder(withUUID: favoritesFolderUUID, in: context)?.objectID
        }
    }

    private func applyChangesAndSave(changes: @escaping (NSManagedObjectContext) throws -> Void,
                                     onError: @escaping (Error) -> Void,
                                     onDidSave: @escaping () -> Void) {
        let maxRetries = 2
        var iteration = 0

        context.perform { [weak self] in
            guard let context = self?.context else { return }

            var lastError: Error?
            while iteration < maxRetries {
                do {
                    try changes(context)

                    try context.save()
                    onDidSave()
                    return
                } catch {
                    let nsError = error as NSError
                    if nsError.code == NSManagedObjectMergeError || nsError.code == NSManagedObjectConstraintMergeError {
                        iteration += 1
                        lastError = error
                        context.reset()
                    } else {
                        onError(error)
                        return
                    }
                }
            }

            if let lastError = lastError {
                onError(lastError)
            }
        }
    }

    private func resetBookmarks(completionHandler: @escaping (Error?) -> Void) {
        applyChangesAndSave { context in
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "BookmarkEntity")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            try context.execute(deleteRequest)

            BookmarkUtils.prepareFoldersStructure(in: context)

        } onError: { error in
            assertionFailure("Failed to reset bookmarks: \(error)")
            DispatchQueue.main.async {
                completionHandler(error)
            }
        } onDidSave: { [self] in
            DispatchQueue.main.async {
                self.cacheReadOnlyTopLevelBookmarksFolders()
                completionHandler(nil)
            }
        }
    }

}
