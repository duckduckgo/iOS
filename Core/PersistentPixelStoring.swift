//
//  PersistentPixelStoring.swift
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

import Foundation
import Networking

public struct PersistentPixelMetadata: Identifiable, Codable, Equatable {

    public let id: UUID
    public let eventName: String
    public let additionalParameters: [String: String]
    public let includedParameters: [Pixel.QueryParameters]

    public init(eventName: String, additionalParameters: [String: String], includedParameters: [Pixel.QueryParameters]) {
        self.id = UUID()
        self.eventName = eventName
        self.additionalParameters = additionalParameters
        self.includedParameters = includedParameters
    }

    var timestamp: String? {
        return additionalParameters[PixelParameters.originalPixelTimestamp]
    }
}

protocol PersistentPixelStoring {
    func append(pixels: [PersistentPixelMetadata]) throws
    func remove(pixelsWithIDs: Set<UUID>) throws
    func storedPixels() throws -> [PersistentPixelMetadata]
}

public enum PersistentPixelStorageError: Error {
    case readError(Error)
    case writeError(Error)
    case encodingError(Error)
    case decodingError(Error)
}

final class DefaultPersistentPixelStorage: PersistentPixelStoring {

    enum Constants {
        static let queuedPixelsFileName = "queued-pixels.json"
        static let pixelCountLimit = 100
    }

    private let fileManager: FileManager
    private let fileName: String
    private let storageDirectory: URL
    private let pixelCountLimit: Int

    private let fileAccessQueue = DispatchQueue(label: "Persistent Pixel File Access Queue", qos: .utility)
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private var fileURL: URL {
        return storageDirectory.appendingPathComponent(fileName)
    }

    init(fileManager: FileManager = .default,
         fileName: String = Constants.queuedPixelsFileName,
         storageDirectory: URL? = nil,
         pixelCountLimit: Int = Constants.pixelCountLimit) {
        self.fileManager = fileManager
        self.fileName = fileName
        self.pixelCountLimit = pixelCountLimit

        if let storageDirectory = storageDirectory {
            self.storageDirectory = storageDirectory
        } else if let appSupportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            self.storageDirectory = appSupportDirectory
        } else {
            fatalError("Unable to locate application support directory")
        }
    }

    func append(pixels newPixels: [PersistentPixelMetadata]) throws {
        try fileAccessQueue.sync {
            var pixels = try self.readStoredPixelDataFromFileSystem()
            pixels.append(contentsOf: newPixels)

            if pixels.count > pixelCountLimit {
                pixels = pixels.suffix(Constants.pixelCountLimit)
            }

            try writePixelDataToFileSystem(pixels: pixels)
        }
    }

    func remove(pixelsWithIDs pixelIDs: Set<UUID>) throws {
        try fileAccessQueue.sync {
            var pixels = try self.readStoredPixelDataFromFileSystem()
            
            pixels.removeAll { pixel in
                pixelIDs.contains(pixel.id)
            }
            
            try writePixelDataToFileSystem(pixels: pixels)
        }
    }

    func storedPixels() throws -> [PersistentPixelMetadata] {
        try fileAccessQueue.sync {
            return try readStoredPixelDataFromFileSystem()
        }
    }

    // MARK: - Private

    private var cachedPixelMetadata: [PersistentPixelMetadata]?

    private func readStoredPixelDataFromFileSystem() throws -> [PersistentPixelMetadata] {
        dispatchPrecondition(condition: .onQueue(fileAccessQueue))

        if let cachedPixelMetadata {
            return cachedPixelMetadata
        }

        guard fileManager.fileExists(atPath: fileURL.path) else {
            return []
        }

        do {
            let pixelFileData = try Data(contentsOf: fileURL)

            do {
                let decodedMetadata = try decoder.decode([PersistentPixelMetadata].self, from: pixelFileData)
                self.cachedPixelMetadata = decodedMetadata
                return decodedMetadata
            } catch {
                throw PersistentPixelStorageError.decodingError(error)
            }
        } catch {
            throw PersistentPixelStorageError.readError(error)
        }
    }

    private func writePixelDataToFileSystem(pixels: [PersistentPixelMetadata]) throws {
        dispatchPrecondition(condition: .onQueue(fileAccessQueue))
        
        do {
            let encodedPixelData = try encoder.encode(pixels)

            do {
                try encodedPixelData.write(to: fileURL)
                self.cachedPixelMetadata = pixels
            } catch {
                throw PersistentPixelStorageError.writeError(error)
            }
        } catch {
            throw PersistentPixelStorageError.encodingError(error)
        }
    }

}
