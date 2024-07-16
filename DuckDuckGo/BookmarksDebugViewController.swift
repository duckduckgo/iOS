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

class BookmarksDebugViewController: UIHostingController<BookmarksDebugRootView> {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: BookmarksDebugRootView())
    }

}

struct BookmarksDebugRootView: View {

    @ObservedObject var model = BookmarksDebugViewModel()

    var body: some View {
        List(model.bookmarks, id: \.id) { entry in
            VStack(alignment: .leading) {
                Text(entry.title ?? "")
                    .font(.system(size: 16))
                ForEach(model.bookmarkAttributes, id: \.self) { attr in
                    Text(entry.formattedValue(for: attr))
                        .font(.system(size: 12))
                }

            }
        }
        .navigationTitle("\(model.bookmarks.count) Bookmarks")
        .toolbar {
            if #available(iOS 15, *) {
                Button("Delete All", role: .destructive) {
                    model.deleteAll()
                }
            }
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

    init() {
        database = BookmarksDatabase.make()
        database.loadStore()

        let context = database.makeContext(concurrencyType: .mainQueueConcurrencyType)
        bookmarkAttributes = Array(BookmarkEntity.entity(in: context).attributesByName.keys)

        fetch()
    }

    func deleteAll() {
        let context = database.makeContext(concurrencyType: .mainQueueConcurrencyType)
        let fetchRequest = BookmarkEntity.fetchRequest()
        let items = try? context.fetch(fetchRequest)
        items?.forEach { obj in
            context.delete(obj)
        }
        do {
            try context.save()
        } catch {
            assertionFailure("Failed to save after delete all")
        }
        fetch()
    }

    func fetch() {
        let context = database.makeContext(concurrencyType: .mainQueueConcurrencyType)
        let fetchRequest = BookmarkEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(BookmarkEntity.title),
                                                         ascending: false)]
        fetchRequest.returnsObjectsAsFaults = false
        bookmarks = (try? context.fetch(fetchRequest)) ?? []
    }
}
