//
//  RegionFilterLoader.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 17/05/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

struct RegionFilterLoader {
    
    private static let filename = "regions"
    private static let fileExtension = "json"
    
    public func load() -> [RegionFilter] {
        let data = loadFile()
        let parser = RegionFilterParser()
        return parser.convert(fromJsonData: data)
    }
    
    private func loadFile() -> Data? {
        let fileLoader = FileLoader()
        return fileLoader.load(name: RegionFilterLoader.filename, ext: RegionFilterLoader.fileExtension)
    }
}
