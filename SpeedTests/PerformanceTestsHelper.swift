//
//  PerformanceTestsHelper.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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

extension XCTestCase {
    
    struct Timeout {
        static let pageLoad = 20.0
    }
    
    func loadStoryboard() -> MainViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let controller = storyboard.instantiateInitialViewController() as? MainViewController else {
            fatalError("Failed to instantiate controller as MainViewController")
        }
        UIApplication.shared.keyWindow!.rootViewController = controller
        XCTAssertNotNil(controller.view)
        
        return controller
    }
    
    func loadBlockingLists() {
        let blocker = DispatchSemaphore(value: 0)
        ContentBlockerLoader().start { _ in
            blocker.signal()
        }
        blocker.wait()
    }
    
    func waitFor(seconds: TimeInterval) {
        RunLoop.main.run(until: Date(timeIntervalSinceNow: seconds))
    }
    
    func waitForPageLoad(in mainController: MainViewController) {
        let pageTimeout = Date(timeIntervalSinceNow: Timeout.pageLoad)
        while (mainController.siteRating == nil || !mainController.siteRating!.finishedLoading) && Date() < pageTimeout {
            waitFor(seconds: 0.001)
        }
    }
}
