//
//  AutofillLoginPromptViewModelTests.swift
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

import XCTest
@testable import DuckDuckGo
@testable import BrowserServicesKit

// swiftlint:disable:next type_body_length
final class AutofillLoginPromptViewModelTests: XCTestCase {

    func testWhenOnePerfectMatchAndNoPartialMatchesThenOnePerfectMatchShownAndMoreOptionsNotShown() {
        let accountMatches = AccountMatches(perfectMatches: [websiteAccountFor(domain: "example.com")],
                                            partialMatches: [:])
        let autofillLoginPromptViewModel = AutofillLoginPromptViewModel(accounts: accountMatches,
                                                                        domain: "example.com",
                                                                        isExpanded: false)
        XCTAssertEqual(autofillLoginPromptViewModel.accountMatchesViewModels.count, 1)
        XCTAssertTrue(autofillLoginPromptViewModel.accountMatchesViewModels[0].isPerfectMatch)
        XCTAssertEqual(autofillLoginPromptViewModel.accountMatchesViewModels[0].accounts.count, 1)
        XCTAssertFalse(autofillLoginPromptViewModel.showMoreOptions)
    }

    func testWhenTwoPerfectMatchAndNoPartialMatchesThenTwoPerfectMatchesShownAndMoreOptionsNotShown() {
        let accountMatches = AccountMatches(perfectMatches: [websiteAccountFor(domain: "example.com", username: "dax@duck.com"),
                                                             websiteAccountFor(domain: "example.com", username: "dax2@duck.com")],
                                            partialMatches: [:])
        let autofillLoginPromptViewModel = AutofillLoginPromptViewModel(accounts: accountMatches,
                                                                                      domain: "example.com",
                                                                                      isExpanded: false)
        XCTAssertEqual(autofillLoginPromptViewModel.accountMatchesViewModels.count, 1)
        XCTAssertTrue(autofillLoginPromptViewModel.accountMatchesViewModels[0].isPerfectMatch)
        XCTAssertEqual(autofillLoginPromptViewModel.accountMatchesViewModels[0].accounts.count, 2)
        XCTAssertFalse(autofillLoginPromptViewModel.showMoreOptions)
    }

    func testWhenThreePerfectMatchAndNoPartialMatchesThenThreePerfectMatchesShownAndMoreOptionsNotShown() {
        let accountMatches = AccountMatches(perfectMatches: [websiteAccountFor(domain: "example.com", username: "dax@duck.com"),
                                                             websiteAccountFor(domain: "example.com", username: "dax2@duck.com"),
                                                             websiteAccountFor(domain: "example.com", username: "dax3@duck.com")],
                                            partialMatches: [:])
        let autofillLoginPromptViewModel = AutofillLoginPromptViewModel(accounts: accountMatches,
                                                                        domain: "example.com",
                                                                        isExpanded: false)
        XCTAssertEqual(autofillLoginPromptViewModel.accountMatchesViewModels.count, 1)
        XCTAssertTrue(autofillLoginPromptViewModel.accountMatchesViewModels[0].isPerfectMatch)
        XCTAssertEqual(autofillLoginPromptViewModel.accountMatchesViewModels[0].accounts.count, 3)
        XCTAssertFalse(autofillLoginPromptViewModel.showMoreOptions)
    }

    func testWhenFourPerfectMatchAndNoPartialMatchesThenTwoPerfectMatchesAndMoreOptionsShown() {
        let accountMatches = AccountMatches(perfectMatches: [websiteAccountFor(domain: "example.com", username: "dax@duck.com"),
                                                             websiteAccountFor(domain: "example.com", username: "dax2@duck.com"),
                                                             websiteAccountFor(domain: "example.com", username: "dax3@duck.com"),
                                                             websiteAccountFor(domain: "example.com", username: "dax4@duck.com")],
                                            partialMatches: [:])
        let autofillLoginPromptViewModel = AutofillLoginPromptViewModel(accounts: accountMatches,
                                                                        domain: "example.com",
                                                                        isExpanded: false)
        XCTAssertEqual(autofillLoginPromptViewModel.accountMatchesViewModels.count, 1)
        XCTAssertTrue(autofillLoginPromptViewModel.accountMatchesViewModels[0].isPerfectMatch)
        XCTAssertEqual(autofillLoginPromptViewModel.accountMatchesViewModels[0].accounts.count, 2)
        XCTAssertTrue(autofillLoginPromptViewModel.showMoreOptions)
    }

    func testWhenOnePerfectMatchAndOnePartialMatchThenOnePerfectMatchAndMoreOptionsShown() {
        let accountMatches = AccountMatches(perfectMatches: [websiteAccountFor(domain: "example.com", username: "dax@duck.com")],
                                            partialMatches: ["sub.example.com": [
                                                websiteAccountFor(domain: "sub.example.com", username: "dax@duck.com")]
                                            ])
        let autofillLoginPromptViewModel = AutofillLoginPromptViewModel(accounts: accountMatches,
                                                                        domain: "example.com",
                                                                        isExpanded: false)
        XCTAssertEqual(autofillLoginPromptViewModel.accountMatchesViewModels.count, 1)
        XCTAssertTrue(autofillLoginPromptViewModel.accountMatchesViewModels[0].isPerfectMatch)
        XCTAssertEqual(autofillLoginPromptViewModel.accountMatchesViewModels[0].accounts.count, 1)
        XCTAssertTrue(autofillLoginPromptViewModel.showMoreOptions)
    }

    func testWhenTwoPerfectMatchesAndOnePartialMatchThenTwoPerfectMatchesAndMoreOptionsShown() {
        let accountMatches = AccountMatches(perfectMatches: [websiteAccountFor(domain: "example.com", username: "dax@duck.com"),
                                                             websiteAccountFor(domain: "example.com", username: "dax1@duck.com")],
                                            partialMatches: ["sub.example.com": [
                                                websiteAccountFor(domain: "sub.example.com", username: "dax@duck.com")]
                                            ])
        let autofillLoginPromptViewModel = AutofillLoginPromptViewModel(accounts: accountMatches,
                                                                        domain: "example.com",
                                                                        isExpanded: false)
        XCTAssertEqual(autofillLoginPromptViewModel.accountMatchesViewModels.count, 1)
        XCTAssertTrue(autofillLoginPromptViewModel.accountMatchesViewModels[0].isPerfectMatch)
        XCTAssertEqual(autofillLoginPromptViewModel.accountMatchesViewModels[0].accounts.count, 2)
        XCTAssertTrue(autofillLoginPromptViewModel.showMoreOptions)
    }

    func testWhenThreePerfectMatchAndOnePartialMatchesThenTwoPerfectMatchesAndMoreOptionsShown() {
        let accountMatches = AccountMatches(perfectMatches: [websiteAccountFor(domain: "example.com", username: "dax@duck.com"),
                                                             websiteAccountFor(domain: "example.com", username: "dax1@duck.com"),
                                                             websiteAccountFor(domain: "example.com", username: "dax2@duck.com")],
                                            partialMatches: ["sub.example.com": [
                                                websiteAccountFor(domain: "sub.example.com", username: "dax@duck.com")]
                                            ])
        let autofillLoginPromptViewModel = AutofillLoginPromptViewModel(accounts: accountMatches,
                                                                        domain: "example.com",
                                                                        isExpanded: false)
        XCTAssertEqual(autofillLoginPromptViewModel.accountMatchesViewModels.count, 1)
        XCTAssertTrue(autofillLoginPromptViewModel.accountMatchesViewModels[0].isPerfectMatch)
        XCTAssertEqual(autofillLoginPromptViewModel.accountMatchesViewModels[0].accounts.count, 2)
        XCTAssertTrue(autofillLoginPromptViewModel.showMoreOptions)
    }

    func testWhenFourPerfectMatchAndOnePartialMatchesThenTwoPerfectMatchesAndMoreOptionsShown() {
        let accountMatches = AccountMatches(perfectMatches: [websiteAccountFor(domain: "example.com", username: "dax@duck.com"),
                                                             websiteAccountFor(domain: "example.com", username: "dax1@duck.com"),
                                                             websiteAccountFor(domain: "example.com", username: "dax2@duck.com"),
                                                             websiteAccountFor(domain: "example.com", username: "dax3@duck.com")],
                                            partialMatches: ["sub.example.com": [
                                                websiteAccountFor(domain: "sub.example.com", username: "dax@duck.com")]
                                            ])
        let autofillLoginPromptViewModel = AutofillLoginPromptViewModel(accounts: accountMatches,
                                                                        domain: "example.com",
                                                                        isExpanded: false)
        XCTAssertEqual(autofillLoginPromptViewModel.accountMatchesViewModels.count, 1)
        XCTAssertTrue(autofillLoginPromptViewModel.accountMatchesViewModels[0].isPerfectMatch)
        XCTAssertEqual(autofillLoginPromptViewModel.accountMatchesViewModels[0].accounts.count, 2)
        XCTAssertTrue(autofillLoginPromptViewModel.showMoreOptions)
    }

    func testWhenOnePerfectMatchAndTwoPartialMatchesThenOnePerfectMatchAndMoreOptionsShown() {
        let accountMatches = AccountMatches(perfectMatches: [websiteAccountFor(domain: "example.com", username: "dax@duck.com")],
                                            partialMatches: ["sub.example.com": [
                                                websiteAccountFor(domain: "sub.example.com", username: "dax@duck.com")
                                            ],
                                                             "sub2.example.com": [
                                                                 websiteAccountFor(domain: "sub2.example.com", username: "dax@duck.com")]
                                            ])
        let autofillLoginPromptViewModel = AutofillLoginPromptViewModel(accounts: accountMatches,
                                                                        domain: "example.com",
                                                                        isExpanded: false)
        XCTAssertEqual(autofillLoginPromptViewModel.accountMatchesViewModels.count, 1)
        XCTAssertTrue(autofillLoginPromptViewModel.accountMatchesViewModels[0].isPerfectMatch)
        XCTAssertEqual(autofillLoginPromptViewModel.accountMatchesViewModels[0].accounts.count, 1)
        XCTAssertTrue(autofillLoginPromptViewModel.showMoreOptions)
    }

    func testWhenTwoPerfectMatchesAndTwoPartialMatchesThenTwoPerfectMatchesAndMoreOptionsShown() {
        let accountMatches = AccountMatches(perfectMatches: [websiteAccountFor(domain: "example.com", username: "dax@duck.com"),
                                                             websiteAccountFor(domain: "example.com", username: "dax2@duck.com")],
                                            partialMatches: ["sub.example.com": [
                                                websiteAccountFor(domain: "sub.example.com", username: "dax@duck.com")
                                            ],
                                                             "sub2.example.com": [
                                                                 websiteAccountFor(domain: "sub2.example.com", username: "dax@duck.com")]
                                            ])
        let autofillLoginPromptViewModel = AutofillLoginPromptViewModel(accounts: accountMatches,
                                                                        domain: "example.com",
                                                                        isExpanded: false)
        XCTAssertEqual(autofillLoginPromptViewModel.accountMatchesViewModels.count, 1)
        XCTAssertTrue(autofillLoginPromptViewModel.accountMatchesViewModels[0].isPerfectMatch)
        XCTAssertEqual(autofillLoginPromptViewModel.accountMatchesViewModels[0].accounts.count, 2)
        XCTAssertTrue(autofillLoginPromptViewModel.showMoreOptions)
    }

    func testWhenThreePerfectMatchesAndTwoPartialMatchesThenTwoPerfectMatchesAndMoreOptionsShown() {
        let accountMatches = AccountMatches(perfectMatches: [websiteAccountFor(domain: "example.com", username: "dax@duck.com"),
                                                             websiteAccountFor(domain: "example.com", username: "dax2@duck.com"),
                                                             websiteAccountFor(domain: "example.com", username: "dax3@duck.com")],
                                            partialMatches: ["sub.example.com": [
                                                websiteAccountFor(domain: "sub.example.com", username: "dax@duck.com")
                                            ],
                                                             "sub2.example.com": [
                                                                 websiteAccountFor(domain: "sub2.example.com", username: "dax@duck.com")]
                                            ])
        let autofillLoginPromptViewModel = AutofillLoginPromptViewModel(accounts: accountMatches,
                                                                        domain: "example.com",
                                                                        isExpanded: false)
        XCTAssertEqual(autofillLoginPromptViewModel.accountMatchesViewModels.count, 1)
        XCTAssertTrue(autofillLoginPromptViewModel.accountMatchesViewModels[0].isPerfectMatch)
        XCTAssertEqual(autofillLoginPromptViewModel.accountMatchesViewModels[0].accounts.count, 2)
        XCTAssertTrue(autofillLoginPromptViewModel.showMoreOptions)
    }

    func testWhenNoPerfectMatchAndOnePartialMatchThenPartialMatchShownAndMoreOptionsNotShown() {
        let accountMatches = AccountMatches(perfectMatches: [],
                                            partialMatches: ["sub.example.com": [
                                                websiteAccountFor(domain: "sub.example.com", username: "dax@duck.com")]
                                            ])
        let autofillLoginPromptViewModel = AutofillLoginPromptViewModel(accounts: accountMatches,
                                                                        domain: "example.com",
                                                                        isExpanded: false)
        XCTAssertEqual(autofillLoginPromptViewModel.accountMatchesViewModels.count, 1)
        XCTAssertFalse(autofillLoginPromptViewModel.accountMatchesViewModels[0].isPerfectMatch)
        XCTAssertEqual(autofillLoginPromptViewModel.accountMatchesViewModels[0].accounts.count, 1)
        XCTAssertFalse(autofillLoginPromptViewModel.showMoreOptions)
    }

    func testWhenNoPerfectMatchAndTwoPartialMatchesForSameSubdomainThenTwoPartialMatchesShownAndMoreOptionsNotShown() {
        let accountMatches = AccountMatches(perfectMatches: [],
                                            partialMatches: ["sub.example.com": [
                                                websiteAccountFor(domain: "sub.example.com", username: "dax@duck.com"),
                                                websiteAccountFor(domain: "sub.example.com", username: "dax2@duck.com")]
                                            ])
        let autofillLoginPromptViewModel = AutofillLoginPromptViewModel(accounts: accountMatches,
                                                                        domain: "example.com",
                                                                        isExpanded: false)
        XCTAssertEqual(autofillLoginPromptViewModel.accountMatchesViewModels.count, 1)
        XCTAssertFalse(autofillLoginPromptViewModel.accountMatchesViewModels[0].isPerfectMatch)
        XCTAssertEqual(autofillLoginPromptViewModel.accountMatchesViewModels[0].accounts.count, 2)
        XCTAssertFalse(autofillLoginPromptViewModel.showMoreOptions)
    }

    func testWhenNoPerfectMatchAndThreePartialMatchesForSameSubdomainThenThreePartialMatchesShownAndMoreOptionsNotShown() {
        let accountMatches = AccountMatches(perfectMatches: [],
                                            partialMatches: ["sub.example.com": [
                                                websiteAccountFor(domain: "sub.example.com", username: "dax@duck.com"),
                                                websiteAccountFor(domain: "sub.example.com", username: "dax2@duck.com"),
                                                websiteAccountFor(domain: "sub.example.com", username: "dax3@duck.com")]
                                            ])
        let autofillLoginPromptViewModel = AutofillLoginPromptViewModel(accounts: accountMatches,
                                                                        domain: "example.com",
                                                                        isExpanded: false)
        XCTAssertEqual(autofillLoginPromptViewModel.accountMatchesViewModels.count, 1)
        XCTAssertFalse(autofillLoginPromptViewModel.accountMatchesViewModels[0].isPerfectMatch)
        XCTAssertEqual(autofillLoginPromptViewModel.accountMatchesViewModels[0].accounts.count, 3)
        XCTAssertFalse(autofillLoginPromptViewModel.showMoreOptions)
    }

    func testWhenNoPerfectMatchAndFourPartialMatchesForSameSubdomainThenTwoPartialMatchesAndMoreOptionsShown() {
        let accountMatches = AccountMatches(perfectMatches: [],
                                            partialMatches: ["sub.example.com": [
                                                websiteAccountFor(domain: "sub.example.com", username: "dax@duck.com"),
                                                websiteAccountFor(domain: "sub.example.com", username: "dax2@duck.com"),
                                                websiteAccountFor(domain: "sub.example.com", username: "dax3@duck.com"),
                                                websiteAccountFor(domain: "sub.example.com", username: "dax4@duck.com")]
                                            ])
        let autofillLoginPromptViewModel = AutofillLoginPromptViewModel(accounts: accountMatches,
                                                                        domain: "example.com",
                                                                        isExpanded: false)
        XCTAssertEqual(autofillLoginPromptViewModel.accountMatchesViewModels.count, 1)
        XCTAssertFalse(autofillLoginPromptViewModel.accountMatchesViewModels[0].isPerfectMatch)
        XCTAssertEqual(autofillLoginPromptViewModel.accountMatchesViewModels[0].accounts.count, 2)
        XCTAssertTrue(autofillLoginPromptViewModel.showMoreOptions)
    }

    func testWhenNoPerfectMatchAndOnePartialMatchAndOnePartialMatchForDifferentSubdomainThenFirstPartialMatchAndMoreOptionsShown() {
        let accountMatches = AccountMatches(perfectMatches: [],
                                            partialMatches: ["sub.example.com": [
                                                                websiteAccountFor(domain: "sub.example.com", username: "dax@duck.com")
                                                            ], "sub2.example.com": [
                                                                 websiteAccountFor(domain: "sub2.example.com", username: "dax@duck.com")]
                                            ])
        let autofillLoginPromptViewModel = AutofillLoginPromptViewModel(accounts: accountMatches,
                                                                        domain: "example.com",
                                                                        isExpanded: false)
        XCTAssertEqual(autofillLoginPromptViewModel.accountMatchesViewModels.count, 1)
        XCTAssertFalse(autofillLoginPromptViewModel.accountMatchesViewModels[0].isPerfectMatch)
        XCTAssertEqual(autofillLoginPromptViewModel.accountMatchesViewModels[0].accounts.count, 1)
        XCTAssertTrue(autofillLoginPromptViewModel.showMoreOptions)
    }

    func testWhenNoPerfectMatchAndTwoPartialMatchesAndOnePartialMatchForDifferentSubdomainThenFirstTwoPartialMatchesAndMoreOptionsShown() {
        let accountMatches = AccountMatches(perfectMatches: [],
                                            partialMatches: ["sub.example.com": [
                                                websiteAccountFor(domain: "sub.example.com", username: "dax@duck.com"),
                                                websiteAccountFor(domain: "sub.example.com", username: "dax2@duck.com")
                                            ], "sub2.example.com": [
                                                websiteAccountFor(domain: "sub2.example.com", username: "dax@duck.com")]
                                            ])
        let autofillLoginPromptViewModel = AutofillLoginPromptViewModel(accounts: accountMatches,
                                                                        domain: "example.com",
                                                                        isExpanded: false)
        XCTAssertEqual(autofillLoginPromptViewModel.accountMatchesViewModels.count, 1)
        XCTAssertFalse(autofillLoginPromptViewModel.accountMatchesViewModels[0].isPerfectMatch)
        XCTAssertEqual(autofillLoginPromptViewModel.accountMatchesViewModels[0].accounts.count, 2)
        XCTAssertTrue(autofillLoginPromptViewModel.showMoreOptions)
    }

    func testWhenNoPerfectMatchAndThreePartialMatchesAndOnePartialMatchForDifferentSubdomainThenFirstTwoPartialMatchesAndMoreOptionsShown() {
        let accountMatches = AccountMatches(perfectMatches: [],
                                            partialMatches: ["sub.example.com": [
                                                websiteAccountFor(domain: "sub.example.com", username: "dax@duck.com"),
                                                websiteAccountFor(domain: "sub.example.com", username: "dax2@duck.com"),
                                                websiteAccountFor(domain: "sub.example.com", username: "dax3@duck.com")
                                            ], "sub2.example.com": [
                                                websiteAccountFor(domain: "sub2.example.com", username: "dax@duck.com")]
                                            ])
        let autofillLoginPromptViewModel = AutofillLoginPromptViewModel(accounts: accountMatches,
                                                                        domain: "example.com",
                                                                        isExpanded: false)
        XCTAssertEqual(autofillLoginPromptViewModel.accountMatchesViewModels.count, 1)
        XCTAssertFalse(autofillLoginPromptViewModel.accountMatchesViewModels[0].isPerfectMatch)
        XCTAssertEqual(autofillLoginPromptViewModel.accountMatchesViewModels[0].accounts.count, 2)
        XCTAssertTrue(autofillLoginPromptViewModel.showMoreOptions)
    }

    func testWhenNoPerfectMatchAndOnePartialMatchAndTwoPartialMatchesForDifferentSubdomainThenFirstPartialMatchAndMoreOptionsShown() {
        let accountMatches = AccountMatches(perfectMatches: [],
                                            partialMatches: ["sub.example.com": [
                                                websiteAccountFor(domain: "sub.example.com", username: "dax@duck.com")
                                            ], "sub2.example.com": [
                                                websiteAccountFor(domain: "sub2.example.com", username: "dax@duck.com"),
                                                websiteAccountFor(domain: "sub2.example.com", username: "dax2@duck.com")]
                                            ])
        let autofillLoginPromptViewModel = AutofillLoginPromptViewModel(accounts: accountMatches,
                                                                        domain: "example.com",
                                                                        isExpanded: false)
        XCTAssertEqual(autofillLoginPromptViewModel.accountMatchesViewModels.count, 1)
        XCTAssertFalse(autofillLoginPromptViewModel.accountMatchesViewModels[0].isPerfectMatch)
        XCTAssertEqual(autofillLoginPromptViewModel.accountMatchesViewModels[0].accounts.count, 1)
        XCTAssertTrue(autofillLoginPromptViewModel.showMoreOptions)
    }


    func websiteAccountFor(domain: String = "", username: String? = "") -> SecureVaultModels.WebsiteAccount {
        return SecureVaultModels.WebsiteAccount(id: "1", title: "", username: "", domain: domain, created: Date(), lastUpdated: Date())
    }
}
