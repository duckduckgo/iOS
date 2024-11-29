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

protocol TabObserver: AnyObject {
 
    func didChange(tab: Tab)
    
}

public class Tab: NSObject, NSCoding {

    struct WeaklyHeldTabObserver {
        weak var observer: TabObserver?
    }
    
    struct NSCodingKeys {
        static let uid = "uid"
        static let link = "link"
        static let viewed = "viewed"
        static let desktop = "desktop"
        static let lastViewedDate = "lastViewedDate"
    }

    private var observersHolder = [WeaklyHeldTabObserver]()
    
    let uid: String

    /// The date last time this tab was displayed.
    ///
    /// - Warning: This value **must not** be used for any other purpose than for inactive tabs buckets aggregation
    /// into a daily pixel in `TabSwitcherOpenDailyPixel`. If you plan to do something else,
    /// read through https://app.asana.com/0/69071770703008/1208795393823862/f and reopen if necessary.
    private(set) var lastViewedDate: Date?

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
    
    var viewed: Bool = false {
        didSet {
            if viewed {
                lastViewedDate = Date()
            }
            notifyObservers()
        }
    }

    public init(uid: String? = nil,
                link: Link? = nil,
                viewed: Bool = false,
                desktop: Bool = AppWidthObserver.shared.isLargeWidth,
                lastViewedDate: Date? = nil) {
        self.uid = uid ?? UUID().uuidString
        self.link = link
        self.viewed = viewed
        self.isDesktop = desktop
        self.lastViewedDate = lastViewedDate
    }

    public convenience required init?(coder decoder: NSCoder) {
        let uid = decoder.decodeObject(forKey: NSCodingKeys.uid) as? String
        let link = decoder.decodeObject(forKey: NSCodingKeys.link) as? Link
        let viewed = decoder.containsValue(forKey: NSCodingKeys.viewed) ? decoder.decodeBool(forKey: NSCodingKeys.viewed) : true
        let desktop = decoder.containsValue(forKey: NSCodingKeys.desktop) ? decoder.decodeBool(forKey: NSCodingKeys.desktop) : false
        let lastViewedDate = decoder.containsValue(forKey: NSCodingKeys.lastViewedDate) ? decoder.decodeObject(forKey: NSCodingKeys.lastViewedDate) as? Date : nil
        self.init(uid: uid, link: link, viewed: viewed, desktop: desktop, lastViewedDate: lastViewedDate)
    }

    public func encode(with coder: NSCoder) {
        coder.encode(uid, forKey: NSCodingKeys.uid)
        coder.encode(link, forKey: NSCodingKeys.link)
        coder.encode(viewed, forKey: NSCodingKeys.viewed)
        coder.encode(isDesktop, forKey: NSCodingKeys.desktop)
        coder.encode(lastViewedDate, forKey: NSCodingKeys.lastViewedDate)
    }

    public override func isEqual(_ other: Any?) -> Bool {
        guard let other = other as? Tab else { return false }
        return link == other.link
    }
    
    func toggleDesktopMode() {
        isDesktop = !isDesktop
    }
    
    func didUpdatePreview() {
        notifyObservers()
    }
    
    func didUpdateFavicon() {
        notifyObservers()
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
        observersHolder.forEach { $0.observer?.didChange(tab: self) }
        pruneHolders()
    }

    private func pruneHolders() {
        observersHolder = observersHolder.filter { $0.observer != nil }
    }

}
