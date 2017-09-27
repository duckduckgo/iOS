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
    
    struct Constants {
        static let sitesFile = "top500_sites.json"
        static let reportFile = "top500_grades_\(TopSitesReport.dateString()).json"
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
        let data = try! FileLoader().load(fileName: Constants.sitesFile, fromBundle: Bundle(for: TopSitesReport.self))
        let sites = try! JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String]
        for site in sites {
            evaluateSite("http://\(site)")
        }
    }
    
    func evaluateSite(_ site: String) {
        mainController.loadUrl(URL(string: site)!)
        wait(for: 5)
        let siteRating = mainController.siteRating
        XCTAssertNotNil(siteRating, "\(site) did not load")
        if let siteRating = siteRating {
            results.append(siteRating.scoreDict)
        }
    }

    func loadStoryboard() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
        mainController = navigationController.topViewController as! MainViewController
        UIApplication.shared.keyWindow!.rootViewController = navigationController
        XCTAssertNotNil(navigationController.view)
        XCTAssertNotNil(mainController.view)
    }
    
    func saveResults() {
        let fileName = Constants.reportFile
        let fileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!.appendingPathComponent(fileName)
        let jsonResults = try! JSONSerialization.data(withJSONObject: results, options: .prettyPrinted)
        let stringResults = String(data: jsonResults, encoding: .utf8)!
        try! stringResults.write(to: fileUrl, atomically: true, encoding: .utf8)
        print("Saving results to \(fileUrl)")
    }
    
    static func dateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmm"
        return formatter.string(from: Date())
    }
}
