//
//  FileLoader.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 17/05/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

enum FileError: Error {
    case unknownFile
    case invalidFileContents
}

class FileLoader {

    func load(name: String, ext: String) throws -> Data {
        let bundle = Bundle.init(for: FileLoader.self)
        return try load(bundle: bundle, name: name, ext: ext)
    }
    
    func load(bundle: Bundle, name: String, ext: String) throws -> Data {
        guard let path = bundle.path(forResource: name, ofType: ext) else { throw  FileError.unknownFile }
        guard let string = try? String(contentsOfFile: path) else { throw FileError.invalidFileContents }
        guard let data = string.data(using: .utf16) else { throw FileError.invalidFileContents }
        return data
    }
}
