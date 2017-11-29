//
//  DetectedTracker.swift
//  Core
//
//  Created by Christopher Brind on 29/11/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

public struct DetectedTracker {

    public let url: String
    public let blocked: Bool
    public let networkName: String?
    public let category: String?

    public init(url: String, networkName: String?, category: String?, blocked: Bool) {
        self.url = url
        self.networkName = networkName
        self.category = category
        self.blocked = blocked
    }

    public var domain: String? {
        get { return URL(string: url)?.host }
    }

    public var isIpTracker: Bool {
        get {
            return (domain ?? "").components(separatedBy: ".").filter( { Int($0) != nil } ).count == 4
        }
    }

}

extension DetectedTracker: Hashable {

    public var hashValue: Int {
        get {
            return "\(url) \(blocked) \(String(describing: networkName)) \(String(describing: category))".hashValue
        }
    }

    public static func ==(lhs: DetectedTracker, rhs: DetectedTracker) -> Bool {
        return lhs.url == rhs.url
            && lhs.blocked == rhs.blocked
            && lhs.networkName == rhs.networkName
            && lhs.category == rhs.category
    }

}
