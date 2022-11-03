//
//  WKBackForwardListExtension.swift
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

import WebKit

public extension WKBackForwardList {

    /// Returns the offset of the searched item from the Current Item
    /// - Parameter backForwardListItem: An item to search for in the list.
    /// - Returns: When found, returns 1-based index from the Current Item, positive for the `forwardList`,
    ///   negative for the `backList`. If `backForwardListItem` matches the current item, returns `0`.
    ///   If `backForwardListItem` is not in the list, returns `nil`.
    ///   When the found index is passed to `item(at: index)` will return the searched item.
    func index(of backForwardListItem: WKBackForwardListItem) -> Int? {
        if currentItem == backForwardListItem {
            return 0
        }
        if let idx = backList.firstIndex(of: backForwardListItem) {
            return -idx - 1
        }
        if let idx = forwardList.firstIndex(of: backForwardListItem) {
            return idx + 1
        }
        return nil
    }

}
