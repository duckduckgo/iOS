//
//  FileSizeDebugViewController.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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
import UIKit
import Core
import GRDB

struct FileItem {
    let url: URL
    let name: String
    let isDirectory: Bool
    let size: Int?
    
    var isEmpty: Bool { (size ?? 0) == 0 }
}

class FileSizeDebugViewController: UITableViewController {
    
    var currentURL: URL?
    var rootURL: URL?
    private var model: [FileItem] = []
    private static let byteCountFormatter = ByteCountFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FileSizeDebugViewController.byteCountFormatter.countStyle = .file
        
        if let url = currentURL {
            model = loadModel(for: url)
        } else {
            model = makeRootModel()
        }

        tableView.reloadData()
    }
    
    private func makeRootModel() -> [FileItem] {
        var rootModel: [FileItem] = [makeFileItem(for: applicationContainerURL, name: "Application Container")]
        
        if let url = sharedContentBlockerContainerURL {
            rootModel.append(makeFileItem(for: url, name: "Shared Content Blocker Container"))
        }
        
        if let url = sharedBookmarksContainerURL {
            rootModel.append(makeFileItem(for: url, name: "Shared Bookmarks Container"))
        }
        
        if let url = sharedDatabaseContainerURL {
            rootModel.append(makeFileItem(for: url, name: "Shared Database Container"))
        }
        
        return rootModel
    }
    
    private var applicationContainerURL: URL {
        let documentsURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsURL.deletingLastPathComponent()
    }
    
    private var sharedContentBlockerContainerURL: URL? {
        let identifier = "\(Global.groupIdPrefix).contentblocker"
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)
    }
    
    private var sharedBookmarksContainerURL: URL? {
        let identifier = BookmarksDatabase.Constants.bookmarksGroupID
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)
    }
    
    private var sharedDatabaseContainerURL: URL? {
        let identifier = "\(Global.groupIdPrefix).database"
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)
    }
    
    private func loadModel(for url: URL) -> [FileItem] {
        let itemsAtURL = (try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)) ?? []
        
        return itemsAtURL.map { makeFileItem(for: $0) }.sorted { $0.name < $1.name }
    }
    
    private func makeFileItem(for url: URL, name: String? = nil) -> FileItem {
        return FileItem(url: url,
                        name: name ?? url.lastPathComponent,
                        isDirectory: url.isDirectory,
                        size: url.sizeInBytes)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = model[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = FileSizeDebugViewController.byteCountFormatter.string(for: item.size)
        
        cell.accessoryType = item.isDirectory ? .disclosureIndicator : .none
        cell.selectionStyle = item.isDirectory ? .default : .none
        
        if item.isDirectory {
            cell.imageView?.image =  item.isEmpty ? UIImage(systemName: "folder") : UIImage(systemName: "folder.fill")
        } else {
            cell.imageView?.image = nil
        }

        return cell
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = model[indexPath.row]
        
        if item.url.isDirectory {
            let storyboard = UIStoryboard(name: "Debug", bundle: Bundle.main)
            if let viewController = storyboard.instantiateViewController(identifier: "FileSizeDebug") as? FileSizeDebugViewController {
                viewController.currentURL = item.url
                viewController.rootURL = rootURL ?? item.url
                viewController.navigationItem.title = item.name
                navigationController?.pushViewController(viewController, animated: true)
            }
        } else {
            if item.name.hasSuffix("db") || item.name.hasSuffix("sqlite") || item.name.hasSuffix("sqlite3") {
                do {
                    let dbPool = try DatabasePool(path: item.url.absoluteString)
                    var fileContent: String = ""
                    var tableNames: [String] = []

                    try dbPool.read { db in
                        let rows = try Row.fetchCursor(db, sql: "SELECT name FROM sqlite_master WHERE type='table'")
                        while let row = try rows.next() {
                            if let name = row["name"] as String? {
                                tableNames.append(name)
                            }
                        }
                    }

                    for table in tableNames {
                        fileContent.append("Contents of table: \(table)\n")
                        try dbPool.read { db in
                            let rows = try Row.fetchAll(db, sql: "SELECT * FROM \(table)")
                            if rows.isEmpty {
                                fileContent.append("Table is empty")
                            } else {
                                for row in rows {
                                    fileContent.append("\(row.description)\n\n")
                                }
                            }
                        }
                        fileContent.append("\n\n")
                    }

                    previewFileContents(fileContent, itemName: item.name)

                } catch {
                    previewFileContents(error.localizedDescription, itemName: item.name)
                }
            } else if item.name.hasSuffix("plist") {
                guard let data = try? Data(contentsOf: item.url.absoluteURL) else {
                    previewFileContents("No content", itemName: item.name)
                    return
                }

                var fileContent: String = ""

                if let plistArray = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [AnyObject] {
                    for item in plistArray {
                        print(item)
                        fileContent.append("\(item) \n")
                    }
                } else if let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: AnyObject] {
                    for (key, value) in plist {
                        print("\(key) : \(value)")
                        fileContent.append("\(key) : \(value) \n")
                    }
                }

                previewFileContents(fileContent, itemName: item.name)
            }
        }
    }

    private func previewFileContents(_ text: String, itemName: String) {
        let storyboard = UIStoryboard(name: "Debug", bundle: Bundle.main)
        if let viewController = storyboard.instantiateViewController(identifier: "FileTextPreviewDebug") as? FileTextPreviewDebugViewController {
            viewController.textContent = text
            viewController.navigationItem.title = itemName
            navigationController?.pushViewController(viewController, animated: true)
        }

    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let currentURL = currentURL, let rootURL = rootURL else {
            return nil
        }
        
        let currentPathFromRoot = currentURL.absoluteString.dropFirst(rootURL.absoluteString.count)
        return "/\(currentPathFromRoot.removingPercentEncoding!)"
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let totalSizeOfCurrentDirectory = currentURL?.sizeInBytes else {
            return nil
        }
        
        let formattedSize = FileSizeDebugViewController.byteCountFormatter.string(for: totalSizeOfCurrentDirectory) ?? "<unknown>"
        
        return "Total size: \(formattedSize)"
    }
}

private extension URL {
    
    var isDirectory: Bool {
        let urlForDirectory = (try? resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
        let isReachable = (try? checkResourceIsReachable()) ?? false
        return urlForDirectory && isReachable
    }
    
    var sizeInBytes: Int? {
        if isDirectory {
            return totalDirectoryAllocatedSize()
        } else {
            return try? resourceValues(forKeys: [.totalFileAllocatedSizeKey]).totalFileAllocatedSize
        }
    }
    
    func totalDirectoryAllocatedSize() -> Int? {
        guard isDirectory else { return nil }
     
        guard let urls = FileManager.default.enumerator(at: self, includingPropertiesForKeys: nil)?.allObjects as? [URL] else { return 0 }

        return urls.lazy.reduce(0) {
            ((try? $1.resourceValues(forKeys: [.totalFileAllocatedSizeKey]).totalFileAllocatedSize) ?? 0) + $0
        }
    }
}
