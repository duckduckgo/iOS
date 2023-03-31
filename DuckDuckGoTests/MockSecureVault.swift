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

final class MockSecureVault: SecureVault {

    var storedAccounts: [SecureVaultModels.WebsiteAccount] = []
    var storedCredentials: [Int64: SecureVaultModels.WebsiteCredentials] = [:]
    var storedNotes: [SecureVaultModels.Note] = []
    var storedIdentities: [SecureVaultModels.Identity] = []
    var storedCards: [SecureVaultModels.CreditCard] = []

    func authWith(password: Data) throws -> SecureVault {
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
