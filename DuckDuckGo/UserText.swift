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
    public static let actionBookmark = NSLocalizedString("action.title.bookmark", value: "Bookmark", comment: "Confirmation of Add to Bookmarks action in Add All Open Tabs to Bookmarks alert")
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

    public static let actionManageFavorites = NSLocalizedString("action.manage.favorites", value: "Manage", comment: "Button label for managing favorites")

    public static let voiceoverSuggestionTypeWebsite = NSLocalizedString("voiceover.suggestion.type.website", value: "Open website", comment: "Open suggested website action accessibility title")
    public static let voiceoverSuggestionTypeBookmark = NSLocalizedString("voiceover.suggestion.type.bookmark", value: "Bookmark", comment: "Voice-over title for a Bookmark suggestion. Noun")
    public static let voiceoverSuggestionTypeSearch = NSLocalizedString("voiceover.suggestion.type.search", value: "Search at DuckDuckGo", comment: "Search for suggestion action accessibility title")
    public static let voiceoverActionAutocomplete = NSLocalizedString("voiceover.action.suggestion.autocomplete", value: "Autocomplete suggestion", comment: "Autocomplete selected suggestion into the Address Bar button accessibility label")

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
    public static let privacyProtectionTrackersBlockedNew = NSLocalizedString("privacy.protection.trackers.blocked.new", value: "Requests Blocked from Loading", comment: "")
    public static let privacyProtectionNoTrackersBlocked = NSLocalizedString("privacy.protection.trackers.not.blocked", value: "No Tracking Requests Blocked", comment: "")
    public static let privacyProtectionTrackersFound = NSLocalizedString("privacy.protection.trackers.found", comment: "Do not translate - stringsdict entry")
    public static let privacyProtectionTrackersNotFound = NSLocalizedString("privacy.protection.trackers.not.found", value: "No Tracking Requests Found", comment: "")
    public static let privacyProtectionTrackersFoundNew = NSLocalizedString("privacy.protection.trackers.found.new", value: "Tracking Requests Found", comment: "")
    public static let privacyProtectionFirstPartyTrackersLoaded = NSLocalizedString("privacy.protection.first.party.trackers.loaded", comment: "Do not translate - stringsdict entry")
    public static let privacyProtectionOtherDomainsLoaded = NSLocalizedString("privacy.protection.other.domains.loaded", comment: "Do not translate - stringsdict entry")
    public static let privacyProtectionOtherThirdPartyDomainsLoaded = NSLocalizedString("privacy.protection.other.third.party.domains.loaded", value: "Third-Party Requests Loaded", comment: "")
    public static let privacyProtectionNoOtherThirdPartyDomainsLoaded = NSLocalizedString("privacy.protection.no.other.third.party.domains.loaded", value: "No Third-Party Requests Loaded", comment: "")
    public static let privacyProtectionMajorTrackersBlocked = NSLocalizedString("privacy.protection.major.trackers.blocked", comment: "Major trackers blocked")
    public static let privacyProtectionMajorTrackersFound = NSLocalizedString("privacy.protection.major.trackers.found", comment: "Major trackers found")
    public static let privacyProtectionMajorTrackersNotFound = NSLocalizedString("privacy.protection.major.trackers.not.found", value: "No Major Tracker Networks Found", comment: "")
    public static let privacyProtectionMajorTrackersFoundNew = NSLocalizedString("privacy.protection.major.trackers.found.new", value: "Major Tracker Networks Found", comment: "")
    
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
    public static let ppEncryptionForcedHeadingNew = NSLocalizedString("privacy.protection.encryption.forced.heading.new", value: "Encrypted Connection", comment: "")
    public static let ppEncryptionMixedHeading = NSLocalizedString("privacy.protection.encryption.mixed.heading", value: "Mixed Encryption", comment: "")
    public static let ppEncryptionUnencryptedHeading = NSLocalizedString("privacy.protection.encryption.unencrypted.heading", value: "Unencrypted Connection", comment: "")
    
    public static let ppNetworkLeaderboard = NSLocalizedString("privacy.protection.network.leaderboard", value: "Tracker networks were found on %@%% of websites you’ve visited since %@.", comment: "First parameter (%@) is a number (percent), %% is a percent sign, second %@ is a date")
    public static let ppNetworkLeaderboardGatheringData = NSLocalizedString("privacy.protection.network.leaderboard.gathering", value: "We’re still collecting data to show how\nmany trackers we’ve blocked.", comment: "")
    
    public static let ppEncryptionHeaderInfo = NSLocalizedString("privacy.protection.encryption.header", value: "An encrypted connection prevents eavesdropping of any personal information you send to a website.", comment: "")
    
    public static let ppEncryptionUnencryptedDetailInfo = NSLocalizedString("privacy.protection.encryption.unencrypted", value: "Be careful when entering personal information on this site.", comment: "")
    
    public static let ppTopOffendersInfo = NSLocalizedString("privacy.protection.top.offenders.info", value: "These stats are only stored on your device, and are not sent anywhere. Ever.", comment: "")
    
    public static let ppTrackerNetworksInfo = NSLocalizedString("privacy.protection.tracker.networks.info", value: "Trackers help companies profile you. We blocked these trackers from loading and monitoring your activity on this page.", comment: "")
    public static let ppTrackerNetworksInfoNew = NSLocalizedString("privacy.protection.tracker.networks.info.new", value: "The following third-party domains’ requests were blocked from loading because they were identified as tracking requests. If a company's requests are loaded, it can allow them to profile you.", comment: "")
    public static let ppTrackerNetworksInfoEmptyStatePrivacyOff = NSLocalizedString("privacy.protection.tracker.networks.info.empty", value: "No tracking requests were blocked from loading because Protections are turned off for this site. If a company's requests are loaded, it can allow them to profile you.", comment: "")
    public static let ppTrackerNetworksInfoEmptyStateNoTrackers = NSLocalizedString("privacy.protection.tracker.networks.info.empty.no.trackers", value: "We did not detect any tracking requests.", comment: "")
    public static let ppOtherDomainsInfo = NSLocalizedString("privacy.protection.other.domains.info", value: "The following third-party domains’ requests were loaded. If a company's requests are loaded, it can allow them to profile you, though our other web tracking protections still apply.", comment: "")
    public static let ppOtherDomainsInfoDisabledProtection = NSLocalizedString("privacy.protection.other.domains.info.disabled.protection", value: "No third-party requests were blocked from loading because Protections are turned off for this site. If a company's requests are loaded, it can allow them to profile you.", comment: "")
    public static let ppOtherDomainsInfoHeaderDisabledProtection = NSLocalizedString("privacy.protection.other.domains.info.header.disabled.protection", value: "The following domains’ tracking requests were loaded.", comment: "")
    public static let ppOtherDomainsInfoHeaderDisabledProtectionAlsoNew = NSLocalizedString("privacy.protection.other.domains.info.header.disabled.protection.also.new", value: "The following domain’s requests were also loaded.", comment: "")
    public static let ppOtherDomainsInfoHeaderDisabledProtectionNew = NSLocalizedString("privacy.protection.other.domains.info.header.disabled.protection.new", value: "The following domains’ requests were loaded.", comment: "")
    public static let ppOtherDomainsAdClickAttribution = NSLocalizedString("privacy.protection.other.domains.adclickattribution", value: "The following domain’s requests were loaded because a %@ ad on DuckDuckGo was recently clicked. These requests help evaluate ad effectiveness. All ads on DuckDuckGo are non-profiling.", comment: "")
    public static let ppOtherDomainsExceptions = NSLocalizedString("privacy.protection.other.domains.exceptions", value: "The following domain’s requests were loaded to prevent site breakage.", comment: "")
    public static let ppOtherDomainsOwnedByFirstParty = NSLocalizedString("privacy.protection.other.domains.firstparty", value: "The following domain’s requests were loaded because they’re associated with %@.", comment: "")
    public static let ppOtherDomainsOtherThirdParties = NSLocalizedString("privacy.protection.other.domains.thirdparties", value: "The following domain’s requests were loaded.", comment: "")
    public static let ppOtherDomainsOtherThirdPartiesEmptyState = NSLocalizedString("privacy.protection.other.domains.thirdparties.empty", value: "We did not detect requests from any third-party domains.", comment: "")
    
    public static let ppAboutProtectionsLink = NSLocalizedString("privacy.protection.about.protections.link", value: "About our Web Tracking Protections", comment: "")
    public static let ppAboutSearchProtectionsAndAdsLink = NSLocalizedString("privacy.protection.about.search.protections.link", value: "About our search protections and ads", comment: "")
    public static let ppAboutSearchProtectionsAndAdsLinkNew = NSLocalizedString("privacy.protection.about.search.protections.link.new", value: "How our search ads impact our protections", comment: "")
    public static let ppPlatformLimitationsFooterInfo = NSLocalizedString("privacy.protection.platform.limitations.footer.info", value: "Please note: platform limitations may limit our ability to detect all requests.", comment: "")
    public static let ppTrackerCategoryNonProfiling = NSLocalizedString("privacy.protection.platform.tracker.category.non.profiling", value: "Non-Profiling", comment: "")
    
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
    
    public static let favoriteMenuRemove = NSLocalizedString("favorite.menu.remove", value: "Remove", comment: "")
    public static let favoriteMenuEdit = NSLocalizedString("favorite.menu.edit", value: "Edit", comment: "")
    
    public static let emptyBookmarks = NSLocalizedString("empty.bookmarks", value: "No bookmarks added yet", comment: "Empty list state placholder")
    public static let noMatchesFound = NSLocalizedString("empty.search", value: "No matches found", comment: "Empty search placeholder on bookmarks search")
    
    public static let bookmarkTitlePlaceholder = NSLocalizedString("bookmark.title.placeholder", value: "Website title", comment: "Placeholder in the add bookmark form")
    public static let bookmarkAddressPlaceholder = NSLocalizedString("bookmark.address.placeholder", value: "www.example.com", comment: "Placeholder in the add bookmark form")
    public static let bookmarkFolderSelectTitle = NSLocalizedString("bookmark.folderSelect.title", value: "Location", comment: "Header for folder selection for bookmarks")
    public static let bookmarkTopLevelFolderTitle = NSLocalizedString("bookmark.topLevelFolder.title", value: "Bookmarks", comment: "Top level bookmarks folder title")
    public static let deleteBookmarkFolderAlertTitle = NSLocalizedString("bookmark.deleteFolderAlert.title", value: "Delete %@?", comment: "Delete bookmark folder alert title")
    
    public static func deleteBookmarkFolderAlertMessage(numberOfChildren: Int) -> String {
        let message = NSLocalizedString("bookmark.deleteFolderAlert.message", comment: "Do not translate - stringsdict entry")
        return message.format(arguments: numberOfChildren)
    }
    
    public static let deleteBookmarkFolderAlertDeleteButton = NSLocalizedString("bookmark.deleteFolderAlert.deleteButton", value: "Delete", comment: "Delete bookmark folder alert delete button")
    public static let addbookmarkFolderButton = NSLocalizedString("bookmark.addFolderButton", value: "Add Folder", comment: "Add bookmark folder button text")
    
    public static let editFavoriteScreenTitle = NSLocalizedString("bookmark.editFavorite.title", value: "Edit Favorite", comment: "Edit favorite screen title")
    public static let editBookmarkScreenTitle = NSLocalizedString("bookmark.editBookmark.title", value: "Edit Bookmark", comment: "Edit bookmark screen title")
    public static let editFolderScreenTitle = NSLocalizedString("bookmark.editFolder.title", value: "Edit Folder", comment: "Edit folder screen title")
    
    public static let addFavoriteScreenTitle = NSLocalizedString("bookmark.addFavorite.title", value: "Add Favorite", comment: "Add favorite screen title")
    public static let addBookmarkScreenTitle = NSLocalizedString("bookmark.addBookmark.title", value: "Add Bookmark", comment: "Add bookmark screen title")
    public static let addFolderScreenTitle = NSLocalizedString("bookmark.addFolder.title", value: "Add Folder", comment: "Add folder screen title")
    
    public static let moreBookmarkButton = NSLocalizedString("bookmark.moreButton", value: "More", comment: "More options button text")

    public static let importExportBookmarksTitle = NSLocalizedString("bookmarks.importExport.title", value: "Import an HTML file of bookmarks from another browser, or export your existing bookmarks.", comment: "Title of prompt for users where they can choose to import or export an HTML file containing webpage bookmarks")
    public static let importBookmarksActionTitle = NSLocalizedString("bookmarks.importAction.title", value: "Import HTML File", comment: "Title of option to import HTML")
    public static let exportBookmarksActionTitle = NSLocalizedString("bookmarks.exportAction.title", value: "Export HTML File", comment: "Title of option to export HTML")
    public static let importBookmarksFooterButton = NSLocalizedString("bookmarks.importExport.footer.button.title", value: "Import bookmark file from another browser", comment: "Import bookmark file button text")
    public static let importBookmarksSuccessMessage = NSLocalizedString("bookmarks.import.success.message", value: "Your bookmarks have been imported.", comment: "Confirmation message that bookmarks have been imported")
    public static let importBookmarksFailedMessage = NSLocalizedString("bookmarks.import.failed.message", value: "Sorry, we aren’t able to import this file.", comment: "Failure message when bookmarks failed to import")
    public static let exportBookmarksShareSuccessMessage = NSLocalizedString("bookmarks.export.share.success.message", value: "Your bookmarks have been shared.", comment: "Confirmation message that bookmarks have been shared successfully to another app")
    public static let exportBookmarksFilesSuccessMessage = NSLocalizedString("bookmarks.export.files.success.message", value: "Your bookmarks have been exported.", comment: "Confirmation message that bookmarks have been exported to the file system")
    public static let exportBookmarksFailedMessage = NSLocalizedString("bookmarks.export.failed.message", value: "We couldn’t export your bookmarks, please try again.", comment: "Failure message when bookmarks failed to export")

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

    public static let daxDialogBrowsingAfterSearch = NSLocalizedString("dax.onboarding.browsing.after.search", value: "Your DuckDuckGo searches are anonymous. Always. 🙌", comment: "")
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
    
    public static let emailBrowsingMenuUseNewDuckAddress = NSLocalizedString("email.browsingMenu.useNewDuckAddress", value: "Generate Private Duck Address", comment: "Email option title in the browsing menu")
    public static let emailBrowsingMenuAlert = NSLocalizedString("email.browsingMenu.alert", value: "New address copied to your clipboard", comment: "Title for the email copy browsing menu alert")
    public static let emailAliasAlertTitle = NSLocalizedString("email.aliasAlert.title", value: "Block email trackers with a Duck Address", comment: "Title for the email alias selection alert")
    public static let emailAliasAlertUseUserAddress = NSLocalizedString("email.aliasAlert.useUserAddress", value: "Use %@", comment: "Parameter is an email address (string)")
    public static let emailAliasAlertGeneratePrivateAddress = NSLocalizedString("email.aliasAlert.generatePrivateAddress", value: "Generate Private Duck Address", comment: "Option for generating a private email address")
    public static let emailAliasAlertDecline = NSLocalizedString("email.aliasAlert.decline", value: "Cancel", comment: "Cancel option for the email alias alert")

    public static let emailSettingEnabled = NSLocalizedString("email.settings.enabled", value: "Enabled", comment: "Signed in state for the email feature")
    public static let emailSettingsOff = NSLocalizedString("email.settings.off", value: "Off", comment: "Signed out state for the email feature")
    public static let emailSettingsFooterText = NSLocalizedString("email.settings.footer", value: "Removing Email Protection from this device removes the option to fill in your Personal Duck Address or a newly generated Private Duck Address into email fields as you browse the web.\n\nTo delete your Duck Addresses entirely, or for any other questions or feedback, reach out to us at support@duck.com.", comment: "Footer text for the email feature")

    public static let fireButtonAnimationFireRisingName = NSLocalizedString("fireButtonAnimation.fireRising.name", value: "Inferno", comment: "")
    public static let fireButtonAnimationWaterSwirlName = NSLocalizedString("fireButtonAnimation.waterSwirl.name", value: "Whirlpool", comment: "")
    public static let fireButtonAnimationAirstreamName = NSLocalizedString("fireButtonAnimation.airstream.name", value: "Airstream", comment: "")
    public static let fireButtonAnimationNoneName = NSLocalizedString("fireButtonAnimation.none.name", value: "None", comment: "")
    
    public static let webJSAlertOKButton = NSLocalizedString("webJSAlert.OK.button", value: "OK", comment: "OK button for JavaScript alerts")
    public static let webJSAlertCancelButton = NSLocalizedString("webJSAlert.cancel.button", value: "Cancel", comment: "Cancel button for JavaScript alerts")
    public static let webJSAlertWebsiteMessageFormat = NSLocalizedString("webJSAlert.website-message.format", value: "A message from %@:", comment: "Alert title explaining the message is shown by a website")

    public static let noVoicePermissionAlertTitle = NSLocalizedString("voiceSearch.alert.no-permission.title", value: "Microphone Access Required", comment: "Title for alert warning the user about missing microphone permission")
    public static let noVoicePermissionAlertMessage = NSLocalizedString("voiceSearch.alert.no-permission.message", value: "Please allow Microphone access in iOS System Settings for DuckDuckGo to use voice features.", comment: "Message for alert warning the user about missing microphone permission")
    public static let noVoicePermissionActionSettings = NSLocalizedString("voiceSearch.alert.no-permission.action.settings", value: "Settings", comment: "No microphone permission alert action button to open the settings app")
    public static let voiceSearchCancelButton = NSLocalizedString("voiceSearch.cancel", value: "Cancel", comment: "Cancel button for voice search")
    public static let voiceSearchFooter = NSLocalizedString("voiceSearch.footer.note", value: "Audio is processed on-device. It's not stored or shared with anyone, including DuckDuckGo.", comment: "Voice-search footer note with on-device privacy warning")
    public static let textSizeDescription = NSLocalizedString("textSize.description", value: "Choose your preferred text size. Websites you view in DuckDuckGo will adjust to it.", comment: "Description text for the text size adjustment setting")
    public static func textSizeFooter(for percentage: String) -> String {
        let message = NSLocalizedString("textSize.footer", value: "Text Size - %@", comment: "Replacement string is a current percent value e.g. '120%'")
        return message.format(arguments: percentage)
    }
    
    public static let addWidget = NSLocalizedString("addWidget.button", value: "Add Widget", comment: "")
    public static let addWidgetTitle = NSLocalizedString("addWidget.title", value: "One tap to your favorite sites.", comment: "")
    public static let addWidgetDescription = NSLocalizedString("addWidget.description", value: "Get quick access to private search and the sites you love.", comment: "")
    public static let addWidgetSettingsFirstParagraph = NSLocalizedString("addWidget.settings.firstParagraph", value: "Long-press on the home screen to enter jiggle mode.", comment: "")
    public static let addWidgetSettingsSecondParagraph = NSLocalizedString("addWidget.settings.secondParagraph.%@", value: "Tap the plus %@ button.", comment: "Replacement string is a plus button icon.")
    public static let addWidgetSettingsThirdParagraph = NSLocalizedString("addWidget.settings.title", value: "Find and select DuckDuckGo. Then choose a widget.", comment: "")

    public static let actionSaveToDownloads = NSLocalizedString("downloads.alert.action.save-to-downloads", value: "Save to Downloads", comment: "Alert action for starting a file dowload")
    public static func messageDownloadStarted(for filename: String) -> String {
        let message = NSLocalizedString("downloads.message.download-started", value: "Download started for %@", comment: "Message confirming that the download process has started. Parameter is downloaded file's filename")
        return message.format(arguments: filename)
    }
    public static func messageDownloadComplete(for filename: String) -> String {
        let message = NSLocalizedString("downloads.message.download-complete", value: "Download complete for %@", comment: "Message confirming that the download process has completed. Parameter is downloaded file's filename")
        return message.format(arguments: filename)
    }
    public static func messageDownloadDeleted(for filename: String) -> String {
        let message = NSLocalizedString("downloads.message.download-deleted", value: "Deleted %@", comment: "Message confirming the file was deleted. Parameter is file's filename")
        return message.format(arguments: filename)
    }
    public static let messageAllFilesDeleted = NSLocalizedString("downloads.message.all-files-deleted", value: "All files deleted", comment: "Message confirming that all files on the downloads list have been deleted")
    
    public static let actionGenericShow = NSLocalizedString("action.generic.show", value: "Show", comment: "Button label for a generic show action")
    public static let actionDownloads = NSLocalizedString("action.title.downloads", value: "Downloads", comment: "Downloads menu item opening the downlods list")
    public static let downloadsScreenTitle = NSLocalizedString("downloads.downloads-list.title", value: "Downloads", comment: "Downloads list screen title")
    
    public static func downloadProgressMessage(currentSize: String, totalSize: String) -> String {
        let message = NSLocalizedString("downloads.downloads-list.row.downloading", value: "Downloading - %@ of %@", comment: "Label displaying file download progress. Both parameters are formatted data size measurements e.g. 5MB. First parameter is data size currently downloaded. Second parameter is total expected data size of the file.")
        return message.format(arguments: currentSize, totalSize)
    }
    
    public static func downloadProgressMessageForUnknownTotalSize(currentSize: String) -> String {
        let message = NSLocalizedString("downloads.downloads-list.row.downloadingUnknownTotalSize", value: "Downloading - %@", comment: "Label displaying file download progress. The parameter is formatted data size measurements currently downloaded e.g. 5MB.")
        return message.format(arguments: currentSize)
    }

    public static let cancelDownloadAlertTitle = NSLocalizedString("downloads.cancel-download.alert.title", value: "Cancel download?", comment: "Title for alert when trying to cancel the file download")
    public static let cancelDownloadAlertDescription = NSLocalizedString("downloads.cancel-download.alert.message", value: "Are you sure you want to cancel this download?", comment: "Message for alert when trying to cancel the file download")
    public static let cancelDownloadAlertResumeAction = NSLocalizedString("downloads.cancel-download.alert.resume", value: "Resume", comment: "Resume download action for alert when trying to cancel the file download")
    public static let cancelDownloadAlertCancelAction = NSLocalizedString("downloads.cancel-download.alert.cancel", value: "Cancel", comment: "Cancel download action for alert when trying to cancel the file download")

    public static let downloadsListDeleteAllButton = NSLocalizedString("downloads.downloads-list.delete-all", value: "Delete All", comment: "Button for deleting all items on downloads list")
    public static let messageDownloadFailed = NSLocalizedString("downloads.message.download-failed", value: "Failed to download. Check internet connection.", comment: "Message informing that the download has failed due to connection issues")
    public static let fireButtonInterruptingDownloadsAlertDescription = NSLocalizedString("downloads.fire-button.alert.message", value: "This will also cancel downloads in progress", comment: "Additional alert message shown when there are active downloads when using the fire button")
    
    public static let dateRangeToday = NSLocalizedString("date.range.today", value: "Today", comment: "Title for a section containing only items from today")
    public static let dateRangeYesterday = NSLocalizedString("date.range.yesterday", value: "Yesterday", comment: "Title for a section containing only items from yesterday")
    public static let dateRangePastWeek = NSLocalizedString("date.range.past-week", value: "Past week", comment: "Title for a section containing only items from past week")
    public static let dateRangePastMonth = NSLocalizedString("date.range.past-month", value: "Past month", comment: "Title for a section containing only items from past month")
    
    public static let emptyDownloads = NSLocalizedString("downloads.downloads-list.empty", value: "No files downloaded yet", comment: "Empty downloads list placholder")
    
    public static let autofillSaveLoginTitleNewUser = NSLocalizedString("autofill.save-login.new-user.title", value: "Do you want DuckDuckGo to save your Login?", comment: "Title displayed on modal asking for the user to save the login for the first time")
    public static let autofillSaveLoginTitle = NSLocalizedString("autofill.save-login.title", value: "Save Login?", comment: "Title displayed on modal asking for the user to save the login")
    public static let autofillUpdateUsernameTitle = NSLocalizedString("autofill.update-usernamr.title", value: "Update Username?", comment: "Title displayed on modal asking for the user to update the username")

    public static let autofillSaveLoginMessageNewUser = NSLocalizedString("autofill.save-login.new-user.message", value: "DuckDuckGo will securely store this Login on your device.", comment: "Message displayed on modal asking for the user to save the login for the first time")
    public static let autofillSaveLoginNotNowCTA = NSLocalizedString("autofill.save-login.not-now.CTA", value: "Not Now", comment: "Cancel CTA displayed on modal asking for the user to save the login")
   
    public static let autofillSavePasswordTitle = NSLocalizedString("autofill.save-password.title", value: "Save Password?", comment: "Title displayed on modal asking for the user to save the password")
    public static let autofillUpdatePasswordTitle = NSLocalizedString("autofill.update-password.title", value: "Update Password?", comment: "Title displayed on modal asking for the user to update the password")
    public static let autofillSaveLoginSaveCTA = NSLocalizedString("autofill.save-login.save.CTA", value: "Save Login", comment: "Confirm CTA displayed on modal asking for the user to save the login")
    public static let autofillSavePasswordSaveCTA = NSLocalizedString("autofill.save-password.save.CTA", value: "Save Password", comment: "Confirm CTA displayed on modal asking for the user to save the password")
    public static let autofillUpdatePasswordSaveCTA = NSLocalizedString("autofill.update-password.save.CTA", value: "Update Password", comment: "Confirm CTA displayed on modal asking for the user to update the password")
    public static let autofillShowPassword = NSLocalizedString("autofill.show-password", value: "Show Password", comment: "Accessibility title for a Show Password button displaying actial password instead of *****")
    public static let autofillHidePassword = NSLocalizedString("autofill.hide-password", value: "Hide Password", comment: "Accessibility title for a Hide Password button replacing displayed password with *****")
    public static let autofillUpdateLoginSaveCTA = NSLocalizedString("autofill.update-login.save.CTA", value: "Update Login", comment: "Confirm CTA displayed on modal asking for the user to update the login")
    public static let autofillAdditionalLoginInfoMessage = NSLocalizedString("autofill.save-login.additional-login.message", value: "This will save an additional Login for this site.", comment: "Message displayed on modal explaining that an additional login will be saved.")
    public static let autofillLoginSavedToastMessage = NSLocalizedString("autofill.login-saved.toast", value: "Login saved", comment: "Message displayed after saving an autofill login")
    public static let autofillLoginUpdatedToastMessage = NSLocalizedString("autofill.login-updated.toast", value: "Login updated", comment: "Message displayed after updating an autofill login")
    public static let autofillLoginSaveToastActionButton = NSLocalizedString("autofill.login-save-action-button.toast", value: "View", comment: "Button displayed after saving/updating an autofill login that takes the user to the saved login")

    public static let autofillKeepEnabledAlertTitle = NSLocalizedString("autofill.keep-enabled.alert.title", value: "Do you want to keep using Autofill?", comment: "Title for alert when asking the user if they want to keep using autofill")
    public static let autofillKeepEnabledAlertMessage = NSLocalizedString("autofill.keep-enabled.alert.message", value: "You can disable Autofill at any time in Settings.", comment: "Message for alert when asking the user if they want to keep using autofill")
    public static let autofillKeepEnabledAlertKeepUsingAction = NSLocalizedString("autofill.keep-enabled.alert.keep-using", value: "Keep Using", comment: "Confirm action for alert when asking the user if they want to keep using autofill")
    public static let autofillKeepEnabledAlertDisableAction = NSLocalizedString("autofill.keep-enabled.alert.disable", value: "Disable", comment: "Disable action for alert when asking the user if they want to keep using autofill")

    public static let actionAutofillLogins = NSLocalizedString("action.title.autofill.logins", value: "Autofill Logins", comment: "Autofill Logins menu item opening the login list")

    // MARK: - Mac Waitlist
    
    public static let macBrowserTitle = NSLocalizedString("mac-waitlist.title", value: "DuckDuckGo Desktop App", comment: "Title for the Mac Waitlist feature")
    
    public static let macWaitlistSummary = NSLocalizedString("mac-browser.waitlist.summary", value: "DuckDuckGo for Mac has the speed you need, the browsing features you expect, and comes packed with our best-in-class privacy essentials.", comment: "Summary text for the macOS browser waitlist")
    
    public static let macWaitlistTryDuckDuckGoForMac = NSLocalizedString("mac-waitlist.join-waitlist-screen.try-duckduckgo-for-mac", value: "Get DuckDuckGo for Mac!", comment: "Title for the Join Waitlist screen")
    
    public static let macWaitlistOnYourMacGoTo = NSLocalizedString("mac-waitlist.join-waitlist-screen.on-your-mac-go-to", value: "On your Mac, go to:", comment: "Description text above the Share Link button")
    
    public static let macWaitlistShareLink = NSLocalizedString("mac-waitlist.join-waitlist-screen.share-link", value: "Share Link", comment: "Title for the Share Link button")
    
    public static let macWaitlistCopy = NSLocalizedString("mac-waitlist.copy", value: "Copy", comment: "Title for the copy action")
    
    public static let macWaitlistWindows = NSLocalizedString("mac-waitlist.join-waitlist-screen.windows", value: "Windows coming soon!", comment: "Disclaimer for the Join Waitlist screen")
    
    // MARK: Notifications
    
    public static let macWaitlistAvailableNotificationTitle = NSLocalizedString("mac-waitlist.available.notification.title", value: "DuckDuckGo for Mac is ready!", comment: "Title for the macOS waitlist notification")
    
    public static let macWaitlistAvailableNotificationBody = NSLocalizedString("mac-waitlist.available.notification.body", value: "Open your invite", comment: "Body text for the macOS waitlist notification")
    
    // MARK: Settings Screen
    
    public static let emailSettingsSubtitle = NSLocalizedString("email.settings.subtitle", value: "Block email trackers and hide your address", comment: "Subtitle for the email settings cell")
    
    public static let macWaitlistBrowsePrivately = NSLocalizedString("mac-waitlist.settings.browse-privately", value: "Browse privately with our app for Mac", comment: "Title for the settings subtitle")
    
    // MARK: Share Sheet
    
    public static let macWaitlistShareSheetTitle = NSLocalizedString("mac-waitlist.share-sheet.title", value: "DuckDuckGo for Mac", comment: "Title for the share sheet entry")
    
    public static func macWaitlistShareSheetMessage() -> String {
        return NSLocalizedString("mac-waitlist.share-sheet.message", value: """
        Ready to start browsing privately on Mac?
        
        Visit this URL on your Mac to download:
        https://duckduckgo.com/mac
        """, comment: "Message used when sharing to iMessage")
    }

    public static let autofillLoginDetailsLoginName = NSLocalizedString("autofill.logins.details.login-name", value:"Login Title", comment: "Login name label for login details on autofill")
    public static let autofillLoginDetailsUsername = NSLocalizedString("autofill.logins.details.username", value:"Username", comment: "Username label for login details on autofill")
    public static let autofillLoginDetailsPassword = NSLocalizedString("autofill.logins.details.password", value:"Password", comment: "Password label for login details on autofill")
    
    public static let autofillLoginDetailsAddress = NSLocalizedString("autofill.logins.details.address", value:"Website URL", comment: "Address label for login details on autofill")
    public static let autofillLoginDetailsNotes = NSLocalizedString("autofill.logins.details.notes", value:"Notes", comment: "Notes label for login details on autofill")
    public static let autofillLockedViewTitle = NSLocalizedString("autofill.logins.details.title", value:"Unlock Autofill", comment: "Title for view displayed when autofill is locked")
    public static let autofillEmptyViewTitleDisabled = NSLocalizedString("autofill.logins.empty-view.title-disabled", value:"Enable Autofill to start saving Logins", comment: "Title for view displayed when autofill is disabled and has no items")
    public static let autofillEmptyViewTitle = NSLocalizedString("autofill.logins.empty-view.title", value:"No logins saved yet", comment: "Title for view displayed when autofill has no items")
    public static let autofillEmptyViewSubtitle = NSLocalizedString("autofill.logins.empty-view.subtitle", value:"Logins are stored securely on this device only", comment: "Subtitle for view displayed when autofill has no items")
    public static let autofillSearchNoResultTitle = NSLocalizedString("autofill.logins.search.no-results.title", value:"No Results", comment: "Title displayed when there are no results on Autofill search")
    public static func autofillSearchNoResultSubtitle(for query: String) -> String {
        let message = NSLocalizedString("autofill.logins.search.no-results.subtitle", value: "for '%@'", comment: "Subtitle displayed when there are no results on Autofill search, example : No Result (Title) for Duck (Subtitle)")
        return message.format(arguments: query)
    }
    
    public static let autofillEnableSettings = NSLocalizedString("autofill.logins.list.enable", value:"Save and Autofill Logins", comment: "Title for a toggle that enables autofill")
    public static let autofillLoginListTitle = NSLocalizedString("autofill.logins.list.title", value:"Autofill Logins", comment: "Title for screen listing autofill logins")
    public static let autofillLoginListSearchPlaceholder = NSLocalizedString("autofill.logins.list.search-placeholder", value:"Search Logins", comment: "Placeholder for search field on autofill login listing")
    
    public static let autofillLoginPromptAuthenticationCancelButton = NSLocalizedString("autofill.logins.prompt.auth.cancel", value:"Cancel", comment: "Cancel button for auth during login prompt")
    public static let autofillLoginPromptAuthenticationReason = NSLocalizedString("autofill.logins.prompt.auth.reason", value:"Unlock To Use Saved Login", comment: "Reason for auth during login prompt")
    public static let autofillLoginPromptTitle = NSLocalizedString("autofill.logins.prompt.title", value:"Use Saved Login?", comment: "Title for autofill login prompt")
    public static let autofillLoginPromptMoreOptions = NSLocalizedString("autofill.logins.prompt.more-options", value:"More Options", comment: "Button title for autofill login prompt if more options are available")

    public static let autofillNoAuthViewFaceIDTitle = NSLocalizedString("autofill.logins.no-auth.face-id.title", value:"Enable Face ID to use Autofill", comment: "Title for view displayed when autofill is locked on devices with faceID")
    public static let autofillNoAuthViewTouchIDTitle = NSLocalizedString("autofill.logins.no-auth.touch-id.title", value:"Enable Touch ID to use Autofill", comment: "Title for view displayed when autofill is locked on devices with touchID")
    public static let autofillNoAuthViewFaceIDSubtitle = NSLocalizedString("autofill.logins.no-auth.face-id.subtitle", value:"Face ID & Passcode are required to protect your Autofill Login details.", comment: "Title for view displayed when autofill is locked on devices with faceID")
    public static let autofillNoAuthViewTouchIDSubtitle = NSLocalizedString("autofill.logins.no-auth.touch-id.subtitle", value:"Touch ID & Passcode are required to protect your Autofill Login details.", comment: "Title for view displayed when autofill is locked on devices with touchID")
    public static let autofillNoAuthViewFaceIDButton = NSLocalizedString("autofill.logins.no-auth.face-id.button", value:"Set Up Face ID", comment: "Title for view displayed when autofill is locked on devices with faceID")
    public static let autofillNoAuthViewTouchIDButton = NSLocalizedString("autofill.logins.no-auth.touch-id.button", value:"Set Up Touch ID", comment: "Title for view displayed when autofill is locked on devices with touchID")

    public static let autofillOpenWebsitePrompt = NSLocalizedString("autofill.logins.details.open-website-prompt.title", value:"Open Website", comment: "Menu item title for option to open website from selected url")
    public static func autofillCopyPrompt(for type: String) -> String {
        let message = NSLocalizedString("autofill.logins.copy-prompt", value: "Copy %@", comment: "Menu item text for copying autofill login details")
        return message.format(arguments: type)
    }
    public static let autofillCopyToastUsernameCopied = NSLocalizedString("autofill.logins.copy-toast.username-copied", value:"Username copied", comment: "Title for toast when copying username")
    public static let autofillCopyToastPasswordCopied = NSLocalizedString("autofill.logins.copy-toast.password-copied", value:"Password copied", comment: "Title for toast when copying password")
    public static let autofillCopyToastAddressCopied = NSLocalizedString("autofill.logins.copy-toast.address-copied", value:"Address copied", comment: "Title for toast when copying address")
    public static let autofillCopyToastNotesCopied = NSLocalizedString("autofill.logins.copy-toast.notes-copied", value:"Notes copied", comment: "Title for toast when copying notes")

    public static func autofillLoginDetailsLastUpdated(for date: String) -> String {
        let message = NSLocalizedString("autofill.logins.details.last-updated", value: "Login last updated %@", comment: "Message displaying when the login was last updated by")
        return message.format(arguments: date)
    }
    public static let autofillLoginListAuthenticationCancelButton = NSLocalizedString("autofill.logins.list.auth.cancel", value:"Cancel", comment: "Cancel button for auth when opening login list")
    public static let autofillLoginListAuthenticationReason = NSLocalizedString("autofill.logins.list.auth.reason", value:"Unlock To Use Saved Login", comment: "Reason for auth when opening login list")
    public static let autofillLoginDetailsDefaultTitle = NSLocalizedString("autofill.logins.details.default-title", value:"Login", comment: "Title for autofill login details")
    public static let autofillLoginDetailsEditTitle = NSLocalizedString("autofill.logins.details.edit-title", value:"Edit Login", comment: "Title when editing autofill login details")
    public static let autofillLoginDetailsNewTitle = NSLocalizedString("autofill.logins.details.new-title", value:"Add Login", comment: "Title when adding new autofill login")
    public static let autofillLoginDetailsDeleteButton = NSLocalizedString("autofill.logins.details.delete", value:"Delete Login", comment: "Delete button when deleting an autofill login")
    public static let autofillLoginDetailsDeleteConfirmationTitle = NSLocalizedString("autofill.logins.details.delete-confirmation.title", value:"Are you sure you want to delete this Login?", comment: "Title of confirmation alert when deleting an autofill login")
    public static let autofillLoginDetailsDeleteConfirmationButtonTitle = NSLocalizedString("autofill.logins.details.delete-confirmation.button", value:"Delete Login", comment: "Autofill alert button confirming delete autofill login")

    public static func autofillLoginListLoginDeletedToastMessage(for title: String) -> String {
        let message = NSLocalizedString("autofill.logins.list.login-deleted-message", value: "Login for %@ deleted", comment: "Toast message when a login item is deleted")
        return message.format(arguments: title)
    }

    public static let autofillLoginDetailsEditTitlePlaceholder = NSLocalizedString("autofill.logins.details.edit.title-placeholder", value:"Title", comment: "Placeholder for title field on autofill login details")
    public static let autofillLoginDetailsEditUsernamePlaceholder = NSLocalizedString("autofill.logins.details.edit.username-placeholder", value:"username@example.com", comment: "Placeholder for userbane field on autofill login details")
    public static let autofillLoginDetailsEditPasswordPlaceholder = NSLocalizedString("autofill.logins.details.edit.password-placeholder", value:"Password", comment: "Placeholder for password field on autofill login details")
    public static let autofillLoginDetailsEditURLPlaceholder = NSLocalizedString("autofill.logins.details.edit.url-placeholder", value:"example.com", comment: "Placeholder for url field on autofill login details")

    public static let autofillLoginDetailsSaveDuplicateLoginAlertTitle = NSLocalizedString("autofill.logins.details.save-duplicate-alert.title", value:"Duplicated Login", comment: "Title for alert when attempting to save a duplicate login")
    public static let autofillLoginDetailsSaveDuplicateLoginAlertMessage = NSLocalizedString("autofill.logins.details.save-duplicate-alert.message", value:"You already have a login for this username and website.", comment: "Message for alert when attempting to save a duplicate login")
    public static let autofillLoginDetailsSaveDuplicateLoginAlertAction = NSLocalizedString("autofill.logins.details.save-duplicate-alert.action", value:"OK", comment: "Action text for alert when attempting to save a duplicate login")

    public static let autofillNavigationButtonItemTitleClose = NSLocalizedString("autofill.logins.list.close-title", value:"Close", comment: "Title for close navigation button")
}
