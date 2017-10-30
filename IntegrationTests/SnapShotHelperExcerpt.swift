//
//  SnapshotHelperExcerpt.swift
//
//  Modified excerpt from fastlane tools SnapShotHelper example
//  https://github.com/fastlane/fastlane/blob/master/snapshot/lib/assets/SnapshotHelper.swift
//

import Foundation
import XCTest

class SnapShotHelperExcerpt {
    
    static func waitForLoadingIndicators(timeout: Int) {
        var loadTime = 1
        let query = XCUIApplication().statusBars.children(matching: .other).element(boundBy: 1).children(matching: .other)
        while (0..<query.count).map({ query.element(boundBy: $0) }).contains(where: { $0.isLoadingIndicator }) {
            if loadTime > timeout {
                print("Wait for loading indicator to disappear timed out")
                return
            }
            
            sleep(1)
            loadTime += 1
            print("Waiting for loading indicator to disappear...")
        }
    }
    
}

extension XCUIElement {
    var isLoadingIndicator: Bool {
        let whiteListedLoaders = ["GeofenceLocationTrackingOn", "StandardLocationTrackingOn"]
        if whiteListedLoaders.contains(self.identifier) {
            return false
        }
        return self.frame.size == CGSize(width: 10, height: 20)
    }
}
