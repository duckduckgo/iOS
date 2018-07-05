//
//  TabsModel.swift
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
import Core

public class TabsModel: NSObject, NSCoding {

    private struct NSCodingKeys {
        static let currentIndex = "currentIndex"
        static let tabs = "tabs"
    }

    private(set) var currentIndex: Int?
    private(set) var tabs: [Tab]

    public init(tabs: [Tab] = [Tab](), currentIndex: Int? = nil) {
        self.tabs = tabs
        self.currentIndex = currentIndex
    }

    public convenience required init?(coder decoder: NSCoder) {
        guard let tabs = decoder.decodeObject(forKey: NSCodingKeys.tabs) as? [Tab] else { return nil }
        var currentIndex = decoder.decodeObject(forKey: NSCodingKeys.currentIndex) as? Int
        if let index = currentIndex, index < 0 || index >= tabs.count {
            currentIndex = nil
        }
        self.init(tabs: tabs, currentIndex: currentIndex)
    }

    public func encode(with coder: NSCoder) {
        coder.encode(tabs, forKey: NSCodingKeys.tabs)
        coder.encode(currentIndex, forKey: NSCodingKeys.currentIndex)
    }

    var isEmpty: Bool {
        return tabs.isEmpty
    }

    var count: Int {
        return tabs.count
    }

    func select(tabAt index: Int) {
        currentIndex = index
    }

    func clearSelection() {
        currentIndex = nil
    }

    func get(tabAt index: Int) -> Tab {
        return tabs[index]
    }

    func add(tab: Tab) {
        tabs.append(tab)
        currentIndex = indexOf(tab: tab)
    }

    func remove(at index: Int) {

        tabs.remove(at: index)

        guard let current = currentIndex else { return }

        if tabs.isEmpty {
            currentIndex = nil
            return
        }

        if current == 0 || current < index {
            return
        }

        currentIndex = current - 1
    }

    func remove(tab: Tab) {
        if let index = indexOf(tab: tab) {
            remove(at: index)
        }
    }

    func indexOf(tab: Tab) -> Int? {
        for (index, current) in tabs.enumerated() {
            if current === tab {
                return index
            }
        }
        return nil
    }

    func clearAll() {
        for tab in tabs {
            remove(tab: tab)
        }
    }
}
