//
//  TabPreviewsSource.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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
import Core

class TabPreviewsSource {
    
    struct Constants {
        static let previewsDirectoryName = "Previews"
    }
    
    private var cache = [String: UIImage]()
    
    private lazy var tabSettings: TabSwitcherSettings = DefaultTabSwitcherSettings()
    
    fileprivate var previewStoreDir: URL?
    private var legacyPreviewStoreDir: URL?
    
    init(storeDir: URL? = TabPreviewsSource.previewStoreDir,
         legacyDir: URL? = TabPreviewsSource.legacyPreviewStoreDir) {
        previewStoreDir = storeDir
        legacyPreviewStoreDir = legacyDir
    }
    
    func prepare() {
        ensurePreviewStoreDirectoryExists()
        migratePreviewStoreDirectoryFromCache()
        
        // Remove already stored previews for tabs that were not yet closed by the user
        if !tabSettings.isGridViewEnabled {
            removeAllPreviews()
        }
    }
    
    func update(preview: UIImage, forTab tab: Tab) {
        cache[tab.uid] = preview
        store(preview: preview, forTab: tab)
        tab.didUpdatePreview()
    }
    
    func preview(for tab: Tab) -> UIImage? {
        if let preview = cache[tab.uid] {
            return preview
        }
        
        guard let preview = loadPreview(forTab: tab) else {
            return nil
        }
        
        cache[tab.uid] = preview
        return preview
    }
    
    func removePreview(forTab tab: Tab) {
        guard let url = previewLocation(for: tab) else { return }
        
        cache[tab.uid] = nil

        do {
            if FileManager.default.fileExists(atPath: url.filePath) {
                try FileManager.default.removeItem(at: url)
            }
        } catch {
            Pixel.fire(pixel: .cachedTabPreviewRemovalError, error: error)
        }
    }
    
    func removeAllPreviews() {
        cache.removeAll()
        guard let dirUrl = previewStoreDir else { return }
        
        if let previews = try? FileManager.default.contentsOfDirectory(at: dirUrl, includingPropertiesForKeys: nil) {
            for previewUrl in previews {
                try? FileManager.default.removeItem(at: previewUrl)
            }
        }
    }
    
    fileprivate func cleanupCache() {
        cache.removeAll()
    }

    func totalStoredPreviews() -> Int? {
        guard let directory = previewStoreDir else { return nil }

        let contents = try? FileManager.default.contentsOfDirectory(atPath: directory.path)
        return contents?.count
    }
    
    static fileprivate var previewStoreDir: URL? {
        guard var cachesDirURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { return nil }
        cachesDirURL.appendPathComponent(Constants.previewsDirectoryName, isDirectory: true)
        return cachesDirURL
    }
    
    static private var legacyPreviewStoreDir: URL? {
        guard var cachesDirURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }
        cachesDirURL.appendPathComponent(Constants.previewsDirectoryName, isDirectory: true)
        return cachesDirURL
    }
    
    private func ensurePreviewStoreDirectoryExists() {
        guard var url = previewStoreDir else { return }
        
        // Create Application Support Dir if needed.
        let parentDirURL = url.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: parentDirURL.path, isDirectory: nil) {
            try? FileManager.default.createDirectory(at: parentDirURL,
                                                     withIntermediateDirectories: false,
                                                     attributes: nil)
        }
        
        if !FileManager.default.fileExists(atPath: url.path, isDirectory: nil) {
            
            try? FileManager.default.createDirectory(at: url,
                                                     withIntermediateDirectories: false,
                                                     attributes: nil)
            
            // Exclude Previews Dir from backup
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            try? url.setResourceValues(resourceValues)
        }
    }
    
    private func migratePreviewStoreDirectoryFromCache() {
        guard let source = legacyPreviewStoreDir,
            let destination = previewStoreDir else { return }
        
        let contents = (try? FileManager.default.contentsOfDirectory(at: source,
                                                                    includingPropertiesForKeys: nil,
                                                                    options: .skipsSubdirectoryDescendants)) ?? []
        let previews = contents.filter { $0.lastPathComponent.hasSuffix(".png") }
        
        for preview in previews {
            let desitnationURL = destination.appendingPathComponent(preview.lastPathComponent)
            try? FileManager.default.moveItem(at: preview, to: desitnationURL)
        }
        
        try? FileManager.default.removeItem(at: source)
    }
    
    private func previewLocation(for tab: Tab) -> URL? {
        return previewStoreDir?.appendingPathComponent("\(tab.uid).png")
    }
    
    private func store(preview: UIImage, forTab tab: Tab) {
        guard let url = previewLocation(for: tab) else { return }
        
        DispatchQueue.global(qos: .utility).async {
            guard let data = preview.pngData() else { return }
            try? data.write(to: url)
        }
    }
    
    private func loadPreview(forTab tab: Tab) -> UIImage? {
        guard let url = previewLocation(for: tab),
            let data = try? Data(contentsOf: url) else { return nil }
        
        return UIImage(data: data)
    }
}

class TabPreviewsCleanup {
    
    static let shared = TabPreviewsCleanup()
    
    private let lock = NSLock()
    private var isCleaning = false
    
    func startCleanup(with model: TabsModel, source: TabPreviewsSource, completion: @escaping () -> Void = {}) {
        lock.lock()
        guard let storeDir = source.previewStoreDir, !isCleaning else {
            lock.unlock()
            completion()
            return
        }
        isCleaning = true
        lock.unlock()
        
        source.cleanupCache()
        
        let validIDs = Set(model.tabs.map { $0.uid })
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let previews = try? FileManager.default.contentsOfDirectory(at: storeDir, includingPropertiesForKeys: nil) {
                for previewURL in previews where previewURL.lastPathComponent.hasSuffix(".png") {
                    let previewID = previewURL.lastPathComponent.dropLast(4)
                    
                    if !validIDs.contains(String(previewID)) {
                        try? FileManager.default.removeItem(at: previewURL)
                    }
                }
            }
            
            self.lock.lock()
            self.isCleaning = false
            self.lock.unlock()
            
            completion()
        }
    }
    
}
