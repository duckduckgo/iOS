/**
 *  This playground script converts the disconnect.me tracker list into a format which can be
 *  used by Apple’s content blocker.
 *
 *  To use this script replace the tracker.json file in resources with the latest version
 *  at https://github.com/disconnectme/disconnect-tracking-protection and then press run
 */

import UIKit

struct TrackerEntry {
    let domain: String
    let url: String
}

func run() {
    guard let jsonData = loadInputFile() else { return }
    let trackers = extractTrackers(jsonData: jsonData)
    let blockListJson = generateBlockListJson(trackers: trackers)
    saveToFile(text: blockListJson)
}

func loadInputFile() -> Data? {
    guard let path = Bundle.main.path(forResource: "trackers", ofType: "json") else { return nil }
    return FileManager.default.contents(atPath: path)
}

func extractTrackers(jsonData: Data) -> Array<TrackerEntry> {
    print("EXTRACTING TRACKERS...")
    let json = JSON(data: jsonData)
    let categories = json["categories"]
    
    var list = Array<TrackerEntry>()
    for (_, elements) in categories {
        for element in elements.arrayValue {
            guard let baseUrl = element.first?.1.first?.0 else { continue }
            guard let trackers = element.first?.1.first?.1.arrayObject else { continue }
            let domain = extractDomain(fromUrl: baseUrl)
            for tracker in trackers {
                let entry = TrackerEntry(domain: domain, url: "\(tracker)")
                list.append(entry)
                print(entry)
            }
        }
    }
    print()
    return list
}

func extractDomain(fromUrl url: String) -> String {
    let host = URL(string: url)?.host ?? url
    return host.replacingOccurrences(of: "www.", with: "")
}

func generateBlockListJson(trackers: Array<TrackerEntry>) -> String {
    print("GENERATING JSON... ", terminator:"")
    var output = "[\n"
    for (index, tracker) in trackers.enumerated() {
        let entry = blockedEntry(tracker: tracker)
        let suffix = last(list: trackers, index: index) ? "\n" : ",\n"
        output.append(entry + suffix)
    }
    output.append("]")
    print("Done\n")
    return output
}

func last(list: Array<Any>, index: Int) -> Bool {
    return index == list.count-1
}

func blockedEntry(tracker: TrackerEntry) -> String {
    let domain = "[\"*\(tracker.domain)\"]"
    let url = "\"\(tracker.url)\""
    return "{ \"action\":  { \"type\": \"block\" }, \"trigger\": { \"load-type\": [\"third-party\"], \"url-filter\": \(url), \"unless-domain\": \(domain)}}"
}

func saveToFile(text: String) {
    let path = try! FileManager.default.url(for: .sharedPublicDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        .appendingPathComponent("blockerList.json")
    print("SAVING FILE TO \(path)... ", terminator:"")
    try! text.write(to: path, atomically: true, encoding: .utf8)
    print("Done\n")
}

run()
