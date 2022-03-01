//
//  ArrayBuilder.swift
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

@resultBuilder
public struct ArrayBuilder<T> {
    public static func buildBlock() -> [T] { [] }
    public static func buildBlock(_ expression: T) -> [T] { [expression] }
    public static func buildBlock(_ elements: T...) -> [T] { elements }
    public static func buildBlock(_ elementGroups: [T]...) -> [T] { elementGroups.flatMap { $0 } }
    public static func buildBlock(_ elements: [T]) -> [T] { elements }
    public static func buildEither(first: [T]) -> [T] { first }
    public static func buildEither(second: [T]) -> [T] { second }
    public static func buildIf(_ element: [T]?) -> [T] { element ?? [] }
    public static func buildBlock(_ element: Never) -> [T] {}
}
