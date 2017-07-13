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

public class TabsModel {
    
    var currentIndex: Int?
    private(set) var tabs = [Tab]()
    
    
    var isEmpty: Bool {
        return tabs.isEmpty
    }
    
    var count: Int {
        return tabs.count
    }
    
    func get(tabAt index: Int) -> Tab {
        return tabs[index]
    }
    
    func clearSelection() {
        currentIndex = nil
    }
    
    func add(tab: Tab) {
        tabs.append(tab)
        currentIndex = indexOf(tab: tab)
    }
    
    func remove(at index: Int) {
        tabs.remove(at: index)
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
