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

struct PersistentPixelMetadata: Codable, Equatable {
    enum PixelType: Codable {
        case daily
        case count
        case regular
    }

    let event: Pixel.Event
    let originalFireDate: Date
    let pixelType: PixelType
    let additionalParameters: [String: String]
    let includedParameters: [Pixel.QueryParameters]

    var pixelName: String {
        switch pixelType {
        case .daily: return event.name + "_d"
        case .count: return event.name + "_c"
        case .regular: return event.name
        }
    }
}

protocol PersistentPixelStoring {
    func append(pixel: PersistentPixelMetadata) throws
    func replaceStoredPixels(with pixels: [PersistentPixelMetadata]) throws
    func storedPixels() throws -> [PersistentPixelMetadata]
}

enum PersistentPixelStorageError: Error {
    case readError(Error)
    case writeError(Error)
    case encodingError(Error)
    case decodingError(Error)
}

final class DefaultPersistentPixelStorage: PersistentPixelStoring {

    private enum Constants {
        static let queuedPixelsFileName = "queued-pixels.json"
    }

    let fileManager: FileManager
    let fileName: String
    let storageDirectory: URL

    private let fileAccessQueue = DispatchQueue(label: "Persistent Pixel File Access Queue", qos: .utility)
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private var fileURL: URL {
        return storageDirectory.appendingPathComponent(fileName)
    }

    public init(fileManager: FileManager = .default,
                fileName: String = Constants.queuedPixelsFileName,
                storageDirectory: URL? = nil) {
        self.fileManager = fileManager
        self.fileName = fileName

        if let storageDirectory = storageDirectory {
            self.storageDirectory = storageDirectory
        } else if let appSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            self.storageDirectory = appSupportDirectory
        } else {
            fatalError("Unable to locate application support directory")
        }
    }

    func append(pixel: PersistentPixelMetadata) throws {
        try fileAccessQueue.sync {
            var pixels = try self.readStoredPixelDataFromFileSystem()
            pixels.append(pixel)
            try writePixelDataToFileSystem(pixels: pixels)
        }
    }

    func replaceStoredPixels(with pixels: [PersistentPixelMetadata]) throws {
        try fileAccessQueue.sync {
            try writePixelDataToFileSystem(pixels: pixels)
        }
    }

    func storedPixels() throws -> [PersistentPixelMetadata] {
        try fileAccessQueue.sync {
            return try readStoredPixelDataFromFileSystem()
        }
    }

    // MARK: - Private

    private func readStoredPixelDataFromFileSystem() throws -> [PersistentPixelMetadata] {
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return []
        }

        let pixelFileData = try Data(contentsOf: fileURL)
        return try decoder.decode([PersistentPixelMetadata].self, from: pixelFileData)
    }

    private func writePixelDataToFileSystem(pixels: [PersistentPixelMetadata]) throws {
        let encodedPixelData = try encoder.encode(pixels)
        try encodedPixelData.write(to: fileURL)
    }

}
