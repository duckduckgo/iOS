//
//  ConfigurationStore.swift
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

import Foundation
import Configuration
import Core

struct ConfigurationStore: ConfigurationStoring {
    
    private let etagStorage: BlockerListETagStorage
    private let fileStore: FileStore
    
    init(etagStorage: BlockerListETagStorage = UserDefaultsETagStorage(), fileStore: FileStore = FileStore()) {
        self.etagStorage = etagStorage
        self.fileStore = fileStore
    }
    
    func loadData(for configuration: Configuration) -> Data? {
        fileStore.loadAsData(for: configuration)
    }
    
    func loadEtag(for configuration: Configuration) -> String? {
        etagStorage.loadEtag(for: configuration)
    }
    
    func loadEmbeddedEtag(for configuration: Configuration) -> String? {
        switch configuration {
        case .trackerDataSet: return AppTrackerDataSetProvider.Constants.embeddedDataETag
        case .privacyConfiguration: return AppPrivacyConfigurationDataProvider.Constants.embeddedDataETag
        default: return nil
        }
    }
    
    mutating func saveData(_ data: Data, for configuration: Configuration) throws {
        try fileStore.persist(data, for: configuration)
    }
    
    mutating func saveEtag(_ etag: String, for configuration: Configuration) throws {
        etagStorage.saveEtag(etag, for: configuration)
    }

    func fileUrl(for configuration: Configuration) -> URL {
        return fileStore.persistenceLocation(for: configuration)
    }

}
