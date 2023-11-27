//
//  ReturnUserMeasurement.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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
import BrowserServicesKit

protocol ReturnUserMeasurement {

    var isReturningUser: Bool { get }
    func installCompletedWithATB(_ atb: Atb)
    func updateStoredATB(_ atb: Atb)

}

class KeychainReturnUserMeasurement: ReturnUserMeasurement {

    static let SecureATBKeychainName = "returning-user-atb"

    struct Measurement {

        let oldATB: String?
        let newATB: String

    }

    /// Called from the `VariantManager` to determine which variant to use
    var isReturningUser: Bool {
        return hasAnyKeychainItems()
    }

    func installCompletedWithATB(_ atb: Atb) {
        writeSecureATB(atb.version)
    }

    /// Update the stored ATB with an even more generalised version of the ATB, if present.
    func updateStoredATB(_ atb: Atb) {
        guard let atb = atb.updateVersion else { return }
        writeSecureATB(atb)
    }

    private func writeSecureATB(_ atb: String) {
        let data = atb.data(using: .utf8)!

        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: Self.SecureATBKeychainName,
            kSecValueData as String: data,

            // We expect to only need access when the app is in the foreground and we want it to be migrated to new devices.
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked,

            // Just to be explicit that we don't want this stored in the cloud
            kSecAttrSynchronizable as String: false
        ]

        var status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecDuplicateItem {
            let attributesToUpdate: [String: Any] = [
                kSecValueData as String: data
            ]
            query.removeValue(forKey: kSecValueData as String)
            status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            if status != errSecSuccess {
                fireDebugPixel(.debugReturnUserUpdateATB, errorCode: status)
            }
        } else if status != errSecSuccess {
            fireDebugPixel(.debugReturnUserAddATB, errorCode: status)
        }

    }

    private func fireDebugPixel(_ event: Pixel.Event, errorCode: OSStatus) {
        Pixel.fire(pixel: event, withAdditionalParameters: [
            PixelParameters.returnUserErrorCode: "\(errorCode)"
        ])
    }

    /// Only check for keychain items created by *this* app.
    private func hasAnyKeychainItems() -> Bool {
        let possibleStorageClasses = [
            kSecClassGenericPassword,
            kSecClassKey
        ]
        return possibleStorageClasses.first(where: hasKeychainItemsInClass(_:)) != nil
    }

    private func hasKeychainItemsInClass(_ secClassCFString: CFString) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: secClassCFString,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true, // Needs to be true or returns nothing.
            kSecReturnRef as String: true,
        ]
        var returnArrayRef: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &returnArrayRef)
        guard status == errSecSuccess,
              let returnArray = returnArrayRef as? [String: Any] else {
            return false
        }
        return returnArray.count > 0
    }

}
