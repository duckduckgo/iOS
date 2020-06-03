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

class TabPreviewsSource {
    
    private var cache = [String: UIImage]()
    
    func prepare() {
        ensurePreviewStoreDirectoryExists()
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
        
        try? FileManager.default.removeItem(at: url)
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
    
    private var previewStoreDir: URL? {
        guard var cachesDirURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }
        cachesDirURL.appendPathComponent("Previews", isDirectory: true)
        return cachesDirURL
    }
    
    private func ensurePreviewStoreDirectoryExists() {
        guard let url = previewStoreDir else { return }
        if !FileManager.default.fileExists(atPath: url.absoluteString, isDirectory: nil) {
            try? FileManager.default.createDirectory(at: url,
                                                     withIntermediateDirectories: false,
                                                     attributes: nil)
        }
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
