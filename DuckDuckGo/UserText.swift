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
    public static let webFavoriteRemoved = NSLocalizedString("web.url.remove.favorite.done", value: "Favorite removed", comment: "Confirmation message")
    public static let webSaveBookmarkNone = NSLocalizedString("web.url.save.bookmark.none", value: "No webpage to bookmark", comment: "Floating message indicating failure")
    
    public static let actionPasteAndGo = NSLocalizedString("action.title.pasteAndGo", value: "Paste & Go", comment: "Paste and Go action")
    public static let actionRefresh = NSLocalizedString("action.title.refresh", value: "Refresh", comment: "Refresh action - button shown in alert")
    public static let actionAdd = NSLocalizedString("action.title.add", value: "Add", comment: "Add action - button shown in alert")
    public static let actionSave = NSLocalizedString("action.title.save", value: "Save", comment: "Save action - button shown in alert")
    public static let actionCancel = NSLocalizedString("action.title.cancel", value: "Cancel", comment: "Cancel action - button shown in alert")
    public static let actionBookmark = NSLocalizedString("action.title.bookmark", value: "Bookmark", comment: "Confirmation of Bookmark action in add to bookmark alert")
    public static let actionNewTab = NSLocalizedString("action.title.newTabAction", value: "New", comment: "Create New Tab action")
    public static let actionNewTabForUrl = NSLocalizedString("action.title.newTabForUrl", value: "Open in New Tab", comment: "Open in New Tab action")
    public static let actionNewBackgroundTabForUrl = NSLocalizedString("action.title.newBackgroundTabForUrl", value: "Open in Background", comment: "Open in New Background Tab action")
    public static let actionForgetAll = NSLocalizedString("action.title.forgetAll", value: "Close Tabs and Clear Data", comment: "")
    public static let actionForgetAllDone = NSLocalizedString("action.title.forgetAllDone", value: "Tabs and data cleared", comment: "Confirmation message")
    public static let actionOpen = NSLocalizedString("action.title.open", value: "Open", comment: "Open action")
    public static let actionCopy = NSLocalizedString("action.title.copy", value: "Copy", comment: "Copy action")
    public static let actionCopyMessage = NSLocalizedString("action.title.copy.message", value: "URL copied", comment: "Floating message indicating URL has been copied")
    public static let actionShare = NSLocalizedString("action.title.share", value: "Share", comment: "Share action")
    public static let actionPrint = NSLocalizedString("action.title.print", value: "Print", comment: "Print action")
    public static let actionOpenBookmarks = NSLocalizedString("action.title.bookmarks", value: "Bookmarks", comment: "Button: Open bookmarks list")
    public static let actionEnableProtection = NSLocalizedString("action.title.enable.protection", value: "Enable Privacy Protection", comment: "Enable protection action")
    public static let actionDisableProtection = NSLocalizedString("action.title.disable.protection", value: "Disable Privacy Protection", comment: "Disable protection action")
    public static let actionRequestDesktopSite = NSLocalizedString("action.title.request.desktop.site", value: "Desktop Site", comment: "Action to reload current page in desktop mode")
    public static let actionRequestMobileSite = NSLocalizedString("action.title.request.mobile.site", value: "Mobile Site", comment: "Action to reload current page in mobile mode")
    public static let actionSaveBookmark = NSLocalizedString("action.title.save.bookmark", value: "Add Bookmark", comment: "Add to Bookmarks action")
    public static let actionSaveFavorite = NSLocalizedString("action.title.save.favorite", value: "Add Favorite", comment: "Add to Favorites action")
    public static let actionReportBrokenSite = NSLocalizedString("action.title.reportBrokenSite", value: "Report Broken Site", comment: "Report broken site action")
    public static let actionSettings = NSLocalizedString("action.title.settings", value: "Settings", comment: "Settings action")
    public static let actionGenericEdit = NSLocalizedString("action.generic.edit", value: "Edit", comment: "Buton label for Edit action")
    public static let actionGenericUndo = NSLocalizedString("action.generic.undo", value: "Undo", comment: "Button label for Undo action")
    public static let actionEditBookmark = NSLocalizedString("action.title.edit.bookmark", value: "Edit Bookmark", comment: "Edit Bookmark action")
    public static let actionRemoveFavorite = NSLocalizedString("action.title.remove.favorite", value: "Remove Favorite", comment: "Remove Favorite action")
    public static let alertSaveBookmark = NSLocalizedString("alert.title.save.bookmark", value: "Save Bookmark", comment: "Save Bookmark action")
    public static let alertSaveFavorite = NSLocalizedString("alert.title.save.favorite", value: "Save Favorite", comment: "Save Favorite action")
    public static let alertBookmarkAllTitle = NSLocalizedString("alert.title.bookmarkAll", value: "Bookmark All Tabs?", comment: "Question from confirmation dialog")
    public static let alertBookmarkAllMessage = NSLocalizedString("alert.message.bookmarkAll", value: "Existing bookmarks will not be duplicated.", comment: "")
    
    public static let alertDisableProtection = NSLocalizedString("alert.title.disable.protection", value: "Add to Unprotected Sites", comment: "Disable protection alert")
    public static let alertDisableProtectionPlaceholder = NSLocalizedString("alert.title.disable.protection.placeholder", value: "www.example.com", comment: "Disable potection alert placeholder - leave as it is")
    public static let messageProtectionDisabled = NSLocalizedString("toast.protection.disabled", value: "Privacy Protection disabled for %@", comment: "Confirmation of an action - populated with a domain name")
    public static let messageProtectionEnabled = NSLocalizedString("toast.protection.enabled", value: "Privacy Protection enabled for %@", comment: "Confirmation of an action - populated with a domain name")
    
    public static let authAlertTitle = NSLocalizedString("auth.alert.title", value: "Authentication Required", comment: "Authentication Alert Title")
    public static let authAlertEncryptedConnectionMessage = NSLocalizedString("auth.alert.message.encrypted", value: "Sign in to %@. Your login information will be sent securely.", comment: "Authentication Alert - populated with a domain name")
    public static let authAlertPlainConnectionMessage = NSLocalizedString("auth.alert.message.plain", value: "Log in to %@. Your password will be sent insecurely because the connection is unencrypted.", comment: "Authentication Alert - populated with a domain name")
    public static let authAlertUsernamePlaceholder = NSLocalizedString("auth.alert.username.placeholder", value: "Username", comment: "Authentication User name field placeholder")
    public static let authAlertPasswordPlaceholder = NSLocalizedString("auth.alert.password.placeholder", value: "Password", comment: "Authentication Password field placeholder")
    public static let authAlertLogInButtonTitle = NSLocalizedString("auth.alert.login.button", value: "Sign In", comment: "Authentication Alert Sign In Button")
    
    public static let navigationTitleEdit = NSLocalizedString("navigation.title.edit", value: "Edit", comment: "Edit button")
    public static let navigationTitleDone = NSLocalizedString("navigation.title.done", value: "Done", comment: "Finish editing bookmarks button")
    
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
    public static let bookmarkFolderSelectTitle = NSLocalizedString("bookmark.folderSelect.title", value: "Location", comment: "Header for folder selection for bookmarks")
    public static let bookmarkTopLevelFolderTitle = NSLocalizedString("bookmark.topLevelFolder.title", value: "Bookmarks", comment: "Top level bookmarks folder title")
    public static let deleteBookmarkFolderAlertTitle = NSLocalizedString("bookmark.deleteFolderAlert.title", value: "Delete %@?", comment: "Delete bookmark folder alert title")
    public static let deleteBookmarkFolderAlertMessageSingular = NSLocalizedString("bookmark.deleteFolderAlert.message.singular", value: "Are you sure you want to delete this folder and %i item?", comment: "Delete bookmark folder alert message")
    public static let deleteBookmarkFolderAlertMessagePlural = NSLocalizedString("bookmark.deleteFolderAlert.message.plural", value: "Are you sure you want to delete this folder and %i items?", comment: "Delete bookmark folder alert message plural")
    public static let deleteBookmarkFolderAlertDeleteButton = NSLocalizedString("bookmark.deleteFolderAlert.deleteButton", value: "Delete", comment: "Delete bookmark folder alert delete button")
    public static let addbookmarkFolderButton = NSLocalizedString("bookmark.addFolderButton", value: "Add Folder", comment: "Add bookmark folder button text")
    
    public static let editFavoriteScreenTitle = NSLocalizedString("bookmark.editFavorite.title", value: "Edit Favorite", comment: "Edit favorite screen title")
    public static let editBookmarkScreenTitle = NSLocalizedString("bookmark.editBookmark.title", value: "Edit Bookmark", comment: "Edit bookmark screen title")
    public static let editFolderScreenTitle = NSLocalizedString("bookmark.editFolder.title", value: "Edit Folder", comment: "Edit folder screen title")
    
    public static let addFavoriteScreenTitle = NSLocalizedString("bookmark.addFavorite.title", value: "Add Favorite", comment: "Add favorite screen title")
    public static let addBookmarkScreenTitle = NSLocalizedString("bookmark.addBookmark.title", value: "Add Bookmark", comment: "Add bookmark screen title")
    public static let addFolderScreenTitle = NSLocalizedString("bookmark.addFolder.title", value: "Add Folder", comment: "Add folder screen title")
    
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
    public static let menuButtonHint = NSLocalizedString("menu.button.hint", value: "Browsing Menu", comment: "")
    public static let bookmarksButtonHint = NSLocalizedString("bookmarks.button.hint", value: "Bookmarks", comment: "")
    
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

    public static let preserveLoginsListTitle = NSLocalizedString("preserveLogins.domain.list.title", value: "Fireproof Sites", comment: "Section header above Fireproofed websites list")
    public static let preserveLoginsListFooter = NSLocalizedString("preserveLogins.domain.list.footer", value: "Websites rely on cookies to keep you signed in. When you Fireproof a site, cookies won’t be erased and you’ll stay signed in, even after using the Fire Button. We still block third-party trackers found on Fireproof websites.", comment: "")
    public static let preserveLoginsRemoveAll = NSLocalizedString("preserveLogins.remove.all", value: "Remove All", comment: "Alert title")
    public static let preserveLoginsRemoveAllOk = NSLocalizedString("preserveLogins.remove.all.ok", value: "OK", comment: "Confirmation button in alert")

    public static let preserveLoginsFireproofAskTitle = NSLocalizedString("preserveLogins.fireproof.title", value: "Fireproof %@ to stay signed in?", comment: "Parameter is a string - domain name. Alert title prompting user to fireproof a site so they can stay signed in")
    public static let preserveLoginsFireproofAskMessage = NSLocalizedString("preserveLogins.fireproof.message", value: "Fireproofing this site will keep you signed in after using the Fire Button.", comment: "Alert message explaining to users that the benefit of fireproofing a site is that they will be kept signed in")
    public static let enablePreservingLogins = NSLocalizedString("preserveLogins.menu.enable", value: "Fireproof This Site", comment: "Enable fireproofing for site")
    public static let disablePreservingLogins = NSLocalizedString("preserveLogins.menu.disable", value: "Remove Fireproofing", comment: "Disable fireproofing for site")
    public static let preserveLoginsFireproofConfirmAction = NSLocalizedString("preserveLogins.menu.confirm", value: "Fireproof", comment: "Confirm fireproofing action")
    public static let preserveLoginsFireproofDefer = NSLocalizedString("preserveLogins.menu.defer", value: "Not Now", comment: "Deny fireproofing action")
    public static let preserveLoginsFireproofConfirmMessage = NSLocalizedString("preserveLogins.menu.confirm.message", value: "%@ is now Fireproof", comment: "Parameter is a website URL. Messege confirms that given website has been fireproofed.")
    public static let preserveLoginsRemovalConfirmMessage = NSLocalizedString("preserveLogins.menu.removal.message", value: "Fireproofing removed", comment: " Messege confirms that website is no longer fireproofed.")
    
    public static let homeTabSearchAndFavorites = NSLocalizedString("homeTab.searchAndFavorites", value: "Search or enter address", comment: "This describes empty tab")
    public static let homeTabTitle = NSLocalizedString("homeTab.title", value: "Home", comment: "Home tab title")
    
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
    
    public static let daxDialogFireButtonEducation = NSLocalizedString("dax.onboarding.fire.button", value: "Personal data can build up in your browser. Yuck. Use the Fire Button to burn it all away. Give it a try now! 👇", comment: "Encourage user to try clearing data with the fire button")
    public static let daxDialogFireButtonEducationConfirmAction = NSLocalizedString("dax.onboarding.fire.button.confirmAction", value: "Close Tabs and Clear Data", comment: "Encourage user to try clearing data with the fire button")
    public static let daxDialogFireButtonEducationCancelAction = NSLocalizedString("dax.onboarding.fire.button.cancelAction", value: "Cancel", comment: "Cancel action")
    
    
    public static let daxDialogOnboardingMessage = NSLocalizedString("dax.onboarding.message", value: "The Internet can be kinda creepy.\n\nNot to worry! Searching and browsing privately is easier than you think.", comment: "")
    
    public static let daxDialogHideTitle = NSLocalizedString("dax.hide.title", value: "Hide remaining tips?", comment: "Title in Hide Dax dialog")
    public static let daxDialogHideMessage = NSLocalizedString("dax.hide.message", value: "There are only a few, and we tried to make them informative.", comment: "Subtitle in Hide Dax dialog")
    public static let daxDialogHideButton = NSLocalizedString("dax.hide.button", value: "Hide Tips Forever", comment: "")
    public static let daxDialogHideCancel = NSLocalizedString("dax.hide.cancel", value: "Cancel", comment: "")
    
    public static let tabSwitcherAccessibilityLabel = NSLocalizedString("tab.switcher.accessibility.label", value: "Tab Switcher", comment: "Tab Switcher Accessibility Label")
        
    public static let onboardingWidgetsHeader = NSLocalizedString("onboarding.widgets.header", value: "Using DuckDuckGo just got easier.", comment: "")
    public static let onboardingWidgetsContinueButtonText = NSLocalizedString("onboarding.widgets.continueButton", value: "Add Widget", comment: "")
    public static let onboardingWidgetsSkipButtonText = NSLocalizedString("onboarding.widgets.skipButton", value: "Maybe Later", comment: "")

    public static let doNotSellInfoText = NSLocalizedString("donotsell.info.headertext", value: "DuckDuckGo automatically blocks many trackers. With Global Privacy Control (GPC), you can also ask participating websites to restrict selling or sharing your personal data with other companies.",
                        comment: "")
    public static let doNotSellLearnMore = NSLocalizedString("donotsell.disclaimer.learnmore", value: "Learn More", comment: "")
    public static let doNotSellEnabled = NSLocalizedString("donotsell.enabled", value: "Enabled", comment: "GPC Setting state")
    public static let doNotSellDisabled = NSLocalizedString("donotsell.disabled", value: "Disabled", comment: "GPC Setting state")
    
    public static let emailBrowsingMenuUseNewDuckAddress = NSLocalizedString("email.browsingMenu.useNewDuckAddress", value: "Create a Duck Address", comment: "Email option title in the browsing menu")
    public static let emailBrowsingMenuAlert = NSLocalizedString("email.browsingMenu.alert", value: "New address copied to your clipboard", comment: "Title for the email copy browsing menu alert")
    public static let emailAliasAlertTitle = NSLocalizedString("email.aliasAlert.title", value: "Block email trackers with a Duck Address", comment: "Title for the email alias selection alert")
    public static let emailAliasAlertUseUserAddress = NSLocalizedString("email.aliasAlert.useUserAddress", value: "Use %@", comment: "Parameter is an email address (string)")
    public static let emailAliasAlertGeneratePrivateAddress = NSLocalizedString("email.aliasAlert.generatePrivateAddress", value: "Generate a Private Address", comment: "Option for generating a private email address")
    public static let emailAliasAlertDecline = NSLocalizedString("email.aliasAlert.decline", value: "Cancel", comment: "Cancel option for the email alias alert")

    public static let emailSettingEnabled = NSLocalizedString("email.settings.enabled", value: "Enabled", comment: "Signed in state for the email feature")
    public static let emailSettingsOff = NSLocalizedString("email.settings.off", value: "Off", comment: "Signed out state for the email feature")
    public static let emailSettingsFooterText = NSLocalizedString("email.settings.footer", value: "Removing Email Protection from this device removes the option to fill in your Personal Duck Address or a newly generated Private Duck Address into email fields as you browse the web.\n\nTo delete your Duck Addresses entirely, or for any other questions or feedback, reach out to us at support@duck.com.", comment: "Footer text for the email feature")

    public static let emailSignOutAlertTitle = NSLocalizedString("email.signOutAlert.title", value: "Remove Email Protection?", comment: "Title for the email sign out alert")
    public static let emailSignOutAlertDescription = NSLocalizedString("email.signOutAlert.description", value: "Note: Removing Email Protection from this device will not delete your Duck Address.", comment: "Description for the email sign out alert")
    public static let emailSignOutAlertCancel = NSLocalizedString("email.signOutAlert.cancel", value: "Cancel", comment: "Cancel option for the email sign out alert")
    public static let emailSignOutAlertRemove = NSLocalizedString("email.signOutAlert.remove", value: "Remove", comment: "Remove option for the email sign out alert")

    public static let emailWaitlistPrivacySimplified = NSLocalizedString("email.waitlist.privacy-simplified", value: "Email privacy, simplified.", comment: "Header text for the email waitlist")
    public static let emailWaitlistJoinedWaitlist = NSLocalizedString("email.waitlist.joined", value: "You’re on the waitlist!", comment: "Header text for the email waitlist")
    public static let emailWaitlistInvited = NSLocalizedString("email.waitlist.invited", value: "You’ve been invited!", comment: "Header text for the email waitlist")

    public static func emailWaitlistSummary(learnMoreString: String) -> String {
        let message = NSLocalizedString("email.waitlist.summary", value: "Block email trackers and hide your address, without switching your email provider. %@.", comment: "Description text for the email waitlist. Parameter is 'Learn more'.")
        return message.format(arguments: learnMoreString)
    }
    public static func emailWaitlistJoinedWithNotificationSummary(learnMoreString: String) -> String {
        let message = NSLocalizedString("email.waitlist.joined.notification", value: "We’ll send you a notification when Email Protection is ready for you. %@.", comment: "Description text for the email waitlist. Parameter is 'Learn more.'")
        return message.format(arguments: learnMoreString)
    }

    public static let emailWaitlistGetANotification = NSLocalizedString("email.waitlist.joined.no-notification.get-notification", value: "get a notification", comment: "Notification text for the email waitlist")
    public static func emailWaitlistJoinedWithoutNotificationSummary(getNotifiedString: String, learnMoreString: String) -> String {
        let message =  NSLocalizedString("email.waitlist.joined.no-notification", value: "Your invite will show up here when we’re ready for you. Want to %@ when it arrives? %@ about Email Protection.", comment: "First parameter is 'get a notification', second is 'Learn more'.")
        return message.format(arguments: getNotifiedString, learnMoreString)
    }

    public static let emailWaitlistJoinWaitlist = NSLocalizedString("email.waitlist.join", value: "Join the Private Waitlist", comment: "Action button text for the email waitlist")
    public static let emailWaitlistGetStarted = NSLocalizedString("email.waitlist.get-started", value: "Get Started", comment: "Action button text for the email waitlist")

    public static let emailWaitlistHaveInviteCode = NSLocalizedString("email.waitlist.have-invite-code", value: "I have an Invite Code", comment: "Invite code button text for the email waitlist")
    public static func emailWaitlistPrivacyGuarantee(learnMoreString: String) -> String {
        let message = NSLocalizedString("email.waitlist.privacy-guarantee", value: "We do not save your emails. %@.", comment: "Footer text for the email waitlist. Parameter is 'Learn more'.")
        return message.format(arguments: learnMoreString)
    }
    public static let emailWaitlistLearnMore = NSLocalizedString("email.waitlist.learn-more", value: "Learn more", comment: "Footer text for the email waitlist")
    public static let emailWaitlistErrorJoining = NSLocalizedString("email.waitlist.error-joining", value: "An error occurred while joining the Waitlist, please try again later", comment: "Error text when failing to join the waitlist")

    public static let emailWaitlistNotificationPermissionTitle = NSLocalizedString("email.waitlist.notification-permission.title", value: "Would you like us to notify you when it’s your turn?", comment: "Title for the permission notification for the email waitlist")
    public static let emailWaitlistNotificationPermissionBody = NSLocalizedString("email.waitlist.notification-permission.body", value: "We’ll send you a notification when you can start using Email Protection.", comment: "Body text for the permission notification for the email waitlist")
    public static let emailWaitlistNotificationPermissionNotifyMe = NSLocalizedString("email.waitlist.notification.notify-me", value: "Notify Me", comment: "Accept option for the permission notification for the email waitlist")
    public static let emailWaitlistNotificationPermissionNoThanks = NSLocalizedString("email.waitlist.notification.no-thanks", value: "No Thanks", comment: "Decline option for the permission notification for the email waitlist")

    public static let emailWaitlistAvailableNotificationTitle = NSLocalizedString("email.waitlist.notification.title", value: "Your Email Protection Invitation is Here!", comment: "Title for the email waitlist notification")
    public static let emailWaitlistAvailableNotificationBody = NSLocalizedString("email.waitlist.notification.body", value: "You joined the waitlist and asked us to notify you when it’s your turn to try our Email Protection.", comment: "Body text for the email waitlist notification")

    public static let fireButtonAnimationFireRisingName = NSLocalizedString("fireButtonAnimation.fireRising.name", value: "Inferno", comment: "")
    public static let fireButtonAnimationWaterSwirlName = NSLocalizedString("fireButtonAnimation.waterSwirl.name", value: "Whirlpool", comment: "")
    public static let fireButtonAnimationAirstreamName = NSLocalizedString("fireButtonAnimation.airstream.name", value: "Airstream", comment: "")
    public static let fireButtonAnimationNoneName = NSLocalizedString("fireButtonAnimation.none.name", value: "None", comment: "")
    
    public static let webJSAlertOKButton = NSLocalizedString("webJSAlert.OK.button", value: "OK", comment: "OK button for JavaScript alerts")
    public static let webJSAlertCancelButton = NSLocalizedString("webJSAlert.cancel.button", value: "Cancel", comment: "Cancel button for JavaScript alerts")
        public static let noVoicePermissionAlertTitle = NSLocalizedString("voiceSearch.alert.no-permission.title", value: "Microphone Access Required", comment: "Title for alert warning the user about missing microphone permission")
    public static let noVoicePermissionAlertMessage = NSLocalizedString("voiceSearch.alert.no-permission.message", value: "Please allow Microphone access in iOS System Settings for DuckDuckGo to use voice features.", comment: "Message for alert warning the user about missing microphone permission")
    public static let noVoicePermissionActionSettings = NSLocalizedString("voiceSearch.alert.no-permission.action.settings", value: "Settings", comment: "No microphone permission alert action button to open the settings app")
    public static let voiceSearchCancelButton = NSLocalizedString("voiceSearch.cancel", value: "Cancel", comment: "Cancel button for voice search")
    public static let voiceSearchPrivacyAcknowledgmentTitle = NSLocalizedString("voiceSearch.alert.privacy-acknowledgment.title", value: "Microphone Access Required for Private Voice Search", comment: "Title for alert explaining voice-search privacy")
    public static let voiceSearchPrivacyAcknowledgmentMessage = NSLocalizedString("voiceSearch.alert.privacy-acknowledgment.message", value: "DuckDuckGo never listens to what you say. All speech data processing for Private Voice Search happens on your device.", comment: "Message for alert explaining voice-search privacy")
    public static let voiceSearchPrivacyAcknowledgmentAcceptButton = NSLocalizedString("voiceSearch.alert.privacy-acknowledgment.action.accept", value: "OK", comment: "Voice-search privacy accept alert action")
    public static let voiceSearchPrivacyAcknowledgmentRejectButton = NSLocalizedString("voiceSearch.alert.privacy-acknowledgment.action.reject", value: "Cancel", comment: "Voice-search privacy reject alert action")
    public static let voiceSearchFooter = NSLocalizedString("voiceSearch.footer.note", value: "Audio is processed on-device. It's not stored or shared with anyone, including DuckDuckGo.", comment: "Voice-search footer note with on-device privacy warning")
    public static let textSizeDescription = NSLocalizedString("textSize.description", value: "Choose your preferred text size. Websites you view in DuckDuckGo will adjust to it.", comment: "Description text for the text size adjustment setting")
    public static func textSizeFooter(for percentage: String) -> String {
        let message = NSLocalizedString("textSize.footer", value: "Text Size - %@", comment: "Replacement string is a current percent value e.g. '120%'")
        return message.format(arguments: percentage)
    }
    
    public static let addWidget = NSLocalizedString("addWidget.button", value: "Add Widget", comment: "")
    public static let addWidgetTitle = NSLocalizedString("addWidget.title", value: "One tap to your favorite sites.", comment: "")
    public static let addWidgetDescription = NSLocalizedString("addWidget.description", value: "Search privately and quickly visit sites you love.", comment: "")
    public static let addWidgetSettingsFirstParagraph = NSLocalizedString("addWidget.settings.firstParagraph", value: "Long-press on the home screen to enter jiggle mode.", comment: "")
    public static let addWidgetSettingsSecondParagraph = NSLocalizedString("addWidget.settings.secondParagraph.%@", value: "Tap the plus %@ button.", comment: "Replacement string is a plus button icon.")
    public static let addWidgetSettingsThirdParagraph = NSLocalizedString("addWidget.settings.title", value: "Find and select DuckDuckGo. Then choose a widget.", comment: "")
    
    public static let webJSAlertDisableAlertsButton = NSLocalizedString("webJSAlert.block-alerts.button", value: "Block Alerts", comment: "Block Alerts button for JavaScript alerts")

}
