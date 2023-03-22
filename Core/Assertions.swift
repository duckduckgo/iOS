//
//  Assertions.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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

#if DEBUG
public var customAssertionFailure: ((@autoclosure () -> String, StaticString, UInt) -> Void)?
public func assertionFailure(_ message: @autoclosure () -> String = String(), file: StaticString = #file, line: UInt = #line) {
    customAssertionFailure?(message(), file, line) ?? Swift.assertionFailure(message(), file: file, line: line)
}

public var customAssert: ((@autoclosure () -> Bool, @autoclosure () -> String, StaticString, UInt) -> Void)?
public func assert(_ condition: @autoclosure () -> Bool, _ message: @autoclosure () -> String = String(), file: StaticString = #file, line: UInt = #line) {
    customAssert?(condition(), message(), file, line) ?? Swift.assert(condition(), message(), file: file, line: line)
}
#endif
