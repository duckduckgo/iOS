//
//  RemoteMessagingStore.swift
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

import Foundation
import Common
import CoreData
import Core
import BrowserServicesKit
import RemoteMessaging

final class RemoteMessagingStore: RemoteMessagingStoring {

    private enum RemoteMessageStatus: Int16 {
        case scheduled
        case dismissed
        case done
    }

    private enum Constants {
        static let privateContextName = "RemoteMessaging"
        static let remoteMessagingConfigManagedObject = "RemoteMessagingConfigManagedObject"
        static let remoteMessageManagedObject = "RemoteMessageManagedObject"
    }

    let context: NSManagedObjectContext
    let notificationCenter: NotificationCenter

    init(context: NSManagedObjectContext = Database.shared.makeContext(concurrencyType: .privateQueueConcurrencyType, name: Constants.privateContextName),
         notificationCenter: NotificationCenter = .default) {
        self.context = context
        self.notificationCenter = notificationCenter
    }

    func saveProcessedResult(_ processorResult: RemoteMessagingConfigProcessor.ProcessorResult) {
        os_log("Remote messaging config - save processed version: %d", log: .remoteMessaging, type: .debug, processorResult.version)
        saveRemoteMessagingConfig(withVersion: processorResult.version)

        if let remoteMessage = processorResult.message {
            deleteScheduledRemoteMessages()
            save(remoteMessage: remoteMessage)

            DispatchQueue.main.async {
                self.notificationCenter.post(name: RemoteMessaging.Notifications.remoteMessagesDidChange, object: nil)
            }
        } else {
            deleteScheduledRemoteMessages()
        }
    }
}

// MARK: - RemoteMessagingConfigManagedObject Public Interface

extension RemoteMessagingStore {

    func fetchRemoteMessagingConfig() -> RemoteMessagingConfig? {
        var config: RemoteMessagingConfig?
        context.performAndWait {
            let fetchRequest: NSFetchRequest<RemoteMessagingConfigManagedObject>
                    = RemoteMessagingConfigManagedObject.fetchRequest()
            fetchRequest.fetchLimit = 1
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "version", ascending: false)]

            guard let results = try? context.fetch(fetchRequest) else {
                return
            }
            if let remoteMessagingConfigManagedObject = results.first {
                config = RemoteMessagingConfig(version: remoteMessagingConfigManagedObject.version,
                                               invalidate: remoteMessagingConfigManagedObject.invalidate,
                                               evaluationTimestamp: remoteMessagingConfigManagedObject.evaluationTimestamp)
            }
        }

        return config
    }

}

// MARK: - RemoteMessagingConfigManagedObject Private Interface

extension RemoteMessagingStore {

    private func saveRemoteMessagingConfig(withVersion version: Int64) {
        context.performAndWait {
            let fetchRequest: NSFetchRequest<RemoteMessagingConfigManagedObject> = RemoteMessagingConfigManagedObject.fetchRequest()
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "version == %lld", version)

            if let results = try? context.fetch(fetchRequest), let result = results.first {
                result.evaluationTimestamp = Date()
                result.invalidate = false
            } else {
                let managedObject = NSEntityDescription.insertNewObject(forEntityName: Constants.remoteMessagingConfigManagedObject, into: context)
                guard let remoteMessagingConfigManagedObject = managedObject as? RemoteMessagingConfigManagedObject else {
                    return
                }
                remoteMessagingConfigManagedObject.version = version
                remoteMessagingConfigManagedObject.evaluationTimestamp = Date()
                remoteMessagingConfigManagedObject.invalidate = false
            }

            do {
                try context.save()
            } catch {
                Pixel.fire(pixel: .dbRemoteMessagingSaveConfigError, error: error)
                os_log("Failed to save remote messaging config: %@",
                       log: OSLog.remoteMessaging,
                       type: .error, error.localizedDescription)
            }
        }
    }

    private func invalidateRemoteMessagingConfigs() {
        context.performAndWait {
            let fetchRequest: NSFetchRequest<RemoteMessagingConfigManagedObject> = RemoteMessagingConfigManagedObject.fetchRequest()
            fetchRequest.returnsObjectsAsFaults = false

            guard let results = try? context.fetch(fetchRequest) else { return }

            results.forEach { $0.invalidate = true }

            do {
                try context.save()
            } catch {
                Pixel.fire(pixel: .dbRemoteMessagingInvalidateConfigError, error: error)
                os_log("Failed to save remote messaging config entity invalidate: %@",
                       log: OSLog.remoteMessaging,
                       type: .error, error.localizedDescription)
            }
        }
    }
}

// MARK: - RemoteMessageManagedObject Public Interface

extension RemoteMessagingStore {

    func fetchScheduledRemoteMessage() -> RemoteMessageModel? {
        var scheduledRemoteMessage: RemoteMessageModel?
        context.performAndWait {
            let fetchRequest: NSFetchRequest<RemoteMessageManagedObject> = RemoteMessageManagedObject.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "status == %i", RemoteMessageStatus.scheduled.rawValue)
            fetchRequest.returnsObjectsAsFaults = false

            guard let results = try? context.fetch(fetchRequest) else { return }

            for remoteMessageManagedObject in results {
                guard let message = remoteMessageManagedObject.message,
                      let remoteMessage = RemoteMessageMapper.fromString(message),
                      let id = remoteMessageManagedObject.id
                else {
                    continue
                }

                scheduledRemoteMessage = RemoteMessageModel(id: id, content: remoteMessage.content, matchingRules: [], exclusionRules: [])
                break
            }
        }
        return scheduledRemoteMessage
    }

    func fetchRemoteMessage(withId id: String) -> RemoteMessageModel? {
        var remoteMessage: RemoteMessageModel?
        context.performAndWait {
            let fetchRequest: NSFetchRequest<RemoteMessageManagedObject> = RemoteMessageManagedObject.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            fetchRequest.returnsObjectsAsFaults = false

            guard let results = try? context.fetch(fetchRequest) else { return }

            for remoteMessageManagedObject in results {
                guard let message = remoteMessageManagedObject.message,
                      let remoteMessageMapped = RemoteMessageMapper.fromString(message),
                      let id = remoteMessageManagedObject.id
                else {
                    continue
                }

                remoteMessage = RemoteMessageModel(id: id, content: remoteMessageMapped.content, matchingRules: [], exclusionRules: [])
                break
            }
        }
        return remoteMessage
    }

    func hasShownRemoteMessage(withId id: String) -> Bool {
        var shown: Bool = true
        context.performAndWait {
            let fetchRequest: NSFetchRequest<RemoteMessageManagedObject> = RemoteMessageManagedObject.fetchRequest()
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)

            guard let results = try? context.fetch(fetchRequest) else { return }

            if let result = results.first {
                shown = result.shown
            }
        }
        return shown
    }

    func hasDismissedRemoteMessage(withId id: String) -> Bool {
        var dismissed: Bool = true
        context.performAndWait {
            let fetchRequest: NSFetchRequest<RemoteMessageManagedObject> = RemoteMessageManagedObject.fetchRequest()
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "status == %i", RemoteMessageStatus.dismissed.rawValue)

            guard let results = try? context.fetch(fetchRequest) else { return }

            if results.first != nil {
                dismissed = true
            }
        }
        return dismissed
    }

    func dismissRemoteMessage(withId id: String) {
        context.performAndWait {
            updateRemoteMessage(withId: id, toStatus: .dismissed)
            invalidateRemoteMessagingConfigs()
        }
    }

    func fetchDismissedRemoteMessageIds() -> [String] {
        var dismissedMessageIds: [String] = []
        context.performAndWait {
            let fetchRequest: NSFetchRequest<RemoteMessageManagedObject> = RemoteMessageManagedObject.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "status == %i", RemoteMessageStatus.dismissed.rawValue)
            fetchRequest.returnsObjectsAsFaults = false

            do {
                let results = try context.fetch(fetchRequest)
                dismissedMessageIds = results.compactMap { $0.id }
            } catch {
                os_log("Failed to fetch dismissed remote messages: %@", log: .remoteMessaging, type: .error, error.localizedDescription)
            }
        }
        return dismissedMessageIds
    }

    func updateRemoteMessage(withId id: String, asShown shown: Bool) {
        context.performAndWait {
            let fetchRequest: NSFetchRequest<RemoteMessageManagedObject> = RemoteMessageManagedObject.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            fetchRequest.returnsObjectsAsFaults = false

            guard let results = try? context.fetch(fetchRequest) else { return }

            results.forEach { $0.shown = shown }
            do {
                try context.save()
            } catch {
                Pixel.fire(pixel: .dbRemoteMessagingUpdateMessageShownError, error: error)
                os_log("Failed to save message update as shown", log: .remoteMessaging, type: .error)
            }
        }
    }
}

// MARK: - RemoteMessageManagedObject Private Interface

extension RemoteMessagingStore {

    private func save(remoteMessage: RemoteMessageModel) {
        context.performAndWait {
            let managedObject = NSEntityDescription.insertNewObject(forEntityName: Constants.remoteMessageManagedObject, into: context)
            guard let remoteMessageManagedObject = managedObject as? RemoteMessageManagedObject else { return }

            remoteMessageManagedObject.id = remoteMessage.id
            remoteMessageManagedObject.message = RemoteMessageMapper.toString(remoteMessage) ?? ""
            remoteMessageManagedObject.status = RemoteMessageStatus.scheduled.rawValue
            remoteMessageManagedObject.shown = false

            do {
                try context.save()
            } catch {
                Pixel.fire(pixel: .dbRemoteMessagingSaveMessageError, error: error)
                os_log("Failed to save remote message entity: %@", log: OSLog.remoteMessaging, type: .error, error.localizedDescription)
            }
        }
    }

    private func updateRemoteMessage(withId id: String, toStatus status: RemoteMessageStatus) {
        context.performAndWait {
            let fetchRequest: NSFetchRequest<RemoteMessageManagedObject> = RemoteMessageManagedObject.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            fetchRequest.returnsObjectsAsFaults = false

            guard let results = try? context.fetch(fetchRequest) else { return }

            results.forEach { $0.status = status.rawValue }

            do {
                try context.save()
            } catch {
                Pixel.fire(pixel: .dbRemoteMessagingUpdateMessageStatusError, error: error)
                os_log("Error saving updateMessageStatus", log: .remoteMessaging, type: .error)
            }
        }
    }

    private func deleteScheduledRemoteMessages() {
        context.performAndWait {
            let fetchRequest: NSFetchRequest<RemoteMessageManagedObject> = RemoteMessageManagedObject.fetchRequest()
            fetchRequest.returnsObjectsAsFaults = false
            fetchRequest.predicate = NSPredicate(format: "status == %i", RemoteMessageStatus.scheduled.rawValue)

            let results = try? context.fetch(fetchRequest)
            results?.forEach {
                context.delete($0)
            }
            do {
                try context.save()
            } catch {
                Pixel.fire(pixel: .dbRemoteMessagingDeleteScheduledMessageError, error: error)
                os_log("Error deleting scheduled remote messages", log: .remoteMessaging, type: .error)
            }
        }
    }
}

// MARK: - MessageMapper

private struct RemoteMessageMapper {

    static func toString(_ remoteMessage: RemoteMessageModel?) -> String? {
        guard let message = remoteMessage,
              let encodedData = try? JSONEncoder().encode(message),
              let jsonString = String(data: encodedData, encoding: .utf8) else { return nil }
        return jsonString
    }

    static func fromString(_ payload: String) -> RemoteMessageModel? {
        guard let data = payload.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(RemoteMessageModel.self, from: data)
    }
}
