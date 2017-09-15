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

    static let shared = EasylistStore()

    enum Easylist: String {

        case easylist
        case easylistPrivacy

    }

    var hasData: Bool {
        return easylist != "" && easylistPrivacy != ""
    }

    private(set) var easylist: String = ""
    private(set) var easylistPrivacy: String = ""

    private init() {
        easylist = (try? Data(contentsOf: persistenceLocation(type: .easylist)).base64EncodedString()) ?? ""
        easylistPrivacy = (try? Data(contentsOf: persistenceLocation(type: .easylistPrivacy)).base64EncodedString()) ?? ""
    }

    func persistEasylist(data: Data) {
        easylist = data.base64EncodedString()
        try! data.write(to: persistenceLocation(type: .easylist), options: .atomic)
    }

    func persistEasylistPrivacy(data: Data) {
        easylistPrivacy = data.base64EncodedString()
        try! data.write(to: persistenceLocation(type: .easylistPrivacy), options: .atomic)
    }

    private func decodeEncode(data: Data) -> String {
        let string = String(data: data, encoding: .utf8)!
        return string.data(using: .utf8)!.base64EncodedString()
    }

    private func persistenceLocation(type: Easylist) -> URL {
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let path = URL(fileURLWithPath: documentPath, isDirectory: true)
        return path.appendingPathComponent("\(type.rawValue).txt")
    }

}
