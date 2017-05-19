//
//  FileLoader.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 17/05/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

struct FileLoader {
    
    func load(name: String, ext: String) -> Data? {
        let bundle = Bundle.init(for: RegionFilterParser.self)
        guard let path = bundle.path(forResource: name, ofType: ext) else { return nil }
        guard let string = try? String(contentsOfFile: path) else { return nil }
        return string.data(using: .utf16)
    }
}
