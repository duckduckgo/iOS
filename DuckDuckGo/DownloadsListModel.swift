//
//  DownloadsListModel.swift
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

struct DownloadsListModel {
    var downloads: [DownloadItem]
    
    init() {
        print("M: init")
        downloads = [DownloadItem(filename: "book.pdf"),
                     DownloadItem(filename: "ticket.pdf"),
                     DownloadItem(filename: "archive.zip"),
                     DownloadItem(filename: "song.mp3")]
        
        downloads.append(contentsOf: downloadsDirectoryItems())
    }

    mutating func deleteItemWithIdentifier(_ identifier: String) {
        print("M: deleteItem()")
        guard let downloadToBeRemoved = downloads.first(where: { $0.filename == identifier }),
        let index = downloads.firstIndex(of: downloadToBeRemoved) else { return }
        
        downloads.remove(at: index)
    }
    
    private func downloadsDirectoryItems() -> [DownloadItem] {
        print("M: downloadsDirectoryItems()")
        return downloadsDirectoryContents().map { url in
            DownloadItem(url: url)
        }
    }
    
    private func downloadsDirectoryContents() -> [URL] {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let directoryContents: [URL]
        
        print("Put some files in: \(documentsUrl)")
        
        do {
            // Get the directory contents urls (including subfolders urls)
            directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil)
//            print(directoryContents)

            // if you want to filter the directory contents you can do like this:
//            let mp3Files = directoryContents.filter{ $0.pathExtension == "mp3" }
//            print("mp3 urls:",mp3Files)
//            let mp3FileNames = mp3Files.map{ $0.deletingPathExtension().lastPathComponent }
//            print("mp3 list:", mp3FileNames)

        } catch {
            print(error)
            directoryContents = []
        }
        
        return directoryContents
    }
}
