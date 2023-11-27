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
import GRDB

// swiftlint:disable file_length
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
    var storedNeverPromptWebsites = [SecureVaultModels.NeverPromptWebsites]()
    var storedNotes: [SecureVaultModels.Note] = []
    var storedIdentities: [SecureVaultModels.Identity] = []
    var storedCards: [SecureVaultModels.CreditCard] = []

    public required init(providers: MockSecureVaultDatabaseProviders) {}

    func getHashingSalt() throws -> Data? {
        nil
    }

    func getEncryptionKey() throws -> Data {
        Data()
    }

    func encrypt(_ data: Data, using key: Data) throws -> Data {
        data
    }

    func decrypt(_ data: Data, using key: Data) throws -> Data {
        data
    }

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
        return storedAccounts.filter { $0.domain?.contains(eTLDplus1) == true }
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

    func neverPromptWebsites() throws -> [SecureVaultModels.NeverPromptWebsites] {
        return storedNeverPromptWebsites
    }

    func hasNeverPromptWebsitesFor(domain: String) throws -> Bool {
        return !storedNeverPromptWebsites.filter { $0.domain == domain }.isEmpty
    }

    func storeNeverPromptWebsites(_ neverPromptWebsite: SecureVaultModels.NeverPromptWebsites) throws -> Int64 {
        if let neverPromptWebsiteId = neverPromptWebsite.id {
            storedNeverPromptWebsites.append(neverPromptWebsite)
            return neverPromptWebsiteId
        } else {
            storedNeverPromptWebsites.append(neverPromptWebsite)
            return -1
        }

    }

    func deleteAllNeverPromptWebsites() throws {
        storedNeverPromptWebsites = []
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

    func hasAccountFor(username: String?, domain: String?) throws -> Bool {
        storedAccounts.contains { $0.domain == domain && $0.username == username }
    }

    // MARK: - Sync Support

    func storeWebsiteCredentials(_ credentials: SecureVaultModels.WebsiteCredentials, in database: Database, encryptedUsing l2Key: Data, hashedUsing salt: Data?) throws -> Int64 {
        try storeWebsiteCredentials(credentials)
    }

    func inDatabaseTransaction(_ block: @escaping (Database) throws -> Void) throws {
    }

    func modifiedSyncableCredentials() throws -> [SecureVaultModels.SyncableCredentials] {
        []
    }

    func deleteSyncableCredentials(_ syncableCredentials: SecureVaultModels.SyncableCredentials, in database: Database) throws {
    }

    func storeSyncableCredentials(_ syncableCredentials: SecureVaultModels.SyncableCredentials, in database: Database, encryptedUsing l2Key: Data, hashedUsing salt: Data?) throws {
    }

    func syncableCredentialsForSyncIds(_ syncIds: any Sequence<String>, in database: Database) throws -> [SecureVaultModels.SyncableCredentials] {
        []
    }

    func syncableCredentialsForAccountId(_ accountId: Int64, in database: Database) throws -> SecureVaultModels.SyncableCredentials? {
        nil
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
    var _neverPromptWebsites = [SecureVaultModels.NeverPromptWebsites]()

    var db: GRDB.DatabaseWriter
    // swiftlint:enable identifier_name

    required init(file: URL = URL(string: "https://duckduckgo.com/")!, key: Data = Data()) throws {
        db = (try? DatabaseQueue(named: "Test"))!
    }

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

    func neverPromptWebsites() throws -> [SecureVaultModels.NeverPromptWebsites] {
        return _neverPromptWebsites
    }

    func hasNeverPromptWebsitesFor(domain: String) throws -> Bool {
        return false
    }

    func storeNeverPromptWebsite(_ neverPromptWebsite: SecureVaultModels.NeverPromptWebsites) throws -> Int64 {
        if let neverPromptWebsiteId = neverPromptWebsite.id {
            _neverPromptWebsites.append(neverPromptWebsite)
            return neverPromptWebsiteId
        } else {
            return -1
        }
    }

    func deleteAllNeverPromptWebsites() throws {
        _neverPromptWebsites.removeAll()
    }

    func updateNeverPromptWebsite(_ neverPromptWebsite: SecureVaultModels.NeverPromptWebsites) throws {
    }

    func insertNeverPromptWebsite(_ neverPromptWebsite: SecureVaultModels.NeverPromptWebsites) throws {
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

    // MARK: - Sync Support

    func hasAccountFor(username: String?, domain: String?) throws -> Bool {
        _accounts.contains { $0.username == username && $0.domain == domain }
    }

    func inTransaction(_ block: @escaping (GRDB.Database) throws -> Void) throws {
        try db.write { try block($0) }
    }

    func storeWebsiteCredentials(_ credentials: BrowserServicesKit.SecureVaultModels.WebsiteCredentials, in database: GRDB.Database) throws -> Int64 {
        try storeWebsiteCredentials(credentials)
    }

    func modifiedSyncableCredentials() throws -> [SecureVaultModels.SyncableCredentials] {
        []
    }

    func syncableCredentialsForSyncIds(_ syncIds: any Sequence<String>, in database: Database) throws -> [SecureVaultModels.SyncableCredentials] {
        []
    }

    func websiteCredentialsForAccountId(_ accountId: Int64, in database: Database) throws -> SecureVaultModels.WebsiteCredentials? {
        try websiteCredentialsForAccountId(accountId)
    }

    func syncableCredentialsForAccountId(_ accountId: Int64, in database: Database) throws -> SecureVaultModels.SyncableCredentials? {
        nil
    }

    func storeSyncableCredentials(_ syncableCredentials: SecureVaultModels.SyncableCredentials, in database: Database) throws {
    }

    func deleteSyncableCredentials(_ syncableCredentials: SecureVaultModels.SyncableCredentials, in database: Database) throws {
    }

    func updateSyncTimestamp(in database: Database, tableName: String, objectId: Int64, timestamp: Date?) throws {
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
