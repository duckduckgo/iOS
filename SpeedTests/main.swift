#!/usr/bin/swift

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
