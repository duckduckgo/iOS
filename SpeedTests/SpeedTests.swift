//
//  SpeedTests.swift
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

import XCTest

@testable import DuckDuckGo
@testable import Core

class SpeedTests: XCTestCase {

    private var results = [Any]()
    private var mainController: MainViewController!

    struct Filename {
        static let sites = "speed_test_sites.json"
        static let report = "speed_test_results_\(SpeedTests.dateString()).json"
    }

    struct Timeout {
        static let pageLoad = 20.0
    }

    override func setUp() {
        loadBlockingLists()
        TabsModel.clear()
        loadStoryboard()
    }

    override func tearDown() {
        saveResults()
        TabsModel.clear()
    }

    func loadBlockingLists() {
        let blocker = DispatchSemaphore(value: 0)
        BlockerListsLoader().start { _ in
            blocker.signal()
        }
        blocker.wait()
    }

    func test() {
        let bundle = Bundle(for: SpeedTests.self)
        guard let data = try? FileLoader().load(fileName: Filename.sites, fromBundle: bundle) else {
            fatalError("Failed to load file \(Filename.sites) from \(bundle)")
        }
        guard let sites = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) else {
            fatalError("Failed create jsonObject with data")
        }
        
        guard let sites = sites as? [[String: String]] else {
            fatalError("sites is not [[String: String]]")
        }

        for site in sites {
            guard let url = site["url"] else {
                XCTFail("site has no url \(site)")
                return
            }

            let time = evalulate(url)
            results.append([
                "url": url,
                "time": time,
                "trackers": mainController.siteRating?.totalTrackersDetected ?? -1
                ])
            waitFor(seconds: 2)
        }
    }

    func waitFor(seconds: TimeInterval) {
        RunLoop.main.run(until: Date(timeIntervalSinceNow: seconds))
    }

    func evalulate(_ url: String) -> TimeInterval {
        if let siteRating = mainController.siteRating {
            siteRating.finishedLoading = false
        }

        mainController.loadUrl(URL(string: url)!)
        let start = Date()
        waitForPageLoad()
        return Date().timeIntervalSince(start)
    }

    func waitForPageLoad() {
        let pageTimeout = Date(timeIntervalSinceNow: Timeout.pageLoad)
        while (mainController.siteRating == nil || !mainController.siteRating!.finishedLoading) && Date() < pageTimeout {
            waitFor(seconds: 0.001)
        }
    }

    func loadStoryboard() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let controller = storyboard.instantiateInitialViewController() as? MainViewController else {
            fatalError("Failed to instantiate controller as MainViewController")
        }
        mainController = controller
        UIApplication.shared.keyWindow!.rootViewController = mainController
        XCTAssertNotNil(mainController.view)
    }

    func saveResults() {
        let fileName = Filename.report
        let fileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!.appendingPathComponent(fileName)
        guard let jsonResults = try? JSONSerialization.data(withJSONObject: results, options: [ .prettyPrinted, .sortedKeys ]) else {
            fatalError("Failed to create json data from results")
        }
        var stringResults = String(data: jsonResults, encoding: .utf8)!
        stringResults = stringResults.replacingOccurrences(of: "\\/", with: "/")
        guard try? stringResults.write(to: fileUrl, atomically: true, encoding: .utf8) {
            fatalError("Failed to write results to \(fileUrl)")
        }
        print("Saving results to \(fileUrl)")
        print("You can access this file directly if runnning in the simulator.")
        print("If you run on a device you must enable file sharing for the app target and then use iTunes to extract the file.")
        print("Hint: add UIFileSharing = YES to Info.plist")
    }

    static func dateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmm"
        return formatter.string(from: Date())
    }

}
