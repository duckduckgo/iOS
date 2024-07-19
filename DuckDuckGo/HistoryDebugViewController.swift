//
//  HistoryDebugViewController.swift
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
import History
import Core
import Combine
import Persistence

class HistoryDebugViewController: UIHostingController<HistoryDebugRootView> {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: HistoryDebugRootView())
    }

}

struct HistoryDebugRootView: View {

    @ObservedObject var model = HistoryDebugViewModel()

    var body: some View {
        List(model.history, id: \.id) { entry in
            VStack(alignment: .leading) {
                Text(entry.title ?? "")
                    .font(.system(size: 14))
                Text(entry.url?.absoluteString ?? "")
                    .font(.system(size: 12))
                Text(entry.lastVisit?.description ?? "")
                    .font(.system(size: 10))
            }
        }
        .navigationTitle("\(model.history.count) History Items")
        .toolbar {
            Button("Delete All", role: .destructive) {
                model.deleteAll()
            }
        }
    }

}

class HistoryDebugViewModel: ObservableObject {

    @Published var history: [BrowsingHistoryEntryManagedObject] = []

    let database: CoreDataDatabase

    init() {
        database = HistoryDatabase.make()
        database.loadStore()
        fetch()
    }

    func deleteAll() {
        let context = database.makeContext(concurrencyType: .mainQueueConcurrencyType)
        let fetchRequest = BrowsingHistoryEntryManagedObject.fetchRequest()
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
        let fetchRequest = BrowsingHistoryEntryManagedObject.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        history = (try? context.fetch(fetchRequest)) ?? []
    }

}
