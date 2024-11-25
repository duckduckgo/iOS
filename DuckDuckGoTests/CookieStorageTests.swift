//
//  CookieStorageTests.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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
@testable import Core
import WebKit

public class CookieStorageTests: XCTestCase {

    func testLoadCookiesFromDefaultsAndRemovalWhenMigrationCompletes() {
        let defaults = UserDefaults(suiteName: "test")!
        defaults.removeSuite(named: "test")

        MigratableCookieStorage.addCookies([
                .make(name: "test1", value: "value1", domain: "example.com"),
                .make(name: "test2", value: "value2", domain: "example.com"),
                .make(name: "test3", value: "value3", domain: "facebook.com"),
        ], defaults)

        let storage = MigratableCookieStorage(userDefaults: defaults)
        XCTAssertEqual(storage.cookies.count, 3)

        XCTAssertTrue(storage.cookies.contains(where: {
            $0.domain == "example.com" &&
            $0.name == "test1" &&
            $0.value == "value1"
        }))

        XCTAssertTrue(storage.cookies.contains(where: {
            $0.domain == "example.com" &&
            $0.name == "test2" &&
            $0.value == "value2"
        }))

        XCTAssertTrue(storage.cookies.contains(where: {
            $0.domain == "facebook.com" &&
            $0.name == "test3" &&
            $0.value == "value3"
        }))

        // Now remove them all
        storage.migrationComplete()

        XCTAssertTrue(storage.cookies.isEmpty)
    }


}

extension MigratableCookieStorage {

    static func addCookies(_ cookies: [HTTPCookie], _ defaults: UserDefaults) {

        var cookieData = [[String: Any?]]()
        cookies.forEach { cookie in
            var mappedCookie = [String: Any?]()
            cookie.properties?.forEach {
                mappedCookie[$0.key.rawValue] = $0.value
            }
            cookieData.append(mappedCookie)
        }
        defaults.setValue(cookieData, forKey: MigratableCookieStorage.Keys.allowedCookies)

    }

}
