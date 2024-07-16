//
//  OnboardingSuggestedSitesProvider.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

protocol OnboardingSuggestionsItemsProviding {
    var list: [ContextualOnboardingListItem] { get }
}

struct OnboardingSuggestedSitesProvider: OnboardingSuggestionsItemsProviding {
    private let countryProvider: OnboardingRegionAndLanguageProvider

    init(countryProvider: OnboardingRegionAndLanguageProvider = Locale.current) {
        self.countryProvider = countryProvider
    }

    enum Countries: String {
        case indonesia = "ID"
        case gb = "GB"
        case germany = "DE"
        case canada = "CA"
        case netherlands = "NL"
        case australia = "AU"
        case sweden = "SE"
        case ireland = "IE"
    }

    var list: [ContextualOnboardingListItem] {
        return [
            option1,
            option2,
            option3,
            surpriseMe
        ]
    }

    private var country: String {
        countryProvider.regionCode ?? ""
    }

    private var option1: ContextualOnboardingListItem {
        let site: String
        switch Countries(rawValue: country) {
        case .indonesia: site = "bolasport.com"
        case .gb: site = "skysports.com"
        case .germany: site = "kicker.de"
        case .canada: site = "tsn.ca"
        case .netherlands: site = "voetbalprimeur.nl"
        case .australia: site = "afl.com.au"
        case .sweden: site = "svenskafans.com"
        case .ireland: site = "skysports.com"
        default: site = "ESPN.com"
        }
        return ContextualOnboardingListItem.site(title: site)
    }

    private var option2: ContextualOnboardingListItem {
        let site: String
        switch Countries(rawValue: country) {
        case .indonesia: site = "kompas.com"
        case .gb: site = "bbc.co.uk"
        case .germany: site = "tagesschau.de"
        case .canada: site = "cbc.ca"
        case .netherlands: site = "nu.nl"
        case .australia: site = "abc.net.au"
        case .sweden: site = "dn.se"
        case .ireland: site = "bbc.co.uk"
        default: site = "yahoo.com"
        }
        return ContextualOnboardingListItem.site(title: site)
    }

    private var option3: ContextualOnboardingListItem {
        let site: String
        switch Countries(rawValue: country) {
        case .indonesia: site = "tokopedia.com"
        case .gb, .germany, .australia, .ireland: site = "eBay.com"
        case .canada: site = "canadiantire.ca"
        case .netherlands: site = "bol.com"
        case .sweden: site = "tradera.com"
        default: site = "eBay.com"
        }
        return ContextualOnboardingListItem.site(title: site)
    }

    private var surpriseMe: ContextualOnboardingListItem {
        let site: String
        switch Countries(rawValue: country) {
        case .germany: site = "https://www.duden.de/rechtschreibung/Ente"
        case .netherlands: site = "https://www.woorden.org/woord/eend"
        case .sweden: site = "https://www.synonymer.se/sv-syn/anka"
        default: site = "britannica.com/animal/duck"
        }
        return ContextualOnboardingListItem.surprise(title: site)
    }
}
