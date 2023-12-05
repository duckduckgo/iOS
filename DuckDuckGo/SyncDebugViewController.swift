//
//  SyncDebugViewController.swift
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

import UIKit
import BackgroundTasks
import Core
import Persistence
import Bookmarks
import DDGSync
import Combine

class SyncDebugViewController: UITableViewController {

    private let titles = [
        Sections.info: "Info",
        Sections.models: "Models",
        Sections.environment: "Environment"
    ]

    enum Sections: Int, CaseIterable {

        case info
        case models
        case environment

    }

    enum InfoRows: Int, CaseIterable {

        case syncNow
        case logOut
        case toggleFavoritesDisplayMode
        case resetFaviconsFetcherOnboardingDialog

    }

    enum ModelRows: Int, CaseIterable {

        case bookmarks

    }

    enum EnvironmentRows: Int, CaseIterable {

        case toggle

    }

    private let bookmarksDatabase: CoreDataDatabase
    private let sync: DDGSyncing

    var syncCancellable: Cancellable?

    init?(coder: NSCoder,
          sync: DDGSyncing,
          bookmarksDatabase: CoreDataDatabase) {

        self.sync = sync
        self.bookmarksDatabase = bookmarksDatabase

        super.init(coder: coder)

        syncCancellable = sync.isSyncInProgressPublisher.receive(on: DispatchQueue.main).sink { [weak self] progress in
            if progress == false {
                self?.tableView.reloadData()
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.allCases.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Sections(rawValue: section) else { return nil }
        return titles[section]
    }

    // swiftlint:disable:next cyclomatic_complexity
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        cell.detailTextLabel?.text = nil
        
        switch Sections(rawValue: indexPath.section) {

        case .info:
            switch InfoRows(rawValue: indexPath.row) {
            case .syncNow:
                cell.textLabel?.text = "Sync now"
            case .logOut:
                cell.textLabel?.text = "Log out of sync in 10 seconds"
            case .toggleFavoritesDisplayMode:
                cell.textLabel?.text = "Toggle favorites display mode in 10 seconds"
            case .resetFaviconsFetcherOnboardingDialog:
                cell.textLabel?.text = "Reset Favicons Fetcher onboarding dialog"
            case .none:
                break
            }

        case .models:
            switch ModelRows(rawValue: indexPath.row) {
            case .bookmarks:
                cell.textLabel?.text = "Bookmarks to sync"

                let context = bookmarksDatabase.makeContext(concurrencyType: .mainQueueConcurrencyType)
                let fr = BookmarkEntity.fetchRequest()
                fr.predicate = NSPredicate(format: "%K != nil", #keyPath(BookmarkEntity.modifiedAt))

                let result = try? context.count(for: fr)
                if let result {
                    cell.detailTextLabel?.text = "\(result)"
                } else {
                    cell.detailTextLabel?.text = "Error"
                }

            case .none:
                break
            }

        case .environment:
            switch EnvironmentRows(rawValue: indexPath.row) {
            case .toggle:
                let targetEnvironment: ServerEnvironment = sync.serverEnvironment == .production ? .development : .production
                cell.textLabel?.text = sync.serverEnvironment.description
                cell.detailTextLabel?.text = "Click to switch to \(targetEnvironment)"

            case .none:
                break
            }

        default: break
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Sections(rawValue: section) {
        case .info: return InfoRows.allCases.count
        case .models: return ModelRows.allCases.count
        case .environment: return EnvironmentRows.allCases.count
        case .none: return 0
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Sections(rawValue: indexPath.section) {
        case .info:
            switch InfoRows(rawValue: indexPath.row) {
            case .syncNow:
                sync.scheduler.requestSyncImmediately()
            case .logOut:
                Task {
                    try await Task.sleep(nanoseconds: UInt64(10e9))
                    try await sync.disconnect()
                }
            case .toggleFavoritesDisplayMode:
                Task { @MainActor in
                    try await Task.sleep(nanoseconds: UInt64(10e9))
                    var displayMode = AppDependencyProvider.shared.appSettings.favoritesDisplayMode
                    if displayMode.isDisplayUnified {
                        displayMode = .displayNative(.mobile)
                    } else {
                        displayMode = .displayUnified(native: .mobile)
                    }
                    AppDependencyProvider.shared.appSettings.favoritesDisplayMode = displayMode
                    NotificationCenter.default.post(name: AppUserDefaults.Notifications.favoritesDisplayModeChange, object: nil)
                }
            case .resetFaviconsFetcherOnboardingDialog:
                var udWrapper = UserDefaultsWrapper(key: .syncDidPresentFaviconsFetcherOnboarding, defaultValue: false)
                udWrapper.wrappedValue = false

            default: break
            }
        case .environment:
            switch EnvironmentRows(rawValue: indexPath.row) {
            case .toggle:
                let targetEnvironment: ServerEnvironment = sync.serverEnvironment == .production ? .development : .production
                sync.updateServerEnvironment(targetEnvironment)
                UserDefaults.standard.set(targetEnvironment.description, forKey: UserDefaultsWrapper<String>.Key.syncEnvironment.rawValue)
                tableView.reloadSections(.init(integer: indexPath.section), with: .automatic)
            default: break
            }
        default: break
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

}
