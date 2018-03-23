//
//  TLD.swift
//  Core
//
//  Created by Chris Brind on 23/03/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import Foundation

class TLD {
    
    private(set) var tlds: [String: Int] = [:]
    
    var json: String {
        guard let data = try? JSONSerialization.data(withJSONObject: tlds, options: []) else { return "{}" }
        guard let json = String(data: data, encoding: .utf8) else { return "{}" }
        return json
    }
    
    init(bundle: Bundle = Bundle(for: TLD.self)) {
        guard let url = bundle.url(forResource: "tlds", withExtension: "json") else { return }
        guard let data = try? Data(contentsOf: url) else { return }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else { return }
        guard let tlds = json as? [String: Int] else { return }
        self.tlds = tlds
    }
    
    func domain(_ host: String?) -> String? {
        guard let host = host else { return nil }
        
        var parts = Array<String>(host.components(separatedBy: ".").reversed())
        var stack = ""
        
        for index in 0 ..< parts.count {
            let part = parts[index]
            stack = !stack.isEmpty ? part + "." + stack : part
            guard let _ = tlds[stack] else { break }
        }
        
        return stack
    }
    
}
