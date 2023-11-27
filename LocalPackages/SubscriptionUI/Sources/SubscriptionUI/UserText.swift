//
//  UserText.swift
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

enum UserText {
    // MARK: - Subscription preferences

    static let preferencesTitle = NSLocalizedString(
        "subscription.preferences.title",
        value: "Privacy Pro",
        comment: "Title for the preferences pane for the subscription"
    )

    static let vpnServiceTitle = NSLocalizedString(
        "subscription.preferences.services.vpn.title",
        value: "VPN",
        comment: "Title for the VPN service listed in the subscription preferences pane"
    )
    static let vpnServiceDescription = NSLocalizedString(
        "subscription.preferences.services.vpn.description",
        value: "Full-device protection with the VPN built for speed and security.",
        comment: "Description for the VPN service listed in the subscription preferences pane"
    )

    static let personalInformationRemovalServiceTitle = NSLocalizedString(
        "subscription.preferences.services.personal.information.removal.title",
        value: "Personal Information Removal",
        comment: "Title for the Personal Information Removal service listed in the subscription preferences pane"
    )
    static let personalInformationRemovalServiceDescription = NSLocalizedString(
        "subscription.preferences.services.personal.information.removal.description",
        value: "Find and remove your personal information from sites that store and sell it.",
        comment: "Description for the Personal Information Removal service listed in the subscription preferences pane"
    )

    static let identityTheftRestorationServiceTitle = NSLocalizedString(
        "subscription.preferences.services.identity.theft.restoration.title",
        value: "Identity Theft Restoration",
        comment: "Title for the Identity Theft Restoration service listed in the subscription preferences pane"
    )
    static let identityTheftRestorationServiceDescription = NSLocalizedString(
        "subscription.preferences.services.identity.theft.restoration.description",
        value: "Restore stolen accounts and financial losses in the event of identity theft.",
        comment: "Description for the Identity Theft Restoration service listed in the subscription preferences pane"
    )

    // MARK: Preferences footer
    static let preferencesSubscriptionFooterTitle = NSLocalizedString(
        "subscription.preferences.subscription.footer.title",
        value: "Questions about Privacy Pro?",
        comment: "Title for the subscription preferences pane footer"
    )
    static let preferencesSubscriptionFooterCaption = NSLocalizedString(
        "subscription.preferences.subscription.footer.caption",
        value: "Visit our Privacy Pro help pages for answers to frequently asked questions.",
        comment: "Caption for the subscription preferences pane footer"
    )
    static let viewFaqsButton = NSLocalizedString(
        "subscription.preferences.view.faqs.button",
        value: "View FAQs",
        comment: "Button to open page for FAQs"
    )

    // MARK: Preferences when subscription is active
    static let preferencesSubscriptionActiveHeader = NSLocalizedString(
        "subscription.preferences.subscription.active.header",
        value: "Privacy Pro is active on this device",
        comment: "Header for the subscription preferences pane when the subscription is active"
    )
    static let preferencesSubscriptionActiveCaption = NSLocalizedString(
        "subscription.preferences.subscription.active.caption",
        value: "Your monthly Privacy Pro subscription renews on April 20, 2027.",
        comment: "Caption for the subscription preferences pane when the subscription is active"
    )

    static let addToAnotherDeviceButton = NSLocalizedString(
        "subscription.preferences.add.to.another.device.button",
        value: "Add to Another Device…",
        comment: "Button to add subscription to another device"
    )
    static let manageSubscriptionButton = NSLocalizedString(
        "subscription.preferences.manage.subscription.button",
        value: "Manage Subscription",
        comment: "Button to manage subscription"
    )
    static let changePlanOrBillingButton = NSLocalizedString(
        "subscription.preferences.change.plan.or.billing.button",
        value: "Change Plan or Billing...",
        comment: "Button to add subscription to another device"
    )
    static let removeFromThisDeviceButton = NSLocalizedString(
        "subscription.preferences.remove.from.this.device.button",
        value: "Remove From This Device...",
        comment: "Button to remove subscription from this device"
    )

    // MARK: Preferences when subscription is inactive
    static let preferencesSubscriptionInactiveHeader = NSLocalizedString(
        "subscription.preferences.subscription.inactive.header",
        value: "One subscription, three advanced protections",
        comment: "Header for the subscription preferences pane when the subscription is inactive"
    )
    static let preferencesSubscriptionInactiveCaption = NSLocalizedString(
        "subscription.preferences.subscription.inactive.caption",
        value: "Get enhanced protection across all your devices and reduce your online footprint for as little as $9.99/mo.",
        comment: "Caption for the subscription preferences pane when the subscription is inactive"
    )

    static let learnMoreButton = NSLocalizedString(
        "subscription.preferences.learn.more.button",
        value: "Learn More",
        comment: "Button to open a page where user can learn more and purchase the subscription"
    )
    static let haveSubscriptionButton = NSLocalizedString(
        "subscription.preferences.i.have.a.subscription.button",
        value: "I Have a Subscription",
        comment: "Button enabling user to activate a subscription user bought earlier or on another device"
    )

    // MARK: - Remove from this device dialog
    static let removeSubscriptionDialogTitle = NSLocalizedString(
        "subscription.dialog.remove.title",
        value: "Remove From This Device?",
        comment: "Remove subscription from device dialog title"
    )
    static let removeSubscriptionDialogDescription = NSLocalizedString(
        "subscription.dialog.remove.description",
        value: "You will no longer be able to access your Privacy Pro subscription on this device. This will not cancel your subscription, and it will remain active on your other devices.",
        comment: "Remove subscription from device dialog subtitle description"
    )
    static let removeSubscriptionDialogCancel = NSLocalizedString(
        "subscription.dialog.remove.cancel.button",
        value: "Cancel",
        comment: "Button to cancel removing subscription from device"
    )
    static let removeSubscriptionDialogConfirm = NSLocalizedString(
        "subscription.dialog.remove.confirm",
        value: "Remove Subscription",
        comment: "Button to confirm removing subscription from device"
    )

    // MARK: - Services for accessing the subscription
    static let appleID = NSLocalizedString(
        "subscription.access.channel.appleid.name",
        value: "Apple ID",
        comment: "Service name displayed when accessing subscription using AppleID account"
    )
    static let email = NSLocalizedString(
        "subscription.access.channel.email.name",
        value: "Email",
        comment: "Service name displayed when accessing subscription using email address"
    )
    static let sync = NSLocalizedString(
        "subscription.access.channel.sync.name",
        value: "Sync",
        comment: "Service name displayed when accessing sync feature"
    )

    // MARK: - Activate subscription modal
    static let activateModalTitle = NSLocalizedString(
        "subscription.activate.modal.title",
        value: "Activate your subscription on this device",
        comment: "Activate subscription modal view title"
    )
    static let activateModalDescription = NSLocalizedString(
        "subscription.activate.modal.description",
        value: "Access your Privacy Pro subscription on this device via Sync, Apple ID or an email address.",
        comment: "Activate subscription modal view subtitle description"
    )

    static let activateModalAppleIDDescription = NSLocalizedString(
        "subscription.activate.modal.appleid.description",
        value: "Your subscription is automatically available on any device signed in to the same Apple ID.",
        comment: "Activate subscription modal description for Apple ID channel"
    )
    static let activateModalEmailDescription = NSLocalizedString(
        "subscription.activate.modal.email.description",
        value: "Use your email to access your subscription on this device.",
        comment: "Activate subscription modal description for email address channel"
    )
    static let activateModalSyncDescription = NSLocalizedString(
        "subscription.activate.modal.sync.description",
        value: "Privacy Pro is automatically available on your Synced devices. Manage your synced devices in Sync settings.",
        comment: "Activate subscription modal description for sync service channel"
    )

    // MARK: - Share subscription modal
    static let shareModalTitle = NSLocalizedString(
        "subscription.share.modal.title",
        value: "Use your subscription on all your devices",
        comment: "Share subscription modal view title"
    )
    static let shareModalDescription = NSLocalizedString(
        "subscription.share.modal.description",
        value: "Access your Privacy Pro subscription on any of your devices via Sync, Apple ID or by adding an email address.",
        comment: "Share subscription modal view subtitle description"
    )

    static let shareModalAppleIDDescription = NSLocalizedString(
        "subscription.share.modal.appleid.description",
        value: "Your subscription is automatically available on any device signed in to the same Apple ID.",
        comment: "Share subscription modal description for Apple ID channel"
    )
    static let shareModalHasEmailDescription = NSLocalizedString(
        "subscription.share.modal.has.email.description",
        value: "You can use this email to activate your subscription on your other devices.",
        comment: "Share subscription modal description for email address channel"
    )
    static let shareModalNoEmailDescription = NSLocalizedString(
        "subscription.share.modal.no.email.description",
        value: "Add an email address to access your subscription on your other devices. We’ll only use this address to verify your subscription.",
        comment: "Share subscription modal description for email address channel"
    )
    static let shareModalSyncDescription = NSLocalizedString(
        "subscription.share.modal.sync.description",
        value: "Privacy Pro is automatically available on your Synced devices. Manage your synced devices in Sync settings.",
        comment: "Share subscription modal description for sync service channel"
    )

    // MARK: - Activate/share modal buttons
    static let restorePurchasesButton = NSLocalizedString(
        "subscription.modal.restore.purchases.button",
        value: "Restore Purchases",
        comment: "Button for restoring past subscription purchases"
    )
    static let manageEmailButton = NSLocalizedString(
        "subscription.modal.manage.email.button",
        value: "Manage",
        comment: "Button for opening manage email address page"
    )
    static let enterEmailButton = NSLocalizedString(
        "subscription.modal.enter.email.button",
        value: "Enter Email",
        comment: "Button for opening page to enter email address"
    )
    static let goToSyncSettingsButton = NSLocalizedString(
        "subscription.modal.sync.settings.button",
        value: "Go to Sync Settings",
        comment: "Button to open sync settings"
    )
}
