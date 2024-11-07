//
//  OnboardingPixelReporterMock.swift
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
import Core
import Onboarding
@testable import DuckDuckGo

final class OnboardingPixelReporterMock: OnboardingIntroPixelReporting, OnboardingSiteSuggestionsPixelReporting, OnboardingSearchSuggestionsPixelReporting, OnboardingCustomInteractionPixelReporting, OnboardingDaxDialogsReporting, OnboardingAddToDockReporting {
    private(set) var didCallTrackOnboardingIntroImpression = false
    private(set) var didCallTrackBrowserComparisonImpression = false
    private(set) var didCallTrackChooseBrowserCTAAction = false
    private(set) var didCallTrackChooseAppIconImpression = false
    private(set) var didCallTrackChooseCustomAppIconColor = false
    private(set) var didCallTrackAddressBarPositionSelectionImpression = false
    private(set) var didCallTrackChooseBottomAddressBarPosition = false
    private(set) var didCallTrackSearchOptionTapped = false
    private(set) var didCallTrackSiteOptionTapped = false
    private(set) var didCallTrackCustomSearch = false
    private(set) var didCallTrackCustomSite = false
    private(set) var didCallTrackSecondSiteVisit = false {
        didSet {
            secondSiteVisitCounter += 1
        }
    }
    private(set) var secondSiteVisitCounter = 0
    private(set) var didCallTrackScreenImpressionCalled = false
    private(set) var capturedScreenImpression: Pixel.Event?
    private(set) var didCallTrackPrivacyDashboardOpenedForFirstTime = false
    private(set) var didCallTrackEndOfJourneyDialogDismiss = false

    private(set) var didCallTrackAddToDockPromoImpression = false
    private(set) var didCallTrackAddToDockPromoShowTutorialCTAAction = false
    private(set) var didCallTrackAddToDockPromoDismissCTAAction = false
    private(set) var didCallTrackAddToDockTutorialDismissCTAAction = false

    func trackOnboardingIntroImpression() {
        didCallTrackOnboardingIntroImpression = true
    }

    func trackBrowserComparisonImpression() {
        didCallTrackBrowserComparisonImpression = true
    }

    func trackChooseBrowserCTAAction() {
        didCallTrackChooseBrowserCTAAction = true
    }

    func trackChooseAppIconImpression() {
        didCallTrackChooseAppIconImpression = true
    }

    func trackChooseCustomAppIconColor() {
        didCallTrackChooseCustomAppIconColor = true
    }

    func trackAddressBarPositionSelectionImpression() {
        didCallTrackAddressBarPositionSelectionImpression = true
    }

    func trackChooseBottomAddressBarPosition() {
        didCallTrackChooseBottomAddressBarPosition = true
    }

    func trackEndOfJourneyDialogCTAAction() {
        didCallTrackEndOfJourneyDialogDismiss = true
    }

    func trackSiteSuggetionOptionTapped() {
        didCallTrackSiteOptionTapped = true
    }

    func trackSearchSuggetionOptionTapped() {
        didCallTrackSearchOptionTapped = true
    }

    func trackCustomSearch() {
        didCallTrackCustomSearch = true
    }

    func trackCustomSite() {
        didCallTrackCustomSite = true
    }

    func trackSecondSiteVisit() {
        didCallTrackSecondSiteVisit = true
    }

    func trackScreenImpression(event: Pixel.Event) {
        didCallTrackScreenImpressionCalled = true
        capturedScreenImpression = event
    }

    func trackPrivacyDashboardOpenedForFirstTime() {
        didCallTrackPrivacyDashboardOpenedForFirstTime = true
    }

    func trackAddToDockPromoImpression() {
        didCallTrackAddToDockPromoImpression = true
    }

    func trackAddToDockPromoShowTutorialCTAAction() {
        didCallTrackAddToDockPromoShowTutorialCTAAction = true
    }

    func trackAddToDockPromoDismissCTAAction() {
        didCallTrackAddToDockPromoDismissCTAAction = true
    }

    func trackAddToDockTutorialDismissCTAAction() {
        didCallTrackAddToDockTutorialDismissCTAAction = true
    }
}
