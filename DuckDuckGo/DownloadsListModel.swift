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
    var ongoingDownloads: [AnyDownloadListRepresentable] = []
    var completeDownloads: [AnyDownloadListRepresentable] = []
    
    init() {
        print("M: init")
        refetchAllDownloads()
        
    }
    
    mutating func refetchAllDownloads() {
        refetchOngoingDownloads()
        refetchCompleteDownloads()
    }
    
    mutating func refetchOngoingDownloads() {
        let downloadManager = AppDependencyProvider.shared.downloadsManager
        ongoingDownloads = downloadManager.downloadList.map { AnyDownloadListRepresentable($0) }
    }
    
    mutating func refetchCompleteDownloads() {
        let downloadManager = AppDependencyProvider.shared.downloadsManager
        completeDownloads = downloadManager.downloadsDirectoryFiles.map { AnyDownloadListRepresentable($0) }
    }
    
    mutating func deleteDownloadWithIdentifier(_ identifier: String) {
        print("M: deleteItem()")
        guard let downloadToDelete = completeDownloads.first(where: { $0.id == identifier }),
              downloadToDelete.type == .complete
        else { return }
        
//        let index = completeDownloads.firstIndex(of: downloadToBeRemoved) else { return }
//        completeDownloads.remove(at: index)
        
        do {
            let fileManager = FileManager.default
            let initialFilePath = downloadToDelete.filePath
//            let fileURL = URL(fileURLWithPath: initialFilePath)
            
            if fileManager.fileExists(atPath: initialFilePath) {
                try fileManager.removeItem(atPath: initialFilePath)
//                var trashURL: NSURL?
//                try fileManager.trashItem(at: fileURL, resultingItemURL: &trashURL)
                    
                DispatchQueue.main.async {
                    ActionMessageView.present(message: UserText.messageDownloadDeleted(for: downloadToDelete.filename),
                                              actionTitle: UserText.actionGenericUndo) {
//                        guard let trashURL = trashURL as? URL else { return }
//                        if !fileManager.fileExists(atPath: trashURL.path) {
//                            try? fileManager.moveItem(atPath: trashURL.path, toPath: initialFilePath)
//                        }
                    }
                }
            } else {
                print("File does not exist")
            }
        } catch let error as NSError {
            print("An error took place: \(error)")
        }
        
        refetchCompleteDownloads()
    }
}
