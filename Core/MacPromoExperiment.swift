//
//  MacPromoExperiment.swift
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
import Core
import UIKit
import LinkPresentation

/**
 Encapsulate logic for showing the two types of promo.

 Decision making for showing the promo is based on the following:
 * Is the RMF message with id `macos_promo_may2023` ready to show?  This handles the logic for when.
 * For the sheet: has it been shown already?  The RMF message handles this already (via dismiss button)
 * Is it enabled in the current cohort?

 */
public class MacPromoExperiment {

    static let promoId = "macos_promo_may2023"

    private var remoteMessagingStore: RemoteMessagingStoring
    private var randomBool: () -> Bool

    @UserDefaultsWrapper(key: .macPromoMay23Exp2Cohort, defaultValue: Cohort.unassigned.rawValue)
    private var cohortValue: String

    var cohort: Cohort {
        get {
            Cohort(rawValue: cohortValue)!
        }
        set {
            cohortValue = newValue.rawValue
        }
    }

    var message: RemoteMessageModel? {
        return remoteMessagingStore.fetchScheduledRemoteMessage()
    }

    init(remoteMessagingStore: RemoteMessagingStoring = AppDependencyProvider.shared.remoteMessagingStore,
         randomBool: @escaping () -> Bool = { Bool.random() }
    ) {
        self.remoteMessagingStore = remoteMessagingStore
        self.randomBool = randomBool
    }

    func shouldShowSheet() -> Bool {
        guard let remoteMessageToPresent = message else { return false }
        if remoteMessageToPresent.id == Self.promoId {
            assignCohort()
            return cohort == .sheet
        }
        return false
    }

    func shouldShowMessage() -> Bool {
        guard let remoteMessageToPresent = message else { return false }
        if remoteMessageToPresent.id == Self.promoId {
            assignCohort()
            return cohort == .message
        }
        // If there's a message to show that's not part of the experiement
        //  we should show it in case of genuine usage.
        return true
    }

    func sheetWasShown() {
        guard let remoteMessageToPresent = message else { return }
        Pixel.fire(pixel: .macPromoSheetShownUnique)
        remoteMessagingStore.dismissRemoteMessage(withId: remoteMessageToPresent.id)
    }

    func sheetWasDismissed() {
        Pixel.fire(pixel: .macPromoSheetDismissed)
    }

    func sheetPrimaryActionClicked() {
        Pixel.fire(pixel: .macPromoPrimaryActionClicked)
    }

    func dismissMessage() {
        remoteMessagingStore.dismissRemoteMessage(withId: Self.promoId)
    }

    func shareSheetFinished(_ messageId: String, activityType: UIActivity.ActivityType?, result: Bool, error: Error?) {
        guard messageId == Self.promoId else { return }
        dismissMessage()
        
        let cohort = cohort.rawValue
        var parameters = [
            "cohort": cohort,

            // Result returns false if the user opens it in DuckDuckGo (which causes the share sheet to get force closed)
            "success": "\(result || activityType?.rawValue == "com.duckduckgo.mobile.ios.ShareExtension")"
        ]

        if let error = error as? NSError {
            parameters["errorDomain"] = error.domain
            parameters["errorCode"] = "\(error.code)"
        }

        Pixel.fire(pixel: .shareLink, withAdditionalParameters: parameters)
        NotificationCenter.default.post(name: RemoteMessaging.Notifications.remoteMessagesDidChange, object: nil)
    }

    private func assignCohort() {
        guard cohort == .unassigned else { return }
        cohort = randomBool() ? .sheet : .message
    }

    enum Cohort: String {

        case sheet
        case message
        case unassigned

    }
}

class TitledURLActivityItem: NSObject, UIActivityItemSource, Identifiable {

    let id: String
    let url: URL
    let title: String

    init(_ url: URL, _ title: String) {
        self.id = url.absoluteString
        self.url = url
        self.title = title
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        url
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        url
    }

    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = title
        metadata.url = url
        return metadata
    }

}
