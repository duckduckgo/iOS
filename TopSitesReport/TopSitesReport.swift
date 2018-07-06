//
//  TopSiteReport.swift
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

import XCTest
@testable import DuckDuckGo
@testable import Core

class TopSitesReport: XCTestCase {

    private var results = [Any]()
    private var mainController: MainViewController!

    struct Filename {
        static let sites = "top500_sites.json"
        static let report = "top500_grades_\(TopSitesReport.dateString()).json"
    }

    struct Timeout {
        static let pageLoad = 20.0
        static let preLoadBuffer = 2.0
        static let postLoadBuffer = 2.0
    }

    override func setUp() {
        TabsModel.clear()
        loadStoryboard()
    }

    override func tearDown() {
        saveResults()
        TabsModel.clear()
    }

    func testTopSites() {
        guard let data = try? FileLoader().load(fileName: Filename.sites, fromBundle: Bundle(for: TopSitesReport.self)) else {
            fatalError("Failed to load file \(Filename.sites)")
        }
        
        guard let sites = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) else {
            fatalError("failed to create json object with data")
        }
        
        guard let sites = sites as? [String] else {
            fatalError("sites is not a [String]")
        }
        
        for site in sites {
            evaluateSite(site)
        }
    }

    func evaluateSite(_ site: String) {

        mainController.loadUrl(URL(string: site)!)
        waitForPageLoad()

        if let siteRating = mainController.siteRating, siteRating.finishedLoading {
            print("SiteRating: \(siteRating.scoreDescription)")
            var result = siteRating.scoreDict
            result["url"] = site
            results.append(result)
        } else {
            print("\(site) failed to load")
        }

    }

    func waitForPageLoad() {
        RunLoop.main.run(until: Date(timeIntervalSinceNow: Timeout.preLoadBuffer))
        let pageTimeout = Date(timeIntervalSinceNow: Timeout.pageLoad)
        while (mainController.siteRating == nil || !mainController.siteRating!.finishedLoading) && Date() < pageTimeout {
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))
        }
        RunLoop.main.run(until: Date(timeIntervalSinceNow: Timeout.postLoadBuffer))
    }

    func loadStoryboard() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let controller = storyboard.instantiateInitialViewController() as? MainViewController else {
            fatalError("Failed to instantiate correct controller for Main")
        }
        self.mainController = controller
        UIApplication.shared.keyWindow!.rootViewController = mainController
        XCTAssertNotNil(mainController.view)
    }

    func saveResults() {
        let fileName = Filename.report
        let fileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!.appendingPathComponent(fileName)
        guard let jsonResults = try? JSONSerialization.data(withJSONObject: results, options: .prettyPrinted) else {
            fatalError("Failed to create json data from result")
        }
        var stringResults = String(data: jsonResults, encoding: .utf8)!
        stringResults = stringResults.replacingOccurrences(of: "\\/", with: "/")
        guard try? stringResults.write(to: fileUrl, atomically: true, encoding: .utf8) else {
            fatalError("Failed to write string results to \(fileUrl)")
        }
        print("Saving results to \(fileUrl)")
    }

    static func dateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmm"
        return formatter.string(from: Date())
    }
}
