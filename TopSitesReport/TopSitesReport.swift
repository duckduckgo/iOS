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

struct ReportEntry: Encodable {
    
    let url: String
    let scores: Grade.Scores?
    let failed: Bool?
    
}

class TopSitesReport: XCTestCase {

    private var results = [ReportEntry]()
    private var mainController: MainViewController!

    struct Filename {
        static let sites = "top_sites.json"
        static let report = "top_sites_report.json"
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
        try? saveResults()
        TabsModel.clear()
    }

    func testTopSites() throws {
        guard let data = try? FileLoader().load(fileName: Filename.sites, fromBundle: Bundle(for: TopSitesReport.self)) else {
            fatalError("Failed to load file \(Filename.sites)")
        }
        
        let sites = try JSONDecoder().decode([String].self, from: data)
        
        for site in sites {
            evaluateSite(site)
        }
    }

    func evaluateSite(_ site: String) {

        mainController.loadUrl(URL(string: "http://\(site)")!)
        waitForPageLoad()

        if let siteRating = mainController.siteRating, siteRating.finishedLoading {
            results.append(ReportEntry(url: site, scores: siteRating.scores, failed: nil))
        } else {
            print("\(site) failed to load")
            results.append(ReportEntry(url: site, scores: nil, failed: true))
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

    func saveResults() throws {
        let fileName = Filename.report
        let fileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!.appendingPathComponent(fileName)
        
        let json = try JSONEncoder().encode(results)
        try json.write(to: fileUrl, options: .atomic)
        
        print("Saving results to \(fileUrl)")
    }

}
