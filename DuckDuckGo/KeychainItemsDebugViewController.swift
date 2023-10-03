//
//  KeychainItemsDebugViewController.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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

import UIKit
import WebKit
import Core

private struct KeychainItem {
    
    let secClass: SecClass
    let service: String?
    let account: String?
    let valueData: Data?
    let creationDate: Any?
    let modificationDate: Any?
    
    var value: String? {
        guard let valueData = valueData else { return nil }
        return String(data: valueData, encoding: .utf8)
    }
    
    var displayString: String {
        return """
        Service: \(service ?? "nil")
        Account: \(account ?? "nil")
        Value as String: \(value ?? "nil")
        Value data: \(String(describing: valueData))
        Creation date: \(String(describing: creationDate))
        Modification date: \(String(describing: modificationDate))
        """
    }
}

private enum SecClass: CaseIterable {

    case internetPassword
    case genericPassword
    case classCertificate
    case classKey
    case classIdentity
    
    var secClassCFString: CFString {
        switch self {
        case .internetPassword:
            return kSecClassInternetPassword
        case .genericPassword:
            return kSecClassGenericPassword
        case .classCertificate:
            return kSecClassCertificate
        case .classKey:
            return kSecClassKey
        case .classIdentity:
            return kSecClassIdentity
        }
    }
    
    var titleString: String {
        switch self {
        case .internetPassword:
            return "kSecClassInternetPassword"
        case .genericPassword:
            return "kSecClassGenericPassword"
        case .classCertificate:
            return "kSecClassCertificate"
        case .classKey:
            return "kSecClassKey"
        case .classIdentity:
            return "kSecClassIdentity"
        }
    }
    
    var items: [KeychainItem]? {
        let query: [String: Any] = [
            kSecClass as String: secClassCFString,
            kSecMatchLimit as String: kSecMatchLimitAll,
            kSecReturnAttributes as String: true,
            kSecReturnRef as String: true,
        ]
        
        var returnArrayRef: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &returnArrayRef)

        guard status == errSecSuccess,
              let returnArray = returnArrayRef as? [[String: Any]] else {
            
                return nil
        }

        return returnArray.map {
            KeychainItem(secClass: self,
                         service: $0[kSecAttrService as String] as? String,
                         account: $0[kSecAttrAccount as String] as? String,
                         valueData: $0[kSecValueData as String] as? Data,
                         creationDate: $0[kSecAttrCreationDate as String, default: "no creation"],
                         modificationDate: $0[kSecAttrModificationDate as String, default: "no modification"])
        }
    }
}

class KeychainItemsDebugViewController: UITableViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return SecClass.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SecClass.allCases[section].items?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return SecClass.allCases[section].titleString
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = SecClass.allCases[indexPath.section].items?[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "keychainItemCell")!
        cell.textLabel?.text = item?.displayString

        return cell
    }

}
