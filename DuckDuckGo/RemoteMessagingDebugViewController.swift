//
//  RemoteMessagingDebugViewController.swift
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
import RemoteMessaging
import Core
import Combine
import Persistence

class RemoteMessagingDebugViewController: UIHostingController<RemoteMessagingDebugRootView> {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: RemoteMessagingDebugRootView())
    }

}

struct RemoteMessagingDebugRootView: View {

    @ObservedObject var model = RemoteMessagingDebugViewModel()

    var body: some View {
        List {
            Section {
                ForEach(model.messages, id: \.id) { entry in
                    VStack(alignment: .leading) {
                        Text(entry.id ?? "")
                            .font(.system(size: 14))
                        Text(entry.message ?? "")
                            .font(.system(size: 12))
                        Text("Shown: \(String(describing: entry.shown))")
                            .font(.system(size: 10))
                        Text("Status: \(statusString(for: entry.status))")
                            .font(.system(size: 10))
                    }
                }
            } footer: {
                Text("This list contains messages that have been shown plus at most 1 message that is scheduled for showing. There may be more messages in the config that will be presented, but they haven't been processed yet.")
            }
        }
        .navigationTitle("\(model.messages.count) Remote Messages")
        .toolbar {
                Button("Delete All", role: .destructive) {
                    model.deleteAll()
                }
        }
    }

    /// This should be kept in sync with `RemoteMessageStatus` private enum from BSK
    private func statusString(for status: NSNumber?) -> String {
        switch status?.int16Value {
        case 0:
            return "scheduled"
        case 1:
            return "dismissed"
        case 2:
            return "done"
        default:
            return "unknown"
        }
    }
}

class RemoteMessagingDebugViewModel: ObservableObject {

    @Published var messages: [RemoteMessageManagedObject] = []

    let database: CoreDataDatabase

    init() {
        database = Database.shared
        fetchMessages()
    }

    func deleteAll() {
        let context = database.makeContext(concurrencyType: .mainQueueConcurrencyType)
        context.deleteAll(entityDescriptions: [
            RemoteMessageManagedObject.entity(in: context),
            RemoteMessagingConfigManagedObject.entity(in: context)
        ])

        do {
            try context.save()
        } catch {
            assertionFailure("Failed to save after delete all")
        }
        fetchMessages()
    }

    func fetchMessages() {
        let context = database.makeContext(concurrencyType: .mainQueueConcurrencyType)
        let fetchRequest = RemoteMessageManagedObject.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        messages = (try? context.fetch(fetchRequest)) ?? []
    }
}
