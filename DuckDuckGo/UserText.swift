//
//  UserText.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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


import Core


public struct UserText {
    
    public static let webPageFailedLoad = NSLocalizedString("web.page.load.failed", comment: "DuckDuckGo cannot load this page because...")

    public static let appUnlock = NSLocalizedString("app.authentication.unlock", comment: "Unlock DuckDuckGo")
    public static let homeLinkTitle = NSLocalizedString("home.link.title", comment: "DuckDuckGo Home")
    public static let searchDuckDuckGo = NSLocalizedString("search.hint.duckduckgo", comment: "Search or enter address")
    public static let webSessionCleared = NSLocalizedString("web.session.clear", comment: "Session cleared")
    public static let webSaveBookmarkDone = NSLocalizedString("web.url.save.bookmark.done", comment: "Bookmark saved")
    public static let webSaveFavoriteDone = NSLocalizedString("web.url.save.favorite.done", comment: "Favorite saved")

    public static let tabSwitcherTitleHasTabs = NSLocalizedString("tabswitcher.title.tabs", comment: "Private Tabs title")
    public static let tabSwitcherTitleNoTabs = NSLocalizedString("tabswitcher.title.notabs", comment: "No Tabs title")
        
    public static let actionPasteAndGo = NSLocalizedString("action.title.pasteAndGo", comment: "Paste and Go action")
    public static let actionRefresh = NSLocalizedString("action.title.refresh", comment: "Refresh action")
    public static let actionAdd = NSLocalizedString("action.title.add", comment: "Add action")
    public static let actionSave = NSLocalizedString("action.title.save", comment: "Save action")
    public static let actionCancel = NSLocalizedString("action.title.cancel", comment: "Cancel action")
    public static let actionNewTab = NSLocalizedString("action.title.newTab", comment: "New Tab action")
    public static let actionNewTabForUrl = NSLocalizedString("action.title.newTabForUrl", comment: "Open in New Tab action")
    public static let actionNewBackgroundTabForUrl = NSLocalizedString("action.title.newBackgroundTabForUrl", comment: "Open in New Background Tab action")
    public static let actionForgetAll = NSLocalizedString("action.title.forgetAll", comment: "Clear Tabs and Data action")
    public static let actionForgetAllDone = NSLocalizedString("action.title.forgetAllDone", comment: "Tabs and Data Cleared")
    public static let actionOpen = NSLocalizedString("action.title.open", comment: "Open action")
    public static let actionReadingList = NSLocalizedString("action.title.readingList", comment: "Reading List action")
    public static let actionCopy = NSLocalizedString("action.title.copy", comment: "Copy action")
    public static let actionShare = NSLocalizedString("action.title.share", comment: "Share action")
    public static let actionAddToWhitelist = NSLocalizedString("action.title.add.to.whitelist", comment: "Add to Whitelist action")
    public static let actionRemoveFromWhitelist = NSLocalizedString("action.title.remove.from.whitelist", comment: "Remove from Whitelist action")
    public static let actionRequestDesktopSite = NSLocalizedString("action.title.request.desktop.site", comment: "Request Mobile Site")
    public static let actionRequestMobileSite = NSLocalizedString("action.title.request.mobile.site", comment: "Request Desktop Site")
    public static let actionSaveBookmark = NSLocalizedString("action.title.save.bookmark", comment: "Save Bookmark action")
    public static let actionSaveFavorite = NSLocalizedString("action.title.save.favorite", comment: "Save Favorite action")
    public static let actionRemoveBookmark = NSLocalizedString("action.title.remove.bookmark", comment: "Remove Bookmark action")
    public static let actionReportBrokenSite = NSLocalizedString("action.title.reportBrokenSite", comment: "Report broken site action")
    public static let actionSettings = NSLocalizedString("action.title.settings", comment: "Settings action")
    public static let alertSaveBookmark = NSLocalizedString("alert.title.save.bookmark", comment: "Save Bookmark action")
    public static let alertSaveFavorite = NSLocalizedString("alert.title.save.favorite", comment: "Save Favorite action")
    public static let alertEditBookmark = NSLocalizedString("alert.title.edit.bookmark", comment: "Edit Bookmark action")

    public static let alertAddToWhitelist = NSLocalizedString("alert.title.add.to.whitelist", comment: "Add to Whitelist action")
    public static let alertAddToWhitelistPlaceholder = NSLocalizedString("alert.title.add.to.whitelist.placeholder", comment: "Add to Whitelist placeholder")

    public static let navigationTitleEdit = NSLocalizedString("navigation.title.edit", comment: "Navbar Edit button title")

    public static let secureConnection = NSLocalizedString("monitoring.connection.secure", comment: "Secure conection")
    public static let unsecuredConnection = NSLocalizedString("monitoring.connection.unsecured", comment: "Unsecured conection")

    public static let privacyProtectionTrackersBlocked = NSLocalizedString("privacy.protection.trackers.blocked", comment: "Trackers blocked")
    public static let privacyProtectionTrackersFound = NSLocalizedString("privacy.protection.trackers.found", comment: "Trackers found")
    public static let privacyProtectionMajorTrackersBlocked = NSLocalizedString("privacy.protection.major.trackers.blocked", comment: "Major trackers blocked")
    public static let privacyProtectionMajorTrackersFound = NSLocalizedString("privacy.protection.major.trackers.found", comment: "Major trackers found")

    public static let privacyProtectionTOSUnknown = NSLocalizedString("privacy.protection.tos.unknown", comment: "Unknown Privacy Practices")
    public static let privacyProtectionTOSGood = NSLocalizedString("privacy.protection.tos.good", comment: "Good Privacy Practices")
    public static let privacyProtectionTOSMixed = NSLocalizedString("privacy.protection.tos.mixed", comment: "Mixed Privacy Practices")
    public static let privacyProtectionTOSPoor = NSLocalizedString("privacy.protection.tos.poor", comment: "Poor Privacy Practices")

    public static let privacyProtectionReloadBlockerLists = NSLocalizedString("privacy.protection.reload.blocker.lists", comment: "This can be caused by a loss of internet connection when loading the content blocking rules.")

    public static let ppEncryptionCertError = NSLocalizedString("privacy.protection.encryption.cert.error", comment: "Error extracting certificate")
    public static let ppEncryptionSubjectName = NSLocalizedString("privacy.protection.encryption.subject.name", comment:  "Subject Name")
    public static let ppEncryptionPublicKey = NSLocalizedString("privacy.protection.encryption.public.key", comment:  "Public Key")
    public static let ppEncryptionIssuer = NSLocalizedString("privacy.protection.encryption.issuer", comment:  "Issuer")
    public static let ppEncryptionSummary = NSLocalizedString("privacy.protection.encryption.summary", comment:  "Summary")
    public static let ppEncryptionCommonName = NSLocalizedString("privacy.protection.encryption.common.name", comment:  "Common Name")
    public static let ppEncryptionEmail = NSLocalizedString("privacy.protection.encryption.email", comment:  "Email")
    public static let ppEncryptionAlgorithm = NSLocalizedString("privacy.protection.encryption.algorithm", comment:  "Algorithm")
    public static let ppEncryptionKeySize = NSLocalizedString("privacy.protection.encryption.key.size", comment:  "Key Size")
    public static let ppEncryptionEffectiveSize = NSLocalizedString("privacy.protection.encryption.effective.size", comment:  "Effective Size")
    public static let ppEncryptionUsageDecrypt = NSLocalizedString("privacy.protection.encryption.usage.decrypt", comment:  "Decrypt")
    public static let ppEncryptionUsageEncrypt = NSLocalizedString("privacy.protection.encryption.usage.encrypt", comment:  "Encrypt")
    public static let ppEncryptionUsageDerive = NSLocalizedString("privacy.protection.encryption.usage.derive", comment:  "Derive")
    public static let ppEncryptionUsageWrap = NSLocalizedString("privacy.protection.encryption.usage.wrap", comment:  "Wrap")
    public static let ppEncryptionUsageUnwrap = NSLocalizedString("privacy.protection.encryption.usage.unwrap", comment:  "Unwrap")
    public static let ppEncryptionUsageSign = NSLocalizedString("privacy.protection.encryption.usage.sign", comment:  "Sign")
    public static let ppEncryptionUsageVerify = NSLocalizedString("privacy.protection.encryption.usage.verify", comment:  "Verify")
    public static let ppEncryptionUsage = NSLocalizedString("privacy.protection.encryption.usage", comment:  "Usage")
    public static let ppEncryptionPermanent = NSLocalizedString("privacy.protection.encryption.permanent", comment:  "Permanent")
    public static let ppEncryptionId = NSLocalizedString("privacy.protection.encryption.id", comment:  "ID")
    public static let ppEncryptionKey = NSLocalizedString("privacy.protection.encryption.key", comment:  "Key")
    public static let ppEncryptionYes = NSLocalizedString("privacy.protection.encryption.yes", comment:  "Yes")
    public static let ppEncryptionNo = NSLocalizedString("privacy.protection.encryption.no", comment:  "No")
    public static let ppEncryptionUnknown = NSLocalizedString("privacy.protection.encryption.unknown", comment:  "Unknown")
    public static let ppEncryptionBits = NSLocalizedString("privacy.protection.encryption.bits", comment:  "%d bits")
    
    public static let ppEncryptionStandardMessage = NSLocalizedString("privacy.protection.encryption.standard.message", comment: "An encrypted connection prevents eavesdropping of any personal information you send to a website.")
    public static let ppEncryptionMixedMessage = NSLocalizedString("privacy.protection.encryption.mixed.message", comment: "This site has mixed encryption because some content is being served over unencrypted connections. Encrypted connections prevent eavesdropping of personal information you send to websites.")
    public static let ppEncryptionForcedMessage = NSLocalizedString("privacy.protection.encryption.forced.message", comment: "We've forced this site to use an encrypted connection, preventing eavesdropping of any personal information you send to it.")
    
    public static let ppEncryptionEncryptedHeading = NSLocalizedString("privacy.protection.encryption.encrypted.heading", comment:  "Encrypted")
    public static let ppEncryptionForcedHeading = NSLocalizedString("privacy.protection.encryption.forced.heading", comment:  "Forced")
    public static let ppEncryptionMixedHeading = NSLocalizedString("privacy.protection.encryption.mixed.heading", comment:  "Mixed")
    public static let ppEncryptionUnencryptedHeading = NSLocalizedString("privacy.protection.encryption.unencrypted.heading", comment:  "Unencrypted")

    public static let ppTrackerNetworksMajorMessage = NSLocalizedString("privacy.protection.tracker.networks.major.message", comment: "Major tracker networks are more harmful because they can track and target you across more of the internet.")

    public static let ppNetworkLeaderboard = NSLocalizedString("privacy.protection.network.leaderboard", comment:  "Trackers networks were found on %@ of web sites you’ve visited since %@.")

    public static let ppTrackerNetworkUnknown = NSLocalizedString("privacy.protection.tracker.network.unknown", comment:  "Unknown tracker networks")

    public static let unknownErrorOccurred = NSLocalizedString("unknown.error.occurred", comment:  "Unknown error occurred")
    
    public static let homeRowReminderTitle = NSLocalizedString("home.row.reminder.title", comment:  "Home Row Reminder Title")
    public static let homeRowReminderMessage = NSLocalizedString("home.row.reminder.message", comment:  "Home Row Reminder Message")
    
    public static let feedbackGeneralPlaceholder = NSLocalizedString("feedback.comment.general.placeholder", comment:  "General feedback comment placeholder")
    public static let feedbackBrokenSitePlaceholder = NSLocalizedString("feedback.comment.brokenSite.placeholder", comment:  "Broken site feedback comment placeholder")
    public static let feedbackSumbittedConfirmation = NSLocalizedString("feedback.submitted.confirmation", comment:  "Feedback submitted confirmation")
    
    public static let customUrlSchemeTitle = NSLocalizedString("prompt.custom.url.scheme.title", comment: "Switch apps?")
    public static func forCustomUrlSchemePrompt(url: URL) -> String {
        let message = NSLocalizedString("prompt.custom.url.scheme.prompt", comment: "Would you like to open this URL... ")
        return message.format(arguments: url.absoluteString)
    }
    public static let customUrlSchemeOpen = NSLocalizedString("prompt.custom.url.scheme.open", comment: "Open custom url button")
    public static let customUrlSchemeDontOpen = NSLocalizedString("prompt.custom.url.scheme.dontopen", comment: "Don't open custom url button")

    public static let failedToOpenExternally = NSLocalizedString("open.externally.failed", comment: "Don't open custom url button")
    
    public static let sectionTitleBookmarks = NSLocalizedString("section.title.bookmarks", comment: "Bookmarks section title")
    public static let sectionTitleFavorites = NSLocalizedString("section.title.favorites", comment: "Favorites section title")

    public static let favoriteMenuDelete = NSLocalizedString("favorite.menu.delete", comment: "Favorite menu: delete")
    public static let favoriteMenuEdit = NSLocalizedString("favorite.menu.edit", comment: "Favorite menu: edit")

    public static let emptyBookmarks = NSLocalizedString("empty.bookmarks", comment: "No bookmarks")
    public static let emptyFavorites = NSLocalizedString("empty.favorites", comment: "No favorites")
    
}
