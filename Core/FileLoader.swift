//
//  FileLoader.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

enum FileError: Error {
    case unknownFile
    case invalidFileContents
}

class FileLoader {

    func load(fileName: String, fromBundle bundle: Bundle) throws -> Data {

        let fileUrl = URL(fileURLWithPath: fileName)
        let baseName = fileUrl.deletingPathExtension().path
        let ext = fileUrl.pathExtension

        var path = bundle.path(forResource: baseName, ofType: ext)
        if path == nil {
            let fileName = fileName.dropping(suffix: ext).dropping(suffix: ".")
            path = bundle.path(forResource: fileName, ofType: ext)
        }
        guard let path else { throw  FileError.unknownFile }
        let url = URL(fileURLWithPath: path)
        guard let data = try? Data(contentsOf: url, options: [.mappedIfSafe]) else { throw  FileError.invalidFileContents }
        return data
    }
}
