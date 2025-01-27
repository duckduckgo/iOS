//
//  UserText.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

struct UserText {

    static let favoritesWidgetGalleryDisplayName = NSLocalizedString("widget.gallery.search.and.favorites.display.name",
                                                                     value: "Search and Favorites",
                                                                     comment: "Display name for search and favorites widget in widget gallery")

    static let favoritesWidgetGalleryDescription = NSLocalizedString("widget.gallery.search.and.favorites.description",
                                                                     value: "Search or visit your favorite sites privately with just one tap.",
                                                                     comment: "Description of search and favorites widget in widget gallery")

    static let searchWidgetGalleryDisplayName = NSLocalizedString("widget.gallery.search.display.name",
                                                                  value: "Search",
                                                                  comment: "Display name for search only widget in widget gallery")

    static let searchWidgetGalleryDescription = NSLocalizedString("widget.gallery.search.description",
                                                                  value: "Quickly launch a private search in DuckDuckGo.",
                                                                  comment: "Description of search only widget in widget gallery")

    static let searchDuckDuckGo = NSLocalizedString("widget.search.duckduckgo",
                                                    value: "Search DuckDuckGo",
                                                    comment: "Placeholder text in search field on the search and favorites widget")

    static let quickActionsSearch = NSLocalizedString("widget.quickactions.search",
                                          value: "Search",
                                          comment: "Placeholder text in search field on the quick actions widget")

    static let noFavoritesMessage = NSLocalizedString("widget.no.favorites.message",
                                                      value: "Quickly visit your favorite sites.",
                                                      comment: "Message shown in the favorites widget empty state.")

    static let noFavoritesCTA = NSLocalizedString("widget.no.favorites.cta",
                                                  value: "Add Favorites",
                                                  comment: "CTA shown in the favorites widget empty state.")

    static let passwordsWidgetGalleryDisplayName = NSLocalizedString("widget.gallery.passwords.display.name",
                                                                  value: "Search Passwords",
                                                                  comment: "Display name for search passwords widget in widget gallery")


    static let passwordsWidgetGalleryDescription = NSLocalizedString("widget.gallery.passwords.description",
                                                                  value: "Quickly search your saved DuckDuckGo passwords.",
                                                                  comment: "Description of search passwords widget in widget gallery")

    static let quickActionsWidgetGalleryDisplayName = NSLocalizedString("widget.gallery.quickactions.display.name",
                                                                  value: "Shortcuts",
                                                                  comment: "Display name for quick actions widget in widget gallery")

    static let quickActionsWidgetGalleryDescription = NSLocalizedString("widget.gallery.quickactions.description",
                                                                  value: "Search, chat on Duck.ai, or view your passwords.",
                                                                  comment: "Description of quickActions widget in widget gallery")

    static let passwords = NSLocalizedString("widget.passwords",
                                             value: "Search Passwords",
                                             comment: "Text in passwords widget")

    static let vpnWidgetGalleryDisplayName = NSLocalizedString("widget.gallery.vpn.display.name",
                                                               value: "VPN",
                                                               comment: "Display name for VPN widget in widget gallery")

    static let vpnWidgetGalleryDescription = NSLocalizedString("widget.gallery.vpn.description",
                                                               value: "View and manage your VPN connection. Requires a Privacy Pro subscription.",
                                                               comment: "Description of VPN widget in widget gallery")

    static let vpnWidgetConnectedStatus = NSLocalizedString("widget.vpn.status.connected",
                                                            value: "VPN is On",
                                                            comment: "Message describing VPN connected status")

    static let vpnWidgetSnoozingStatus = NSLocalizedString("widget.vpn.status.snoozed",
                                                            value: "VPN is Snoozed",
                                                            comment: "Message describing VPN snoozing status")

    static let vpnWidgetDisconnectedStatus = NSLocalizedString("widget.vpn.status.disconnected",
                                                               value: "VPN is Off",
                                                               comment: "Message describing VPN disconnected status")

    static let vpnWidgetDisconnectedSubtitle = NSLocalizedString("widget.vpn.subtitle.disconnected",
                                                                 value: "Not connected",
                                                                 comment: "Subtitle describing VPN disconnected status")

    static let vpnWidgetConnectButton = NSLocalizedString("widget.vpn.button.connect",
                                                          value: "Connect",
                                                          comment: "VPN connect button text")

    static let vpnWidgetDisconnectButton = NSLocalizedString("widget.vpn.button.disconnect",
                                                             value: "Disconnect",
                                                             comment: "VPN disconnect button text")

    static let vpnWidgetLiveActivityVPNSnoozingStatusLabel = NSLocalizedString("widget.vpn.live-activity.label.snoozing",
                                                                     value: "VPN Snoozing",
                                                                     comment: "VPN Live Activity snoozing label text")

    static let vpnWidgetLiveActivityVPNActiveStatusLabel = NSLocalizedString("widget.vpn.live-activity.label.active",
                                                                     value: "VPN is On",
                                                                     comment: "VPN Live Activity active label text")

    static let vpnWidgetLiveActivityWakeUpButton = NSLocalizedString("widget.vpn.live-activity.button.wake-up",
                                                                     value: "Wake Up",
                                                                     comment: "VPN Live Activity wake up button text")

    static let vpnWidgetLiveActivityDismissButton = NSLocalizedString("widget.vpn.live-activity.button.dismiss",
                                                                      value: "Dismiss",
                                                                      comment: "VPN Live Activity dismiss button text")

    static func vpnWidgetSnoozingUntil(endDate: String) -> String {
        let localized = NSLocalizedString("widget.vpn.label.snoozing-until", value: "Until %@", comment: "Label for the snooze end date, e.g. 'Until 9:51 AM'")
        return localized.format(arguments: endDate)
    }

    // MARK: - Control Center Widget

    static let vpnControlWidgetOn = NSLocalizedString(
        "vpn.control.widget.on",
        value: "VPN is ON",
        comment: "Title for the control widget when enabled")

    static let vpnControlWidgetOff = NSLocalizedString(
        "vpn.control.widget.off",
        value: "VPN is OFF",
        comment: "Title for the control widget when disabled")

    static let vpnControlWidgetLocationUnknown = NSLocalizedString(
        "vpn.control.widget.location-unknown",
        value: "Unknown Location",
        comment: "Description for the control widget when the location is unknown")

    static let vpnControlWidgetConnecting = NSLocalizedString(
        "vpn.control.widget.connecting",
        value: "Connecting...",
        comment: "Description for the control widget when connecting")

    static let vpnControlWidgetDisconnecting = NSLocalizedString(
        "vpn.control.widget.disconnecting",
        value: "Disconnecting...",
        comment: "Description for the control widget when disconnecting")

    static let vpnControlWidgetNotConnected = NSLocalizedString(
        "vpn.control.widget.not-connected",
        value: "Not Connected",
        comment: "Description for the control widget when not connected")

    // MARK: - Misc...

    static let lockScreenSearchTitle = NSLocalizedString(
        "lock.screen.widget.search.title",
        value: "Private Search",
        comment: "Title shown to the user when adding the Search lock screen widget")

    static let lockScreenSearchDescription = NSLocalizedString(
        "lock.screen.widget.search.description",
        value: "Instantly start a private search in DuckDuckGo.",
        comment: "Description shown to the user when adding the Search lock screen widget")

    static let lockScreenFavoritesTitle = NSLocalizedString(
        "lock.screen.widget.favorites.title",
        value: "Favorites",
        comment: "Title shown to the user when adding the favorites lock screen widget")

    static let lockScreenFavoritesDescription = NSLocalizedString(
        "lock.screen.widget.favorites.description",
        value: "Quickly open your favorite websites with a tap.",
        comment: "Description shown to the user when adding the Search lock screen widget")

    static let lockScreenVoiceTitle = NSLocalizedString(
        "lock.screen.widget.voice.title",
        value: "Voice Search",
        comment: "Title shown to the user when adding the Voice Search lock screen widget")

    static let lockScreenVoiceDescription = NSLocalizedString(
        "lock.screen.widget.voice.description",
        value: "Instantly start a new private voice search in DuckDuckGo.",
        comment: "Description shown to the user when adding the Voice Search lock screen widget")

    static let lockScreenEmailTitle = NSLocalizedString(
        "lock.screen.widget.email.title",
        value: "Email Protection",
        comment: "Title shown to the user when adding the Email Protection lock screen widget")

    static let lockScreenEmailDescription = NSLocalizedString(
        "lock.screen.widget.email.description",
        value: "Instantly generate a new private Duck Address.",
        comment: "Description shown to the user when adding the Email Protection lock screen widget")

    static let lockScreenFireTitle = NSLocalizedString(
        "lock.screen.widget.fire.title",
        value: "Fire Button",
        comment: "Title shown to the user when adding the Fire Button lock screen widget")

    static let lockScreenFireDescription = NSLocalizedString(
        "lock.screen.widget.fire.description",
        value: "Instantly delete your browsing history and start a new private search in DuckDuckGo.",
        comment: "Description shown to the user when adding the Fire Button lock screen widget")

    static let lockScreenPasswordsTitle = NSLocalizedString(
        "lock.screen.widget.passwords.title",
        value: "Search Passwords",
        comment: "Title shown to the user when adding the Search Passwords lock screen widget")

    static let lockScreenPasswordsDescription = NSLocalizedString(
        "lock.screen.widget.passwords.description",
        value: "Quickly search your saved DuckDuckGo passwords.",
        comment: "Description shown to the user when adding the Search Passwords lock screen widget")

    static let lockScreenAIChatTitle = NSLocalizedString(
        "lock.screen.widget.aichat.title",
        value: "Duck.ai",
        comment: "Title shown to the user when adding the Duck.ai lock screen widget")

    static let lockScreenAIChatDescription = NSLocalizedString(
        "lock.screen.widget.aichat.description",
        value: "Quickly start a new AI chat in Duck.ai",
        comment: "Description shown to the user when adding the Duck.ai lock screen widget")

}
