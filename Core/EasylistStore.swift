//
//  EasylistStore.swift
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

class EasylistStore {

    struct CacheNames {

        static let easylist = "easylist"
        static let easylistPrivacy = "easylist-privacy"

    }

    enum Easylist: String {

        case easylist
        case easylistPrivacy

    }

    var hasData: Bool {
        return easylist != "" && easylistPrivacy != ""
    }

    private(set) var easylist: String = ""
    private(set) var easylistPrivacy: String = ""

    public init() {
        easylist = load(.easylist) ?? ""
        easylistPrivacy = load(.easylistPrivacy) ?? ""
    }

    func load(_ type: Easylist) -> String? {
        guard let data = try? Data(contentsOf: persistenceLocation(type: type)) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    func persistEasylist(data: Data) {
        easylist = persistAndPrepareForInjection(data: data, as: .easylist, withCacheName: CacheNames.easylist) ?? ""
    }

    func persistEasylistPrivacy(data: Data) {
        easylistPrivacy = persistAndPrepareForInjection(data: data, as: .easylistPrivacy, withCacheName: CacheNames.easylistPrivacy) ?? ""
    }

    private func persistAndPrepareForInjection(data: Data, as type: Easylist, withCacheName cacheName: String) -> String? {
        guard let escapedEasylist = escapedString(from: data) else { return nil }
        do {
            try persist(escapedEasylist: escapedEasylist, to: persistenceLocation(type: type))
            invalidateCache(named: cacheName)
            return escapedEasylist
        } catch {
            Logger.log(text: "failed to write \(type): \(error)")
        }
        return nil
    }

    private func persistenceLocation(type: Easylist) -> URL {
        let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: ContentBlockerStoreConstants.groupName)
        return path!.appendingPathComponent("\(type.rawValue).txt")
    }

    private func invalidateCache(named name: String) {
        ContentBlockerStringCache().remove(named: name)
    }

    private func persist(escapedEasylist: String, to: URL) throws {
        try escapedEasylist.write(to: to, atomically: true, encoding: .utf8)
    }

    private func escapedString(from data: Data) -> String? {
        return String(data: data, encoding: .utf8)?.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "`", with: "\\`")
    }

}

