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
    
    public static let appUnlock = NSLocalizedString("app.authentication.unlock", value: "Unlock DuckDuckGo.", comment: "Shown on authentication screen")
    public static let searchDuckDuckGo = NSLocalizedString("search.hint.duckduckgo", value: "Search or enter address", comment: "")
    public static let webSaveBookmarkDone = NSLocalizedString("web.url.save.bookmark.done", value: "Bookmark added", comment: "Confirmation message")
    public static let webBookmarkAlreadySaved = NSLocalizedString("web.url.save.bookmark.exists", value: "Bookmark already saved", comment: "Floating Info message")
    public static let webSaveFavoriteDone = NSLocalizedString("web.url.save.favorite.done", value: "Favorite added", comment: "Confirmation message")
    public static let webSaveBookmarkNone = NSLocalizedString("web.url.save.bookmark.none", value: "No webpage to bookmark", comment: "Floating message indicating failure")
    
    public static let actionPasteAndGo = NSLocalizedString("action.title.pasteAndGo", value: "Paste & Go", comment: "Paste and Go action")
    public static let actionRefresh = NSLocalizedString("action.title.refresh", value: "Refresh", comment: "Refresh action - button shown in alert")
    public static let actionAdd = NSLocalizedString("action.title.add", value: "Add", comment: "Add action - button shown in alert")
    public static let actionSave = NSLocalizedString("action.title.save", value: "Save", comment: "Save action - button shown in alert")
    public static let actionCancel = NSLocalizedString("action.title.cancel", value: "Cancel", comment: "Cancel action - button shown in alert")
    public static let actionBookmark = NSLocalizedString("action.title.bookmark", value: "Bookmark", comment: "Confirmation of Bookmark action in add to bookmark alert")
    public static let actionNewTab = NSLocalizedString("action.title.newTab", value: "New Tab", comment: "Create New Tab action")
    public static let actionNewTabForUrl = NSLocalizedString("action.title.newTabForUrl", value: "Open in New Tab", comment: "Open in New Tab action")
    public static let actionNewBackgroundTabForUrl = NSLocalizedString("action.title.newBackgroundTabForUrl", value: "Open in Background", comment: "Open in New Background Tab action")
    public static let actionForgetAll = NSLocalizedString("action.title.forgetAll", value: "Close Tabs and Clear Data", comment: "")
    public static let actionForgetAllDone = NSLocalizedString("action.title.forgetAllDone", value: "Tabs and data cleared", comment: "Confirmation message")
    public static let actionOpen = NSLocalizedString("action.title.open", value: "Open", comment: "Open action")
    public static let actionCopy = NSLocalizedString("action.title.copy", value: "Copy", comment: "Copy action")
    public static let actionShare = NSLocalizedString("action.title.share", value: "Share...", comment: "Share action")
    public static let actionEnableProtection = NSLocalizedString("action.title.enable.protection", value: "Enable Privacy Protection", comment: "Enable protection action")
    public static let actionDisableProtection = NSLocalizedString("action.title.disable.protection", value: "Disable Privacy Protection", comment: "Disable protection action")
    public static let actionRequestDesktopSite = NSLocalizedString("action.title.request.desktop.site", value: "Request Desktop Site", comment: "Action to reload current page in desktop mode")
    public static let actionRequestMobileSite = NSLocalizedString("action.title.request.mobile.site", value: "Request Mobile Site", comment: "Action to reload current page in mobile mode")
    public static let actionSaveBookmark = NSLocalizedString("action.title.save.bookmark", value: "Add to Bookmarks", comment: "Add to Bookmarks action")
    public static let actionSaveFavorite = NSLocalizedString("action.title.save.favorite", value: "Add to Favorites", comment: "Add to Favorites action")
    public static let actionReportBrokenSite = NSLocalizedString("action.title.reportBrokenSite", value: "Report Broken Site", comment: "Report broken site action")
    public static let actionSettings = NSLocalizedString("action.title.settings", value: "Settings", comment: "Settings action")
    public static let alertSaveBookmark = NSLocalizedString("alert.title.save.bookmark", value: "Save Bookmark", comment: "Save Bookmark action")
    public static let alertSaveFavorite = NSLocalizedString("alert.title.save.favorite", value: "Save Favorite", comment: "Save Favorite action")
    public static let alertEditBookmark = NSLocalizedString("alert.title.edit.bookmark", value: "Edit Bookmark", comment: "Edit Bookmark action")
    public static let alertBookmarkAllTitle = NSLocalizedString("alert.title.bookmarkAll", value: "Bookmark All Tabs?", comment: "Question from confirmation dialog")
    public static let alertBookmarkAllMessage = NSLocalizedString("alert.message.bookmarkAll", value: "Existing bookmarks will not be duplicated.", comment: "")
    
    public static let alertDisableProtection = NSLocalizedString("alert.title.disable.protection", value: "Add to Unprotected Sites", comment: "Disable protection alert")
    public static let alertDisableProtectionPlaceholder = NSLocalizedString("alert.title.disable.protection.placeholder", value: "www.example.com", comment: "Disable potection alert placeholder - leave as it is")
    public static let toastProtectionDisabled = NSLocalizedString("toast.protection.disabled", value: "%@ added to Unprotected Sites", comment: "Confirmation of an action - populated with a domain name")
    public static let toastProtectionEnabled = NSLocalizedString("toast.protection.enabled", value: "%@ removed from Unprotected Sites", comment: "Confirmation of an action - populated with a domain name")
    
    public static let authAlertTitle = NSLocalizedString("auth.alert.title", value: "Authentication Required", comment: "Authentication Alert Title")
    public static let authAlertEncryptedConnectionMessage = NSLocalizedString("auth.alert.message.encrypted", value: "Sign in to %@. Your login information will be sent securely.", comment: "Authentication Alert - populated with a domain name")
    public static let authAlertPlainConnectionMessage = NSLocalizedString("auth.alert.message.plain", value: "Log in to %@. Your password will be sent insecurely because the connection is unencrypted.", comment: "Authentication Alert - populated with a domain name")
    public static let authAlertUsernamePlaceholder = NSLocalizedString("auth.alert.username.placeholder", value: "Username", comment: "Authentication User name field placeholder")
    public static let authAlertPasswordPlaceholder = NSLocalizedString("auth.alert.password.placeholder", value: "Password", comment: "Authentication Password field placeholder")
    public static let authAlertLogInButtonTitle = NSLocalizedString("auth.alert.login.button", value: "Sign In", comment: "Authentication Alert Sign In Button")
    
    public static let navigationTitleEdit = NSLocalizedString("navigation.title.edit", value: "Edit", comment: "Edit button")
    
    public static let privacyProtectionProtectionDisabled = NSLocalizedString("privacy.protection.main.disabled", value: "SITE PROTECTION DISABLED", comment: "")
    public static let privacyProtectionPrivacyGrade = NSLocalizedString("privacy.protection.main.grade", value: "PRIVACY GRADE", comment: "")
    public static let privacyProtectionEnhanced = NSLocalizedString("privacy.protection.main.enhanced", value: "ENHANCED FROM $1 TO $2", comment: "$1 and $2 are grades - letters. Example: Enhanced from D to B")
    public static let privacyProtectionTrackersBlocked = NSLocalizedString("privacy.protection.trackers.blocked", comment: "Do not translate - stringsdict entry")
    public static let privacyProtectionTrackersFound = NSLocalizedString("privacy.protection.trackers.found", comment: "Do not translate - stringsdict entry")
    public static let privacyProtectionMajorTrackersBlocked = NSLocalizedString("privacy.protection.major.trackers.blocked", comment: "Major trackers blocked")
    public static let privacyProtectionMajorTrackersFound = NSLocalizedString("privacy.protection.major.trackers.found", comment: "Major trackers found")
    
    public static let privacyProtectionTOSUnknown = NSLocalizedString("privacy.protection.tos.unknown", value: "Unknown Privacy Practices", comment: "")
    public static let privacyProtectionTOSGood = NSLocalizedString("privacy.protection.tos.good", value: "Good Privacy Practices", comment: "")
    public static let privacyProtectionTOSMixed = NSLocalizedString("privacy.protection.tos.mixed", value: "Mixed Privacy Practices", comment: "")
    public static let privacyProtectionTOSPoor = NSLocalizedString("privacy.protection.tos.poor", value: "Poor Privacy Practices", comment: "")
    
    public static let ppEncryptionCertError = NSLocalizedString("privacy.protection.encryption.cert.error", value: "Error extracting certificate", comment: "")
    public static let ppEncryptionSubjectName = NSLocalizedString("privacy.protection.encryption.subject.name", value: "Subject Name", comment: "Header of a section that provides infomration about certificate issuer")
    public static let ppEncryptionPublicKey = NSLocalizedString("privacy.protection.encryption.public.key", value: "Public Key", comment: "Public Key of a certficate")
    public static let ppEncryptionIssuer = NSLocalizedString("privacy.protection.encryption.issuer", value: "Issuer", comment: "Part of certificate info")
    public static let ppEncryptionSummary = NSLocalizedString("privacy.protection.encryption.summary", value: "Summary", comment: "Part of certificate info")
    public static let ppEncryptionCommonName = NSLocalizedString("privacy.protection.encryption.common.name", value: "Common Name", comment: "Part of certificate info")
    public static let ppEncryptionEmail = NSLocalizedString("privacy.protection.encryption.email", value: "Email", comment: "Part of certificate info")
    public static let ppEncryptionAlgorithm = NSLocalizedString("privacy.protection.encryption.algorithm", value: "Algorithm", comment: "Part of certificate info")
    public static let ppEncryptionKeySize = NSLocalizedString("privacy.protection.encryption.key.size", value: "Key Size", comment: "Part of certificate info")
    public static let ppEncryptionEffectiveSize = NSLocalizedString("privacy.protection.encryption.effective.size", value: "Effective Size", comment: "Part of certificate info")
    public static let ppEncryptionUsageDecrypt = NSLocalizedString("privacy.protection.encryption.usage.decrypt", value: "Decrypt", comment: "Usage of a certificate")
    public static let ppEncryptionUsageEncrypt = NSLocalizedString("privacy.protection.encryption.usage.encrypt", value: "Encrypt", comment: "Usage of a certificate")
    public static let ppEncryptionUsageDerive = NSLocalizedString("privacy.protection.encryption.usage.derive", value: "Derive", comment: "Usage of a certificate")
    public static let ppEncryptionUsageWrap = NSLocalizedString("privacy.protection.encryption.usage.wrap", value: "Wrap", comment: "Usage of a certificate")
    public static let ppEncryptionUsageUnwrap = NSLocalizedString("privacy.protection.encryption.usage.unwrap", value: "Unwrap", comment: "Usage of a certificate")
    public static let ppEncryptionUsageSign = NSLocalizedString("privacy.protection.encryption.usage.sign", value: "Sign", comment: "Usage of a certificate")
    public static let ppEncryptionUsageVerify = NSLocalizedString("privacy.protection.encryption.usage.verify", value: "Verify", comment: "Usage of a certificate")
    public static let ppEncryptionUsage = NSLocalizedString("privacy.protection.encryption.usage", value: "Usage", comment: "Part of certificate info")
    public static let ppEncryptionPermanent = NSLocalizedString("privacy.protection.encryption.permanent", value: "Permanent", comment: "Part of certificate info - Permanent in this context means that certificate is stored on the device (so it’s not temporary one).")
    public static let ppEncryptionId = NSLocalizedString("privacy.protection.encryption.id", value: "Subject Key Identifier", comment: "Part of certificate info")
    public static let ppEncryptionKey = NSLocalizedString("privacy.protection.encryption.key", value: "Public Key", comment: "Part of certificate info")
    public static let ppEncryptionYes = NSLocalizedString("privacy.protection.encryption.yes", value: "Yes", comment: "Confirmation that certificate is permanent")
    public static let ppEncryptionNo = NSLocalizedString("privacy.protection.encryption.no", value: "No", comment: "Info that certificate is not permanent")
    public static let ppEncryptionUnknown = NSLocalizedString("privacy.protection.encryption.unknown", value: "Unknown", comment: "")
    public static let ppEncryptionBits = NSLocalizedString("privacy.protection.encryption.bits", value: "%d bits", comment: "Certificate Key size info - number (integer) of bits")
    
    public static let ppEncryptionStandardMessage = NSLocalizedString("privacy.protection.encryption.standard.message", value: "An encrypted connection prevents eavesdropping of any personal information you send to a website.", comment: "")
    public static let ppEncryptionMixedMessage = NSLocalizedString("privacy.protection.encryption.mixed.message", value: "This site has mixed encryption because some content is being served over unencrypted connections.", comment: "")
    public static let ppEncryptionForcedMessage = NSLocalizedString("privacy.protection.encryption.forced.message", value: "We’ve forced this site to use an encrypted connection, preventing eavesdropping of any personal information you send to it.", comment: "")
    
    public static let ppEncryptionEncryptedHeading = NSLocalizedString("privacy.protection.encryption.encrypted.heading", value: "Encrypted Connection", comment: "")
    public static let ppEncryptionForcedHeading = NSLocalizedString("privacy.protection.encryption.forced.heading", value: "Forced Encryption", comment: "")
    public static let ppEncryptionMixedHeading = NSLocalizedString("privacy.protection.encryption.mixed.heading", value: "Mixed Encryption", comment: "")
    public static let ppEncryptionUnencryptedHeading = NSLocalizedString("privacy.protection.encryption.unencrypted.heading", value: "Unencrypted Connection", comment: "")
    
    public static let ppNetworkLeaderboard = NSLocalizedString("privacy.protection.network.leaderboard", value: "Tracker networks were found on %@%% of websites you’ve visited since %@.", comment: "First parameter (%@) is a number (percent), %% is a percent sign, second %@ is a date")
    public static let ppNetworkLeaderboardGatheringData = NSLocalizedString("privacy.protection.network.leaderboard.gathering", value: "We’re still collecting data to show how\nmany trackers we’ve blocked.", comment: "")
    
    public static let ppEncryptionHeaderInfo = NSLocalizedString("privacy.protection.encryption.header", value: "An encrypted connection prevents eavesdropping of any personal information you send to a website.", comment: "")
    
    public static let ppEncryptionUnencryptedDetailInfo = NSLocalizedString("privacy.protection.encryption.unencrypted", value: "Be careful when entering personal information on this site.", comment: "")
    
    public static let ppTopOffendersInfo = NSLocalizedString("privacy.protection.top.offenders.info", value: "These stats are only stored on your device, and are not sent anywhere. Ever.", comment: "")
    
    public static let ppTrackerNetworksInfo = NSLocalizedString("privacy.protection.tracker.networks.info", value: "Tracker networks aggregate your web history into a data profile about you.  Major tracker networks are more harmful because they can track and target you across more of the Internet.", comment: "")
    
    public static let ppPracticesHeaderInfo = NSLocalizedString("privacy.protection.practices.header.info", value: "Privacy practices indicate how much the personal information that you share with a website is protected.", comment: "")
    public static let ppPracticesReviewedInfo = NSLocalizedString("privacy.protection.practices.reviewed.info", value: "This website will notify you before transferring your information in the event of a merger or acquisition", comment: "")
    public static let ppPracticesUnknownInfo = NSLocalizedString("privacy.protection.practices.unknown.info", value: "The privacy practices of this website have not been reviewed.", comment: "")
    public static let ppPracticesFooterInfo = NSLocalizedString("privacy.protection.practices.footer.info", value: "Privacy Practices from ToS;DR.", comment: "ToS;DR is an organization")
    
    static let reportBrokenSiteHeader = NSLocalizedString("report.brokensite.header", value: "Submitting an anonymous broken site report helps us debug these issues and improve the app.", comment: "")
    
    static let brokenSiteSectionTitle = NSLocalizedString("brokensite.sectionTitle", value: "DESCRIBE WHAT HAPPENED", comment: "Broken Site Section Title")
    
    static let brokenSiteCategoryImages = NSLocalizedString("brokensite.category.images", value: "Images didn’t load", comment: "Broken Site Category")
    static let brokenSiteCategoryPaywall = NSLocalizedString("brokensite.category.paywall", value: "The site asked me to disable", comment: "Broken Site Category")
    static let brokenSiteCategoryComments = NSLocalizedString("brokensite.category.comments", value: "Comments didn’t load", comment: "Broken Site Category")
    static let brokenSiteCategoryVideos = NSLocalizedString("brokensite.category.videos", value: "Video didn’t play", comment: "Broken Site Category")
    static let brokenSiteCategoryLinks = NSLocalizedString("brokensite.category.links", value: "Links or buttons don’t work", comment: "Broken Site Category")
    static let brokenSiteCategoryContent = NSLocalizedString("brokensite.category.content", value: "Content is missing", comment: "Broken Site Category")
    static let brokenSiteCategoryLogin = NSLocalizedString("brokensite.category.login", value: "I can’t sign in", comment: "Broken Site Category")
    static let brokenSiteCategoryUnsupported = NSLocalizedString("brokensite.category.unsupported", value: "The browser is incompatible", comment: "Broken Site Category")
    static let brokenSiteCategoryOther = NSLocalizedString("brokensite.category.other", value: "Something else", comment: "Broken Site Category")
    
    public static let unknownErrorOccurred = NSLocalizedString("unknown.error.occurred", value: "An unknown error occurred.", comment: "")
    
    public static let homeRowReminderTitle = NSLocalizedString("home.row.reminder.title", value: "Take DuckDuckGo home", comment: "Home is this context is the bottom home row (dock)")
    public static let homeRowReminderMessage = NSLocalizedString("home.row.reminder.message", value: "Add DuckDuckGo to your dock for easy access!", comment: "")
    
    public static let homeRowOnboardingHeader = NSLocalizedString("home.row.onboarding.header", value: "Add DuckDuckGo to your home screen!", comment: "")
    
    public static let feedbackSumbittedConfirmation = NSLocalizedString("feedback.submitted.confirmation", value: "Thank You! Feedback submitted.", comment: "")
    
    public static let customUrlSchemeTitle = NSLocalizedString("prompt.custom.url.scheme.title", value: "Open in Another App?", comment: "Alert title")
    public static let customUrlSchemeMessage = NSLocalizedString("prompt.custom.url.scheme.prompt", value: "Would you like to leave DuckDuckGo to view this content?", comment: "")
    public static let customUrlSchemeOpen = NSLocalizedString("prompt.custom.url.scheme.open", value: "Open", comment: "Confirm action")
    public static let customUrlSchemeDontOpen = NSLocalizedString("prompt.custom.url.scheme.dontopen", value: "Cancel", comment: "Deny action")
    
    public static let failedToOpenExternally = NSLocalizedString("open.externally.failed", value: "The app required to open that link can’t be found", comment: "’Link’ is link on a website")
    
    public static let sectionTitleBookmarks = NSLocalizedString("section.title.bookmarks", value: "Bookmarks", comment: "")
    public static let sectionTitleFavorites = NSLocalizedString("section.title.favorites", value: "Favorites", comment: "")
    
    public static let favoriteMenuDelete = NSLocalizedString("favorite.menu.delete", value: "Delete", comment: "")
    public static let favoriteMenuEdit = NSLocalizedString("favorite.menu.edit", value: "Edit", comment: "")
    
    public static let emptyBookmarks = NSLocalizedString("empty.bookmarks", value: "No bookmarks added yet", comment: "Empty list state placholder")
    public static let emptyFavorites = NSLocalizedString("empty.favorites", value: "No favorites added yet", comment: "Empty list state placholder")
    public static let noMatchesFound = NSLocalizedString("empty.search", value: "No matches found", comment: "Empty search placeholder on bookmarks search")
    
    public static let bookmarkTitlePlaceholder = NSLocalizedString("bookmark.title.placeholder", value: "Website title", comment: "Placeholder in the add bookmark form")
    public static let bookmarkAddressPlaceholder = NSLocalizedString("bookmark.address.placeholder", value: "www.example.com", comment: "Placeholder in the add bookmark form")
    
    public static let findInPage = NSLocalizedString("findinpage.title", value: "Find in Page", comment: "")
    public static let findInPageCount = NSLocalizedString("findinpage.count", value: "%1$d of %2$d", comment: "Used to indicate number of entries found and position of the currently viewed one: e.g. 1 of 10")
    
    public static let keyCommandShowAllTabs = NSLocalizedString("keyCommandShowAllTabs", value: "Show All Tabs", comment: "")
    public static let keyCommandNewTab = NSLocalizedString("keyCommandNewTab", value: "New Tab", comment: "")
    public static let keyCommandCloseTab = NSLocalizedString("keyCommandCloseTab", value: "Close Tab", comment: "")
    public static let keyCommandNextTab = NSLocalizedString("keyCommandNextTab", value: "Next Tab", comment: "")
    public static let keyCommandPreviousTab = NSLocalizedString("keyCommandPreviousTab", value: "Previous Tab", comment: "")
    public static let keyCommandBrowserForward = NSLocalizedString("keyCommandBrowserForward", value: "Browse Forward", comment: "")
    public static let keyCommandBrowserBack = NSLocalizedString("keyCommandBrowserBack", value: "Browse Back", comment: "")
    public static let keyCommandFind = NSLocalizedString("keyCommandFind", value: "Find in Page", comment: "")
    public static let keyCommandLocation = NSLocalizedString("keyCommandLocation", value: "Search or Enter Address", comment: "")
    public static let keyCommandFire = NSLocalizedString("keyCommandFire", value: "Clear All Tabs and Data", comment: "")
    public static let keyCommandClose = NSLocalizedString("keyCommandClose", value: "Close", comment: "")
    public static let keyCommandSelect = NSLocalizedString("keyCommandSelect", value: "Select", comment: "")
    public static let keyCommandFindNext = NSLocalizedString("keyCommandFindNext", value: "Find Next", comment: "")
    public static let keyCommandFindPrevious = NSLocalizedString("keyCommandFindPrevious", value: "Find Previous", comment: "")
    public static let keyCommandReload = NSLocalizedString("keyCommandReload", value: "Reload", comment: "")
    public static let keyCommandPrint = NSLocalizedString("keyCommandPrint", value: "Print", comment: "")
    public static let keyCommandAddBookmark = NSLocalizedString("keyCommandAddBookmark", value: "Add Bookmark", comment: "")
    public static let keyCommandAddFavorite = NSLocalizedString("keyCommandAddFavorite", value: "Add Favorite", comment: "")
    public static let keyCommandOpenInNewTab = NSLocalizedString("keyCommandOpenInNewTab", value: "Open Link in New Tab", comment: "")
    public static let keyCommandOpenInNewBackgroundTab = NSLocalizedString("keyCommandOpenInNewBackgroundTab", value: "Open Link in Background", comment: "")
    
    public static let bookmarkAllTabsSaved = NSLocalizedString("bookmarkAll.tabs.saved", value: "All tabs bookmarked", comment: "Confirmation message after selecting Bookmark All button")
    public static let bookmarkAllTabsFailedToSave = NSLocalizedString("bookmarkAll.tabs.failed", value: "Added new bookmarks for all tabs", comment: "Info message after selecting Bookmark All button")
    
    public static let themeNameDefault = NSLocalizedString("theme.name.default", value: "System Default", comment: "Entry for Default System theme")
    public static let themeNameLight = NSLocalizedString("theme.name.light", value: "Light", comment: "Light Theme entry")
    public static let themeNameDark = NSLocalizedString("theme.name.dark", value: "Dark", comment: "Dark Theme entry")
    
    public static let themeAccessoryDefault = NSLocalizedString("theme.acc.default", value: "System", comment: "Short entry for Default System theme")
    public static let themeAccessoryLight = NSLocalizedString("theme.acc.light", value: "Light", comment: "Light Theme entry")
    public static let themeAccessoryDark = NSLocalizedString("theme.acc.dark", value: "Dark", comment: "Dark Theme entry")
    
    public static let autoClearAccessoryOn = NSLocalizedString("autoclear.on", value: "On", comment: "")
    public static let autoClearAccessoryOff = NSLocalizedString("autoclear.off", value: "Off", comment: "")
    
    public static func privacyGrade(_ grade: String) -> String {
        let message = NSLocalizedString("privacy.protection.site.grade", value: "Privacy grade %@", comment: "Replacement string is a single letter: A/B/C/D")
        return message.format(arguments: grade)
    }
    
    public static let privacyGradeHint = NSLocalizedString("privacy.protection.site.hint", value: "Press to open Privacy Protection screen", comment: "")
    
    public static func numberOfTabs(_ number: Int) -> String {
        let message = NSLocalizedString("number.of.tabs", comment: "Do not translate - stringsdict entry")
        return message.format(arguments: number)
    }
    
    public static func openTab(withTitle title: String, atAddress address: String) -> String {
        let message = NSLocalizedString("tab.open.with.title.and.address", value: "Open \"%@\" at %@", comment: "Accesibility label: first string is website title, second is address")
        return message.format(arguments: title, address)
    }

    public static let openHomeTab = NSLocalizedString("tab.open.home", value: "Open home tab", comment: "Accessibility label on tab cell")
    public static let closeHomeTab = NSLocalizedString("tab.close.home", value: "Close home tab", comment: "Accessibility label on remove button")

    public static func closeTab(withTitle title: String, atAddress address: String) -> String {
        let message = NSLocalizedString("tab.close.with.title.and.address", value: "Close \"%@\" at %@", comment: "Accesibility label: first string is website title, second is address")
        return message.format(arguments: title, address)
    }
    
    public static let favorite = NSLocalizedString("favorite", value: "Favorite", comment: "")
    
    public static let launchscreenWelcomeMessage = NSLocalizedString("launchscreenWelcomeMessage", value: "Welcome to\nDuckDuckGo!", comment: "Please preserve newline character")
    public static let onboardingWelcomeHeader = NSLocalizedString("onboardingWelcomeHeader", value: "Welcome to DuckDuckGo!", comment: "")
    public static let onboardingContinue = NSLocalizedString("onboardingContinue", value: "Continue", comment: "")
    public static let onboardingSkip = NSLocalizedString("onboardingSkip", value: "Skip", comment: "")
    public static let onboardingStartBrowsing = NSLocalizedString("onboardingStartBrowsing", value: "Start Browsing", comment: "This is on a button presented on the last of the onboarding screens.")
    public static let onboardingSetAsDefaultBrowser = NSLocalizedString("onboardingSetAsDefaultBrowser", value: "Set as Default Browser", comment: "")
    public static let onboardingDefaultBrowserTitle = NSLocalizedString("onboardingDefaultBrowserTitle", value: "Make DuckDuckGo your default browser.", comment: "")
    public static let onboardingDefaultBrowserMaybeLater = NSLocalizedString("onboardingDefaultBrowserMaybeLater", value: "Maybe Later", comment: "")
    
    public static let preserveLoginsSwitchTitle = NSLocalizedString("preserveLogins.switch.title", value: "Ask to Fireproof Sites", comment: "Ask to Fireproof Sites")
    
    public static let preserveLoginsListTitle = NSLocalizedString("preserveLogins.domain.list.title", value: "Websites", comment: "Section header above Fireproffed websites list")
    public static let preserveLoginsListFooter = NSLocalizedString("preserveLogins.domain.list.footer", value: "Websites rely on cookies to keep you signed in. When you Fireproof a site, cookies won’t be erased and you’ll stay signed in, even after using the Fire Button. We still block third-party trackers found on Fireproof websites.", comment: "")
    public static let preserveLoginsRemoveAll = NSLocalizedString("preserveLogins.remove.all", value: "Remove All", comment: "Alert title")
    public static let preserveLoginsRemoveAllOk = NSLocalizedString("preserveLogins.remove.all.ok", value: "OK", comment: "Confirmation button in alert")
    
    public static let preserveLoginsFireproofAsk = NSLocalizedString("preserveLogins.fireproof.message", value: "Would you like to Fireproof %@?", comment: "Paramter is a string - domain name")
    public static let preserveLoginsFireproofConfirm = NSLocalizedString("preserveLogins.menu.confirm", value: "Fireproof Website", comment: "Confirm fireproofing action")
    public static let preserveLoginsFireproofDefer = NSLocalizedString("preserveLogins.menu.defer", value: "Not Now", comment: "Deny fireproofing action")
    
    public static let preserveLoginsToast = NSLocalizedString("preserveLogins.toast", value: "%@ is now Fireproof! Visit Settings to manage.", comment: "Parameter is a string - domain name")
    
    public static let homeTabSearchAndFavorites = NSLocalizedString("homeTab.searchAndFavorites", value: "Search or enter address", comment: "This describes empty tab")
    public static let homeTabTitle = NSLocalizedString("homeTab.title", value: "Home", comment: "Home tab title")
    
    public static let settingTutorialInfo = NSLocalizedString("settings.tutorial.info", value: "Other search engines track your searches even when you’re in Private Browsing Mode. We don’t track you. Period.", comment: "")
    public static let settingTutorialOpenStep = NSLocalizedString("settings.tutorial.open", value: "Open *Settings* app.", comment: "Asterix is an indicator of a bold text. Settings is a native iOS app.")
    public static let settingTutorialNavigateStep = NSLocalizedString("settings.tutorial.navigate", value: "Navigate to *Safari*, then *Search Engine*.", comment: "")
    public static let settingTutorialSelectStep = NSLocalizedString("settings.tutorial.select", value: "Select *DuckDuckGo*.", comment: "")
    
    public static let settingsAboutText = NSLocalizedString("settings.about.text", value: "At DuckDuckGo, we’re setting the new standard of trust online.\n\nDuckDuckGo Privacy Browser provides all the privacy essentials you need to protect yourself as you search and browse the web, including tracker blocking, smarter encryption, and DuckDuckGo private search.\n\nAfter all, the Internet shouldn’t feel so creepy, and getting the privacy you deserve online should be as simple as closing the blinds.", comment: "")
    
    public static let daxDialogHomeInitial = NSLocalizedString("dax.onboarding.home.initial", value: "Next, try visiting one of your favorite sites!\n\nI’ll block trackers so they can’t spy on you. I’ll also upgrade the security of your connection if possible. 🔒", comment: "")
    public static let daxDialogHomeSubsequent = NSLocalizedString("dax.onboarding.home.subsequent", value: "You’ve got this!\n\nRemember: Every time you browse with me, a creepy ad loses its wings. 👍", comment: "ad = advertisment")
    public static let daxDialogHomeAddFavorite = NSLocalizedString("dax.onboarding.home.add.favorite", value: "Visit your favorite sites in a flash!\n\nGo to a site you love. Then tap the \"⋯\" icon and select *Add to Favorites*.", comment: "Encourage user to add favorite site using the browsing menu.")
    public static let daxDialogHomeAddFavoriteAccessible = NSLocalizedString("dax.onboarding.home.add.favorite.accessible", value: "Visit your favorite sites in a flash! Visit one of your favorite sites. Then tap the open menu button and select Add to Favorites.", comment: "Accessible version of dax.onboarding.home.add.favorite")

    public static let daxDialogBrowsingAfterSearch = NSLocalizedString("dax.onboarding.browsing.after.search", value: "Your DuckDuckGo searches are anonymous and I never store your search history.  Ever. 🙌", comment: "")
    public static let daxDialogBrowsingAfterSearchCTA = NSLocalizedString("dax.onboarding.browsing.after.search.cta", value: "Phew!", comment: "")
    
    public static let daxDialogBrowsingWithoutTrackers = NSLocalizedString("dax.onboarding.browsing.without.trackers", value: "As you tap and scroll, I’ll block pesky trackers.\n\nGo ahead - keep browsing!", comment: "")
    public static let daxDialogBrowsingWithoutTrackersCTA = NSLocalizedString("dax.onboarding.browsing.without.trackers.cta", value: "Got It", comment: "")
    
    public static let daxDialogBrowsingSiteIsMajorTracker = NSLocalizedString("dax.onboarding.browsing.site.is.major.tracker", value: "Heads up! I can’t stop %1$@ from seeing your activity on %2$@.\n\nBut browse with me, and I can reduce what %1$@ knows about you overall by blocking their trackers on lots of other sites.",  comment: "First paramter is a string - network name, 2nd parameter is a string - domain name")
    public static let daxDialogBrowsingSiteIsMajorTrackerCTA = NSLocalizedString("dax.onboarding.browsing.site.is.major.tracker.cta", value:  "Got It", comment: "")
    
    public static let daxDialogBrowsingSiteOwnedByMajorTracker = NSLocalizedString("dax.onboarding.browsing.site.owned.by.major.tracker", value: "Heads up! Since %2$@ owns %1$@, I can’t stop them from seeing your activity here.\n\nBut browse with me, and I can reduce what %2$@ knows about you overall by blocking their trackers on lots of other sites.", comment: "Parameters are domain names (strings)")
    public static let daxDialogBrowsingSiteOwnedByMajorTrackerCTA = NSLocalizedString("dax.onboarding.browsing.site.owned.by.major.tracker.cta", value: "Got It", comment: "Got It")
    
    public static let daxDialogBrowsingWithOneTracker = NSLocalizedString("dax.onboarding.browsing.one.tracker", value: "*%1$@* was trying to track you here.\n\nI blocked them!\n\n☝️ You can check the address bar to see who is trying to track you when you visit a new site.", comment: "Parameter is domain name (string)")
    public static let daxDialogBrowsingWithOneTrackerCTA = NSLocalizedString("dax.onboarding.browsing.one.tracker.cta", value: "High Five!", comment: "")
    
    public static let daxDialogBrowsingWithMultipleTrackers = NSLocalizedString("dax.onboarding.browsing.multiple.trackers", comment: "First parameter is a count of additional trackers, second and third are names of the tracker networks (strings)")
    public static let daxDialogBrowsingWithMultipleTrackersCTA = NSLocalizedString("dax.onboarding.browsing.multiple.trackers.cta" , value: "High Five!", comment: "")
    
    public static let daxDialogOnboardingMessage = NSLocalizedString("dax.onboarding.message", value: "The Internet can be kinda creepy.\n\nNot to worry! Searching and browsing privately is easier than you think.", comment: "")
    
    public static let daxDialogHideTitle = NSLocalizedString("dax.hide.title", value: "Hide remaining tips?", comment: "Title in Hide Dax dialog")
    public static let daxDialogHideMessage = NSLocalizedString("dax.hide.message", value: "There are only a few, and we tried to make them informative.", comment: "Subtitle in Hide Dax dialog")
    public static let daxDialogHideButton = NSLocalizedString("dax.hide.button", value: "Hide Tips Forever", comment: "")
    public static let daxDialogHideCancel = NSLocalizedString("dax.hide.cancel", value: "Cancel", comment: "")
    
    public static let tabSwitcherAccessibilityLabel = NSLocalizedString("tab.switcher.accessibility.label", value: "Tab Switcher", comment: "Tab Switcher Accessibility Label")
    
    public static let defaultBrowserHomeMessageHeader = NSLocalizedString("home.message.header", value: "Make DuckDuckGo your default browser.", comment: "")
    public static let defaultBrowserHomeMessageSubheader = NSLocalizedString("home.message.subheader", value: "Open links with peace of mind, every time.", comment: "")
    public static let defaultBrowserHomeMessageTopText = NSLocalizedString("home.message.topText", value: "NEW IN IOS 14", comment: "")
    public static let defaultBrowserHomeMessageButtonText = NSLocalizedString("home.message.buttonText", value: "Set as Default Browser", comment: "")
    
    public static let onboardingWidgetsHeader = NSLocalizedString("onboarding.widgets.header", value: "Using DuckDuckGo just got easier.", comment: "")
    public static let onboardingWidgetsContinueButtonText = NSLocalizedString("onboarding.widgets.continueButton", value: "Add Widget", comment: "")
    public static let onboardingWidgetsSkipButtonText = NSLocalizedString("onboarding.widgets.skipButton", value: "Maybe Later", comment: "")

    public static let doNotSellInfoText = NSLocalizedString("donotsell.info.headertext", value: "Your data shouldn’t be for sale. At DuckDuckGo, we agree. Activate the \"Global Privacy Control\" (GPC) setting and we’ll signal to websites your preference to:\n\n• Not sell your personal data.\n• Limit sharing of your personal data to other companies.",
                        comment: "")
    public static let doNotSellDisclaimerBold = NSLocalizedString("donotsell.disclaimer.footertext", value: "Since Global Privacy Control (GPC) is a new standard, most websites won’t recognize it yet, but we’re working hard to ensure it becomes accepted worldwide.", comment: "")
    public static let doNotSellDisclaimerSuffix = NSLocalizedString("donotsell.disclaimer.suffix", value: " However, websites are only required to act on the signal to the extent applicable laws compel them to do so. ", comment: "")
    public static let doNotSellLearnMore = NSLocalizedString("donotsell.disclaimer.learnmore", value: "Learn More", comment: "")
    public static let doNotSellEnabled = NSLocalizedString("donotsell.enabled", value: "Enabled", comment: "GPC Setting state")
    public static let doNotSellDisabled = NSLocalizedString("donotsell.disabled", value: "Disabled", comment: "GPC Setting state")
    
    public static let fireButtonAnimationFireRisingName = NSLocalizedString("fireButtonAnimation.fireRising.name", value: "Inferno", comment: "")
    public static let fireButtonAnimationWaterSwirlName = NSLocalizedString("fireButtonAnimation.waterSwirl.name", value: "Whirlpool", comment: "")
    public static let fireButtonAnimationAirstreamName = NSLocalizedString("fireButtonAnimation.airstream.name", value: "Airstream", comment: "")
    public static let fireButtonAnimationNoneName = NSLocalizedString("fireButtonAnimation.none.name", value: "None", comment: "")
}
