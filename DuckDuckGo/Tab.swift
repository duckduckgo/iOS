//
//  Tab.swift
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

import Core

public class Tab: NSObject, NSCoding {

    private struct NSCodingKeys {
        static let link = "link"
    }

    var link: Link?

    init(link: Link?) {
        self.link = link
    }

    public convenience required init?(coder decoder: NSCoder) {
        let link = decoder.decodeObject(forKey: NSCodingKeys.link) as? Link
        self.init(link: link)
    }

    public func encode(with coder: NSCoder) {
        coder.encode(link, forKey: NSCodingKeys.link)
    }

    public override func isEqual(_ other: Any?) -> Bool {
        guard let other = other as? Tab else { return false }
        return link == other.link
    }
}
