#!/usr/bin/swift

//
//  main.swift
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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

// TYPES

enum Errors: Error {

    case fileNotFound
    case invalidJson
    case reportLengthsAreDifferent
    case jsonEncodingFailed
    case stringFromDataFailed

}

struct URLTime: Codable {

    let url: String
    let time: TimeInterval
    let trackers: Int

}

// FUNCTIONS

func loadJson(fromFile file: String) throws -> [URLTime] {
    guard let data = try? Data(contentsOf: URL(string: "file://\(file)")!) else {
        throw Errors.fileNotFound
    }

    let decoder = JSONDecoder()
    guard let results = try? decoder.decode([URLTime].self, from: data) else {
        throw Errors.invalidJson
    }

    return results
}

func usage() {
    print("usage: \(#function) base.json comparison.json")
    print()
}

// SCRIPT

guard CommandLine.arguments.count == 3 else {
    usage()
    exit(1)
}

do {
    let base = try loadJson(fromFile: CommandLine.arguments[1])
    let comparison = try loadJson(fromFile: CommandLine.arguments[2])

    guard base.count == comparison.count else {
        throw Errors.reportLengthsAreDifferent
    }

    var diffs = [URLTime]()
    for index in 0 ..< base.count {
        let baseTiming = base[index]
        let comparisonTiming = comparison[index]
        diffs.append(URLTime(url: baseTiming.url, time: baseTiming.time - comparisonTiming.time, trackers: baseTiming.trackers - comparisonTiming.trackers))
    }

    let encoder = JSONEncoder()
    encoder.outputFormatting = [ .prettyPrinted, .sortedKeys ]
    guard let resultData = try? encoder.encode(diffs) else {
        throw Errors.jsonEncodingFailed
    }

    guard let result = String(data: resultData, encoding: .utf8) else {
        throw Errors.stringFromDataFailed
    }
    print(result)

} catch {
    print("Error: \(error)")
    print()
    usage()
}
