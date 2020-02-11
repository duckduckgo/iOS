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

protocol TabObserver: class {
 
    func didChange(tab: Tab)
    
}

public class Tab: NSObject, NSCoding {

    struct WeaklyHeldTabObserver {
        weak var observer: TabObserver?
    }
    
    struct NSCodingKeys {
        static let link = "link"
        static let viewed = "viewed"
        static let desktop = "desktop"
    }

    private var observersHolder = [WeaklyHeldTabObserver]()
    
    var isDesktop: Bool = false {
        didSet {
            notifyObservers()
        }
    }
    
    var link: Link? {
        didSet {
            notifyObservers()
        }
    }
    var viewed: Bool = true {
        didSet {
            notifyObservers()
        }
    }

    public init(link: Link? = nil, viewed: Bool = true, desktop: Bool = isPad) {
        self.link = link
        self.viewed = viewed
        self.isDesktop = desktop
    }

    public convenience required init?(coder decoder: NSCoder) {
        let link = decoder.decodeObject(forKey: NSCodingKeys.link) as? Link
        let viewed = decoder.containsValue(forKey: NSCodingKeys.viewed) ? decoder.decodeBool(forKey: NSCodingKeys.viewed) : true
        let desktop = decoder.containsValue(forKey: NSCodingKeys.desktop) ? decoder.decodeBool(forKey: NSCodingKeys.desktop) : false
        self.init(link: link, viewed: viewed, desktop: desktop)
    }

    public func encode(with coder: NSCoder) {
        coder.encode(link, forKey: NSCodingKeys.link)
        coder.encode(viewed, forKey: NSCodingKeys.viewed)
    }

    public override func isEqual(_ other: Any?) -> Bool {
        guard let other = other as? Tab else { return false }
        return link == other.link
    }
    
    func toggleDesktopMode() {
        isDesktop = !isDesktop
    }
    
    func addObserver(_ observer: TabObserver) {
        guard indexOf(observer) == nil else { return }
        observersHolder.append(WeaklyHeldTabObserver(observer: observer))
    }
    
    func removeObserver(_ observer: TabObserver) {
        guard let index = indexOf(observer) else { return }
        observersHolder.remove(at: index)
    }
    
    private func indexOf(_ observer: TabObserver) -> Int? {
        pruneHolders()
        return observersHolder.firstIndex(where: { $0.observer === observer })
    }
    
    private func notifyObservers() {
        pruneHolders()
        observersHolder.forEach { $0.observer?.didChange(tab: self) }
    }

    private func pruneHolders() {
        observersHolder = observersHolder.filter { $0.observer != nil }
    }

}
