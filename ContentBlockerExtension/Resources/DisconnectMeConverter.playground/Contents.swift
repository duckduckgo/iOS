/**
 *  This playground script converts the disconnect.me tracker list into a format which can be
 *  used by Apple’s content blocker.
 *
 *  To use this script replace the tracker.json file in resources with the latest version
 *  at https://github.com/disconnectme/disconnect-tracking-protection and then press run
 */

import UIKit

func run() {
    guard let jsonData = loadInputFile() else { return }
    let trackersUrls = extractUrls(jsonData: jsonData)
    let blockListJson = generateBlockListJson(urls: trackersUrls)
    saveToFile(text: blockListJson)
}

func loadInputFile() -> Data? {
    guard let path = Bundle.main.path(forResource: "trackers", ofType: "json") else {
        return nil
    }
    return FileManager.default.contents(atPath: path)
}

func extractUrls(jsonData: Data) -> Array<String> {
    print("EXTRACTING URLS...")
    let json = JSON(data: jsonData)
    let categories = json["categories"]
    
    var list = Array<String>()
    for (_, elements) in categories {
        for element in elements.arrayValue {
            guard let urls = element.first?.1.first?.1.arrayObject else { continue }
            for url in urls {
                print(url)
                list.append("\(url)")
            }
        }
    }
    print()
    return list
}

func generateBlockListJson(urls: Array<String>) -> String {
    print("GENERATING JSON... ", terminator:"")
    var output = "[\n"
    for (index, url) in urls.enumerated() {
        let entry = blockedEntry(url: url)
        let suffix = last(list: urls, index: index) ? "\n" : ",\n"
        output.append(entry + suffix)
    }
    output.append("]")
    print("Done\n")
    return output
}

func last(list: Array<Any>, index: Int) -> Bool {
    return index == list.count-1
}

func blockedEntry(url: String) -> String {
    return "{ \"action\":  { \"type\": \"block\" }, \"trigger\": { \"load-type\": [\"third-party\"], \"url-filter\": [\"\(url)\"]}}"
}

func saveToFile(text: String) {
    let path = try! FileManager.default.url(for: .sharedPublicDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        .appendingPathComponent("blockerList.json")
    print("SAVING FILE TO \(path)... ", terminator:"")
    try! text.write(to: path, atomically: true, encoding: .utf8)
    print("Done\n")
}

run()
