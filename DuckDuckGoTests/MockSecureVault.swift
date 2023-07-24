//
//  MockSecureVault.swift
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
import SecureStorage

typealias MockVaultFactory = SecureVaultFactory<MockSecureVault<MockDatabaseProvider>>

// swiftlint:disable:next identifier_name
let MockSecureVaultFactory = SecureVaultFactory<MockSecureVault>(
    makeCryptoProvider: {
        return MockCryptoProvider()
    }, makeKeyStoreProvider: {
        let provider = MockKeyStoreProvider()
        provider._l1Key = "key".data(using: .utf8)
        return provider
    }, makeDatabaseProvider: { key in
        return try MockDatabaseProvider(key: key)
    }
)

final class MockSecureVault<T: AutofillDatabaseProvider>: AutofillSecureVault {

    public typealias MockSecureVaultDatabaseProviders = SecureStorageProviders<T>

    var storedAccounts: [SecureVaultModels.WebsiteAccount] = []
    var storedCredentials: [Int64: SecureVaultModels.WebsiteCredentials] = [:]
    var storedNotes: [SecureVaultModels.Note] = []
    var storedIdentities: [SecureVaultModels.Identity] = []
    var storedCards: [SecureVaultModels.CreditCard] = []

    public required init(providers: MockSecureVaultDatabaseProviders) {}

    func authWith(password: Data) throws -> any AutofillSecureVault {
        return self
    }

    func resetL2Password(oldPassword: Data?, newPassword: Data) throws {}

    func accounts() throws -> [SecureVaultModels.WebsiteAccount] {
        return storedAccounts
    }

    func accountsFor(domain: String) throws -> [SecureVaultModels.WebsiteAccount] {
        return storedAccounts.filter { $0.domain == domain }
    }

    func accountsWithPartialMatchesFor(eTLDplus1: String) throws -> [BrowserServicesKit.SecureVaultModels.WebsiteAccount] {
        return storedAccounts.filter { $0.domain.contains(eTLDplus1) }
    }

    func websiteCredentialsFor(accountId: Int64) throws -> SecureVaultModels.WebsiteCredentials? {
        return storedCredentials[accountId]
    }

    func storeWebsiteCredentials(_ credentials: SecureVaultModels.WebsiteCredentials) throws -> Int64 {
        let accountID = Int64(credentials.account.id!)!
        storedCredentials[accountID] = credentials

        return accountID
    }

    func deleteWebsiteCredentialsFor(accountId: Int64) throws {
        storedCredentials[accountId] = nil
    }

    func notes() throws -> [SecureVaultModels.Note] {
        return storedNotes
    }

    func noteFor(id: Int64) throws -> SecureVaultModels.Note? {
        return storedNotes.first { $0.id == id }
    }

    func storeNote(_ note: SecureVaultModels.Note) throws -> Int64 {
        storedNotes.append(note)
        return note.id!
    }

    func deleteNoteFor(noteId: Int64) throws {
        storedNotes = storedNotes.filter { $0.id != noteId }
    }

    func identities() throws -> [SecureVaultModels.Identity] {
        return storedIdentities
    }

    func identityFor(id: Int64) throws -> SecureVaultModels.Identity? {
        return storedIdentities.first { $0.id == id }
    }

    func storeIdentity(_ identity: SecureVaultModels.Identity) throws -> Int64 {
        storedIdentities.append(identity)
        return identity.id!
    }

    func deleteIdentityFor(identityId: Int64) throws {
        storedIdentities = storedIdentities.filter { $0.id != identityId }
    }

    func creditCards() throws -> [SecureVaultModels.CreditCard] {
        return storedCards
    }

    func creditCardFor(id: Int64) throws -> SecureVaultModels.CreditCard? {
        return storedCards.first { $0.id == id }
    }

    func storeCreditCard(_ card: SecureVaultModels.CreditCard) throws -> Int64 {
        storedCards.append(card)
        return card.id!
    }

    func deleteCreditCardFor(cardId: Int64) throws {
        storedCards = storedCards.filter { $0.id != cardId }
    }

    func existingIdentityForAutofill(matching proposedIdentity: SecureVaultModels.Identity) throws -> SecureVaultModels.Identity? {
        return nil
    }

    func existingCardForAutofill(matching proposedCard: SecureVaultModels.CreditCard) throws -> SecureVaultModels.CreditCard? {
        return nil
    }

}

// MARK: - Mock Providers

class MockDatabaseProvider: AutofillDatabaseProvider {

    // swiftlint:disable identifier_name
    var _accounts = [SecureVaultModels.WebsiteAccount]()
    var _notes = [SecureVaultModels.Note]()
    var _identities = [Int64: SecureVaultModels.Identity]()
    var _creditCards = [Int64: SecureVaultModels.CreditCard]()
    var _forDomain = [String]()
    var _credentialsDict = [Int64: SecureVaultModels.WebsiteCredentials]()
    var _note: SecureVaultModels.Note?
    // swiftlint:enable identifier_name

    required init(file: URL = URL(string: "https://duckduckgo.com/")!, key: Data = Data()) throws {}

    static func recreateDatabase(withKey key: Data) throws -> Self {
        // swiftlint:disable:next force_cast
        return try MockDatabaseProvider(file: URL(string: "https://duck.com")!, key: Data()) as! Self
    }

    func storeWebsiteCredentials(_ credentials: SecureVaultModels.WebsiteCredentials) throws -> Int64 {
        if let accountIdString = credentials.account.id, let accountID = Int64(accountIdString) {
            _credentialsDict[accountID] = credentials
            return accountID
        } else {
            _credentialsDict[-1] = credentials
            return -1
        }
    }

    func websiteCredentialsForAccountId(_ accountId: Int64) throws -> SecureVaultModels.WebsiteCredentials? {
        return _credentialsDict[accountId]
    }

    func websiteAccountsForDomain(_ domain: String) throws -> [SecureVaultModels.WebsiteAccount] {
        self._forDomain.append(domain)
        return _accounts
    }

    func websiteAccountsForTopLevelDomain(_ eTLDplus1: String) throws -> [SecureVaultModels.WebsiteAccount] {
        self._forDomain.append(eTLDplus1)
        return _accounts
    }

    func deleteWebsiteCredentialsForAccountId(_ accountId: Int64) throws {
        self._accounts = self._accounts.filter { $0.id != String(accountId) }
    }

    func accounts() throws -> [SecureVaultModels.WebsiteAccount] {
        return _accounts
    }

    func notes() throws -> [SecureVaultModels.Note] {
        return _notes
    }

    func noteForNoteId(_ noteId: Int64) throws -> SecureVaultModels.Note? {
        return _note
    }

    func deleteNoteForNoteId(_ noteId: Int64) throws {
        self._notes = self._notes.filter { $0.id != noteId }
    }

    func storeNote(_ note: SecureVaultModels.Note) throws -> Int64 {
        _note = note
        return note.id ?? -1
    }

    func identities() throws -> [SecureVaultModels.Identity] {
        return Array(_identities.values)
    }

    func identityForIdentityId(_ identityId: Int64) throws -> SecureVaultModels.Identity? {
        return _identities[identityId]
    }

    func storeIdentity(_ identity: SecureVaultModels.Identity) throws -> Int64 {
        if let identityID = identity.id {
            _identities[identityID] = identity
            return identityID
        } else {
            return -1
        }
    }

    func deleteIdentityForIdentityId(_ identityId: Int64) throws {
        _identities.removeValue(forKey: identityId)
    }

    func creditCards() throws -> [SecureVaultModels.CreditCard] {
        return Array(_creditCards.values)
    }

    func creditCardForCardId(_ cardId: Int64) throws -> SecureVaultModels.CreditCard? {
        return _creditCards[cardId]
    }

    func storeCreditCard(_ creditCard: SecureVaultModels.CreditCard) throws -> Int64 {
        if let cardID = creditCard.id {
            _creditCards[cardID] = creditCard
            return cardID
        } else {
            return -1
        }
    }

    func deleteCreditCardForCreditCardId(_ cardId: Int64) throws {
        _creditCards.removeValue(forKey: cardId)
    }
}

class MockCryptoProvider: SecureStorageCryptoProvider {

    var passwordSalt: Data {
        return Data()
    }

    var keychainServiceName: String {
        return "service"
    }

    var keychainAccountName: String {
        return "account"
    }

    // swiftlint:disable identifier_name
    var _derivedKey: Data?
    var _decryptedData: Data?
    var _lastDataToDecrypt: Data?
    var _lastDataToEncrypt: Data?
    var _lastKey: Data?
    var hashingSalt: Data?
    // swiftlint:enable identifier_name

    func generateSecretKey() throws -> Data {
        return Data()
    }

    func generatePassword() throws -> Data {
        return Data()
    }

    func deriveKeyFromPassword(_ password: Data) throws -> Data {
        return _derivedKey!
    }

    func generateNonce() throws -> Data {
        return Data()
    }

    func encrypt(_ data: Data, withKey key: Data) throws -> Data {
        _lastDataToEncrypt = data
        _lastKey = key
        return data
    }

    func decrypt(_ data: Data, withKey key: Data) throws -> Data {
        _lastDataToDecrypt = data
        _lastKey = key

        guard let data = _decryptedData else {
            throw SecureStorageError.invalidPassword
        }

        return data
    }

    func generateSalt() throws -> Data {
        return Data()
    }

    func hashData(_ data: Data) throws -> String? {
        return ""
    }

    func hashData(_ data: Data, salt: Data?) throws -> String? {
        return ""
    }

}

class MockKeyStoreProvider: SecureStorageKeyStoreProvider {

    // swiftlint:disable identifier_name
    var _l1Key: Data?
    var _encryptedL2Key: Data?
    var _generatedPassword: Data?
    var _generatedPasswordCleared = false
    var _lastEncryptedL2Key: Data?
    // swiftlint:enable identifier_name

    var generatedPasswordEntryName: String {
        return ""
    }

    var l1KeyEntryName: String {
        return ""
    }

    var l2KeyEntryName: String {
        return ""
    }

    var keychainServiceName: String {
        return ""
    }

    func attributesForEntry(named: String, serviceName: String) -> [String: Any] {
        return [:]
    }

    func storeGeneratedPassword(_ password: Data) throws {
    }

    func generatedPassword() throws -> Data? {
        return _generatedPassword
    }

    func clearGeneratedPassword() throws {
        _generatedPasswordCleared = true
    }

    func storeL1Key(_ data: Data) throws {
    }

    func l1Key() throws -> Data? {
        return _l1Key
    }

    func storeEncryptedL2Key(_ data: Data) throws {
        _lastEncryptedL2Key = data
    }

    func encryptedL2Key() throws -> Data? {
        return _encryptedL2Key
    }

}
