//
//  IndexedCallable.swift
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

class IndexedCallable: NSObject {
    static let prefix = "callWithIndex"
    private static let prefixLength = prefix.count
    
    static func selector(for index: Int) -> Selector {
        Selector("\(prefix)\(index)")
    }
    
    let handler: (Int) -> Void
    
    init(handler: @escaping (Int) -> Void) {
        self.handler = handler
    }
    
    class func willRespond(to selector: Selector) -> Bool {
        NSStringFromSelector(selector).hasPrefix(prefix)
    }
    
    override class func resolveInstanceMethod(_ selector: Selector!) -> Bool {
        let name = NSStringFromSelector(selector)

        // intercept unknown selectors of the form `callWithIndex<int>`
        guard name.hasPrefix(prefix), let index = Int(name.dropFirst(prefixLength)) else {
            return super.resolveInstanceMethod(selector)
        }
        
        // add a new method that calls the handler with the given index
        let imp: @convention(block) (IndexedCallable) -> Void = { instance in
            instance.handler(index)
        }
        
        // types "v@:" -> returns void (v), takes object (@) and selector (:)
        return class_addMethod(self, selector, imp_implementationWithBlock(imp), "v@:")
    }
}
