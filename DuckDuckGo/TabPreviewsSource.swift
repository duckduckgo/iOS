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
    
    func update(preview: UIImage, forTab tab: Tab) {
        cache[tab.uid] = preview
        store(preview: preview, forTab: tab)
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
    
    private func previewLocation(for tab: Tab) -> URL? {
        guard var cachesDirURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }
        cachesDirURL.appendPathComponent("Previews", isDirectory: true)
        
        do {
        try FileManager.default.createDirectory(at: cachesDirURL, withIntermediateDirectories: false, attributes: nil)
        } catch {
            print(error)
        }
        print("--> caches: \(cachesDirURL)")
        cachesDirURL.appendPathComponent("\(tab.uid).png")
        return cachesDirURL
    }
    
    private func store(preview: UIImage, forTab tab: Tab) {
        guard let url = previewLocation(for: tab),
            let data = preview.pngData() else { return }
        
        do {
//            let file = FileHandle(forWritingTo: url)
            try data.write(to: url)
        } catch {
            print(error)
        }
    }
    
    private func loadPreview(forTab tab: Tab) -> UIImage? {
        guard let url = previewLocation(for: tab),
            let data = try? Data(contentsOf: url) else { return nil }
        
        return UIImage(data: data)
    }
}
