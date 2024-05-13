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
    
    public static let addressBarPositionTop = NSLocalizedString("address.bar.top", value: "Top", comment: "Settings label for top position for the address bar")
    public static let addressBarPositionBottom = NSLocalizedString("address.bar.bottom", value: "Bottom", comment: "Settings label for bottom position for the address bar")
    
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
    public static let actionDelete = NSLocalizedString("action.title.delete", value: "Delete", comment: "Delete action - button shown in alert")
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
    public static let actionOK = NSLocalizedString("action.ok", value: "OK", comment: "Button label for OK action")
    
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
    public static let messageProtectionDisabledAndToggleReportSent = NSLocalizedString("toast.protection.disabled.and.toggle.report.sent", value: "Privacy Protections disabled for %@ and report sent.", comment: "Confirmation of an action - populated with a domain name")

    public static let authAlertTitle = NSLocalizedString("auth.alert.title", value: "Authentication Required", comment: "Authentication Alert Title")
    public static let authAlertEncryptedConnectionMessage = NSLocalizedString("auth.alert.message.encrypted", value: "Sign in to %@. Your login information will be sent securely.", comment: "Authentication Alert - populated with a domain name")
    public static let authAlertPlainConnectionMessage = NSLocalizedString("auth.alert.message.plain", value: "Log in to %@. Your password will be sent insecurely because the connection is unencrypted.", comment: "Authentication Alert - populated with a domain name")
    public static let authAlertUsernamePlaceholder = NSLocalizedString("auth.alert.username.placeholder", value: "Username", comment: "Authentication User name field placeholder")
    public static let authAlertPasswordPlaceholder = NSLocalizedString("auth.alert.password.placeholder", value: "Password", comment: "Authentication Password field placeholder")
    public static let authAlertLogInButtonTitle = NSLocalizedString("auth.alert.login.button", value: "Sign In", comment: "Authentication Alert Sign In Button")
    
    public static let navigationTitleEdit = NSLocalizedString("navigation.title.edit", value: "Edit", comment: "Edit button")
    public static let navigationTitleDone = NSLocalizedString("navigation.title.done", value: "Done", comment: "Finish editing bookmarks button")
    
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
    
    public static let deleteBookmarkAlertTitle = NSLocalizedString("bookmark.delete.alert.title", value: "Delete?", comment: "Delete bookmark alert title")
    public static let deleteBookmarkAlertMessage = NSLocalizedString("bookmark.delete.alert.message", value: "This will delete your bookmark for \"%@\"", comment: "Delete bookmark alert message")
    public static let bookmarkDeleted = NSLocalizedString("bookmark.deleted.toast", value: "Bookmark deleted", comment: "The message shown after a bookmark has been deleted")
    
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
    
    public static let privacyIconShield = NSLocalizedString("privacy.icon.shield", value: "Privacy Icon", comment: "Privacy Icon accessibility title")
    public static let privacyIconDax = NSLocalizedString("privacy.icon.dax", value: "DuckDuckGo logo", comment: "Privacy Icon accessibility title")
    public static let privacyIconOpenDashboardHint = NSLocalizedString("privacy.icon.hint", value: "Tap to open Privacy Dashboard screen", comment: "Privacy Icon accessibility hint")
    
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
    
    public static let autoconsentEnabled = NSLocalizedString("autoconsent.enabled", value: "Enabled", comment: "Autoconsent for Cookie Management Setting state")
    public static let autoconsentDisabled = NSLocalizedString("autoconsent.disabled", value: "Disabled", comment: "Autoconsent for Cookie Management Setting state")
    public static let autoconsentInfoText = NSLocalizedString("autoconsent.info.header", value: "When DuckDuckGo detects cookie consent pop-ups on sites you visit, we can try to automatically set your cookie preferences to minimize cookies and maximize privacy, then close the pop-ups. Some sites don't provide an option to manage cookie preferences, so we can only hide pop-ups like these.", comment: "")
    
    public static let emailBrowsingMenuUseNewDuckAddress = NSLocalizedString("email.browsingMenu.useNewDuckAddress", value: "Generate Private Duck Address", comment: "Email option title in the browsing menu")
    public static let emailBrowsingMenuAlert = NSLocalizedString("email.browsingMenu.alert", value: "New address copied to your clipboard", comment: "Title for the email copy browsing menu alert")
    public static let emailAliasPromptTitle = NSLocalizedString("email.aliasAlert.prompt.title", value: "Select email address", comment: "Title for the email alias selection prompt")
    public static let emailAliasPromptUseUserAddressSubtitle = NSLocalizedString("email.aliasAlert.prompt.useUserAddress.subtitle", value: "Block email trackers", comment: "Subtitle for choosing primary user email address")
    public static let emailAliasPromptGeneratePrivateAddress = NSLocalizedString("email.aliasAlert.prompt.generatePrivateAddress", value: "Generate Private Duck Address", comment: "Option for generating a private email address")
    public static let emailAliasPromptGeneratePrivateAddressSubtitle = NSLocalizedString("email.aliasAlert.prompt.generatePrivateAddress.subtitle", value: "Block email trackers & hide address", comment: "Subtitle for generating a private email address")
    
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
    public static let noVoicePermissionAlertOKbutton = NSLocalizedString("voiceSearch.alert.no-permission.ok", value: "OK", comment: "OK button alert warning the user about missing microphone permission")
    public static let noVoicePermissionAlertMessage = NSLocalizedString("voiceSearch.alert.no-permission.message", value: "Please allow Microphone access in iOS System Settings for DuckDuckGo to use voice features.", comment: "Message for alert warning the user about missing microphone permission")
    public static let noVoicePermissionActionSettings = NSLocalizedString("voiceSearch.alert.no-permission.action.settings", value: "Settings", comment: "No microphone permission alert action button to open the settings app")
    public static let voiceSearchCancelButton = NSLocalizedString("voiceSearch.cancel", value: "Cancel", comment: "Cancel button for voice search")
    public static let voiceSearchFooterOld = NSLocalizedString("voiceSearch.footer.note.old", value: "Audio is processed on-device. It's not stored or shared with anyone, including DuckDuckGo.", comment: "Voice-search footer note with on-device privacy warning")
    public static let voiceSearchFooter = NSLocalizedString("voiceSearch.footer.note", value: "Add Private Voice Search option to the address bar. Audio is not stored or shared with anyone, including DuckDuckGo.", comment: "Voice-search footer note with on-device privacy warning")
    public static let textSizeDescription = NSLocalizedString("textSize.description", value: "Choose your preferred text size. Websites you view in DuckDuckGo will adjust to it.", comment: "Description text for the text size adjustment setting")
    public static func textSizeFooter(for percentage: String) -> String {
        let message = NSLocalizedString("textSize.footer", value: "Text Size - %@", comment: "Replacement string is a current percent value e.g. '120%'")
        return message.format(arguments: percentage)
    }
    
    public static let addWidget = NSLocalizedString("addWidget.button", value: "Add Widget", comment: "")
    public static let addWidgetTitle = NSLocalizedString("addWidget.title", value: "One tap to your favorite sites.", comment: "")
    public static let addWidgetDescription = NSLocalizedString("addWidget.description", value: "Get quick access to private search and the sites you love.", comment: "")
    public static let addWidgetSettingsFirstParagraph = NSLocalizedString("addWidget.settings.firstParagraph", value: "Long-press on the Home Screen to enter jiggle mode.", comment: "")
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
    
    public static let autofillSaveLoginTitleNewUser = NSLocalizedString("autofill.save-login.new-user.title", value: "Do you want DuckDuckGo to save your password?", comment: "Title displayed on modal asking for the user to save the login for the first time")
    public static let autofillSaveLoginTitle = NSLocalizedString("autofill.save-login.title", value: "Save Password?", comment: "Title displayed on modal asking for the user to save the login")
    public static let autofillUpdateUsernameTitle = NSLocalizedString("autofill.update-usernamr.title", value: "Update username?", comment: "Title displayed on modal asking for the user to update the username")

    public static let autofillSaveLoginMessageNewUser = NSLocalizedString("autofill.save-login.new-user.message", value: "Passwords are stored securely on your device.", comment: "Message displayed on modal asking for the user to save the login for the first time")
    public static let autofillSaveLoginNotNowCTA = NSLocalizedString("autofill.save-login.not-now.CTA", value: "Don’t Save", comment: "Cancel CTA displayed on modal asking for the user to save the login")
    public static let autofillSaveLoginNeverPromptCTA = NSLocalizedString("autofill.save-login.never-prompt.CTA", value:"Never Ask for This Site", comment: "CTA displayed on modal asking if the user never wants to be prompted to save a login for this website agin")
    
    public static func autofillUpdatePassword(for title: String) -> String {
        let message = NSLocalizedString("autofill.update-password.title", value: "Update password for\n%@?", comment: "Title displayed on modal asking for the user to update the password")
        return message.format(arguments: title)
    }
    public static let autoUpdatePasswordMessage = NSLocalizedString("autofill.update-password.message", value: "DuckDuckGo will update this stored password on your device.", comment: "Message displayed on modal asking for the user to update the password")
    
    public static let autofillSavePasswordSaveCTA = NSLocalizedString("autofill.save-password.save.CTA", value: "Save Password", comment: "Confirm CTA displayed on modal asking for the user to save the password")
    public static let autofillUpdatePasswordSaveCTA = NSLocalizedString("autofill.update-password.save.CTA", value: "Update Password", comment: "Confirm CTA displayed on modal asking for the user to update the password")
    public static let autofillShowPassword = NSLocalizedString("autofill.show-password", value: "Show Password", comment: "Accessibility title for a Show Password button displaying actial password instead of *****")
    public static let autofillHidePassword = NSLocalizedString("autofill.hide-password", value: "Hide Password", comment: "Accessibility title for a Hide Password button replacing displayed password with *****")
    public static let autofillUpdateUsernameSaveCTA = NSLocalizedString("autofill.update-username.save.CTA", value: "Update Username", comment: "Confirm CTA displayed on modal asking for the user to update the login")
    public static let autofillLoginSavedToastMessage = NSLocalizedString("autofill.login-saved.toast", value: "Password saved", comment: "Message displayed after saving an autofill login")
    public static let autofillLoginUpdatedToastMessage = NSLocalizedString("autofill.login-updated.toast", value: "Password updated", comment: "Message displayed after updating an autofill login")
    public static let autofillLoginSaveToastActionButton = NSLocalizedString("autofill.login-save-action-button.toast", value: "View", comment: "Button displayed after saving/updating an autofill login that takes the user to the saved login")

    public static let autofillKeepEnabledAlertTitle = NSLocalizedString("autofill.keep-enabled.alert.title", value: "Do you want to keep saving passwords?", comment: "Title for alert when asking the user if they want to keep using autofill")
    public static let autofillKeepEnabledAlertMessage = NSLocalizedString("autofill.keep-enabled.alert.message", value: "You can disable this at any time in Settings.", comment: "Message for alert when asking the user if they want to keep using autofill")
    public static let autofillKeepEnabledAlertKeepUsingAction = NSLocalizedString("autofill.keep-enabled.alert.keep-using", value: "Keep Saving", comment: "Confirm action for alert when asking the user if they want to keep using autofill")
    public static let autofillKeepEnabledAlertDisableAction = NSLocalizedString("autofill.keep-enabled.alert.disable", value: "Disable", comment: "Disable action for alert when asking the user if they want to keep using autofill")

    public static let actionAutofillLogins = NSLocalizedString("action.title.autofill.logins", value: "Passwords", comment: "Autofill Logins menu item opening the login list")

    // MARK: - Waitlist
    
    public static let waitlistPrivacyDisclaimer = NSLocalizedString("waitlist.privacy-disclaimer",
                                                                    value: "You won’t need to share any personal information to join the waitlist. You’ll secure your place in line with a timestamp that exists solely on your device so we can notify you when it’s your turn.",
                                                                    comment: "Privacy disclaimer for the Waitlist feature")
    public static let waitlistInviteCode = NSLocalizedString("waitlist.invite-code", value: "Invite Code", comment: "Label text for the invite code")
    public static let waitlistShareLink = NSLocalizedString("waitlist.join-waitlist-screen.share-link", value: "Share Link", comment: "Title for the Share Link button")
    public static let waitlistCopy = NSLocalizedString("waitlist.copy", value: "Copy", comment: "Title for the copy action")
    public static let waitlistNotifyMe = NSLocalizedString("waitlist.joined.no-notification.get-notification", value: "Notify Me", comment: "Notification text for the waitlist")
    public static let waitlistNotifyMeConfirmationTitle = NSLocalizedString("waitlist.joined.no-notification.get-notification-confirmation-title", value: "Get a notification when it’s your turn?", comment: "Title for the alert to confirm enabling notifications")
    public static let waitlistNoThanks = NSLocalizedString("waitlist.joined.no-notification.no-thanks", value: "No Thanks", comment: "Cancel button in the alert to confirm enabling notifications")
    public static let waitlistNotificationDisabled = NSLocalizedString("waitlist.notification.disabled", value: "We can notify you when it’s your turn, but notifications are currently disabled for DuckDuckGo.", comment: "Text used for the Notifications Disabled state")
    public static let waitlistJoin = NSLocalizedString("waitlist.join-waitlist-screen.join", value: "Join the Private Waitlist", comment: "Title for the Join Waitlist screen")
    public static let waitlistJoining = NSLocalizedString("waitlist.join-waitlist-screen.joining", value: "Joining Waitlist...", comment: "Temporary status text for the Join Waitlist screen")
    public static let waitlistAllowNotifications = NSLocalizedString("waitlist.allow-notifications", value: "Allow Notifications", comment: "Title for the button to enable push notifications in system settings")
    public static let waitlistAvailableNotificationBody = NSLocalizedString("waitlist.available.notification.body", value: "Open your invite", comment: "Body text for the waitlist notification")
    public static let waitlistOnTheList = NSLocalizedString("waitlist.queue-screen.on-the-list", value: "You’re on the list!", comment: "Title for the queue screen")
    public static let waitlistYoureInvited = NSLocalizedString("waitlist.invite-screen.youre-invited", value: "You’re Invited!", comment: "Title for the invite code screen")
    public static let waitlistDownloadAvailable = NSLocalizedString("waitlist.settings.download-available", value: "Download available", comment: "Title for the settings subtitle")
    public static func waitlistInviteScreenStepTitle(step: Int) -> String {
        NSLocalizedString("waitlist.invite-screen.step.title", value: "Step %d", comment: "Step title on the invite screen").format(arguments: step)
    }
    public static let waitlistShareSheetTitle = NSLocalizedString("waitlist.share-sheet.title", value: "You’re Invited!", comment: "Title for the share sheet entry")
    
    // MARK: - Mac Waitlist
    
    public static let macBrowserTitle = NSLocalizedString("mac-waitlist.title", value: "DuckDuckGo App for Mac", comment: "Title for the Mac Waitlist feature")
    public static let macWaitlistSummary = NSLocalizedString("mac-browser.waitlist.summary", value: "DuckDuckGo for Mac has the speed you need, the browsing features you expect, and comes packed with our best-in-class privacy essentials.", comment: "Summary text for the macOS browser waitlist")
    public static let macWaitlistTryDuckDuckGoForMac = NSLocalizedString("mac-waitlist.join-waitlist-screen.try-duckduckgo-for-mac", value: "Get DuckDuckGo for Mac!", comment: "Title for the Join Waitlist screen")
    public static let macWaitlistOnYourMacGoTo = NSLocalizedString("mac-waitlist.join-waitlist-screen.on-your-mac-go-to", value: "On your Mac, go to:", comment: "Description text above the Share Link button")
    public static let macWaitlistWindows = NSLocalizedString("mac-waitlist.join-waitlist-screen.windows-waitlist", value: "Looking for the Windows version?", comment: "Title for the macOS waitlist button redirecting to Windows waitlist")
    public static let macWaitlistCopy = NSLocalizedString("mac-waitlist.copy", value: "Copy", comment: "Title for the copy action")
    public static let macWaitlistShareLink = NSLocalizedString("mac-waitlist.join-waitlist-screen.share-link", value: "Share Link", comment: "Title for the Share Link button")
    
    // MARK: - Windows Waitlist
    
    public static let windowsWaitlistTitle = NSLocalizedString("windows-waitlist.title", value: "DuckDuckGo App for Windows", comment: "Title for the Windows Waitlist feature")
    public static let windowsWaitlistSummary = NSLocalizedString("windows-waitlist.summary", value: "DuckDuckGo for Windows has what you need to browse with more privacy — private search, tracker blocking, forced encryption, and cookie pop-up blocking, plus more best-in-class protections on the way.", comment: "Summary text for the Windows browser waitlist")
    public static let windowsWaitlistOnYourComputerGoTo = NSLocalizedString("mac-waitlist.join-waitlist-screen.on-your-computer-go-to", value: "On your Windows computer, go to:", comment: "Description text above the Share Link button")
    public static let windowsWaitlistTryDuckDuckGoForWindowsDownload = NSLocalizedString("windows-waitlist.waitlist-download-screen.try-duckduckgo-for-windows", value: "Get DuckDuckGo for Windows!", comment: "Title for the Windows browser download link page")
        public static let windowsWaitlistMac = NSLocalizedString("windows-waitlist.join-waitlist-screen.mac-waitlist", value: "Looking for the Mac version?", comment: "Title for the Windows waitlist button redirecting to Mac waitlist")
    public static let windowsWaitlistBrowsePrivately = NSLocalizedString("windows-waitlist.settings.browse-privately", value: "Browse privately with our app for Windows", comment: "Title for the settings subtitle")

    //MARK: - Get Desktop Browser
    public static let getBrowserTitle = NSLocalizedString("get.browser.title", value: "Get DuckDuckGo for Mac or Windows", comment: "Title for the get desktop browser feature")
    public static let getBrowserOnYourDesktopGoTo = NSLocalizedString("get.browser.on-your-desktop-go-to", value: "On your computer, go to:", comment: "Description text above the Share Link button")
    public static let getBrowserShareLink = NSLocalizedString("get.browser.share-link", value: "Share Download Link", comment: "Title for the Share Download Link button")
    public static let getBrowserShareLinkTitle = NSLocalizedString("get.browser.share-link.title", value: "Get DuckDuckGo Browser for Mac or Windows", comment: "Title displayed in the share action")
    public static let getBrowserShareLinkMessage = NSLocalizedString("get.browser.share-link.message", value: "Search privately and block trackers with the DuckDuckGo desktop browser. Visit this link on your computer to download today.", comment: "Message displayed in the share action when sharing via email")

    // MARK: Network Protection
    
    public static let netPSettingsTitle = NSLocalizedString("netP.settings.title", value: "VPN", comment: "Title for the DuckDuckGo VPN feature in settings")
    public static let netPNavTitle = NSLocalizedString("netP.title", value: "DuckDuckGo VPN", comment: "Title for the DuckDuckGo VPN feature")
    public static let netPCellConnected = NSLocalizedString("netP.cell.connected", value: "Connected", comment: "String indicating NetP is connected when viewed from the settings screen")
    public static let netPCellDisconnected = NSLocalizedString("netP.cell.disconnected", value: "Not connected", comment: "String indicating NetP is disconnected when viewed from the settings screen")
    
    static let netPInviteTitle = NSLocalizedString("network.protection.invite.dialog.title", value: "You’re invited to try DuckDuckGo VPN", comment: "Title for the network protection invite screen")
    static let netPInviteMessage = NSLocalizedString("network.protection.invite.dialog.message", value: "Enter your invite code to get started.", comment: "Message for the network protection invite dialog")
    static let netPInviteFieldPrompt = NSLocalizedString("network.protection.invite.field.prompt", value: "Invite Code", comment: "Prompt for the network protection invite code text field")
    static let netPInviteSuccessTitle = NSLocalizedString("network.protection.invite.success.title", value: "Success! You’re in.", comment: "Title for the network protection invite success view")
    static let netPInviteSuccessMessage = NSLocalizedString("network.protection.invite.success.message", value: "Hide your location from websites and conceal your online activity from Internet providers and others on your network.", comment: "Message for the network protection invite success view")
    
    static let netPStatusViewTitle = NSLocalizedString("network.protection.status.view.title", value: "VPN", comment: "Title label text for the status view when netP is disconnected")
    static let netPStatusHeaderTitleOff = NSLocalizedString("network.protection.status.header.title.off", value: "DuckDuckGo VPN is Off", comment: "Header title label text for the status view when VPN is disconnected")
    static let netPStatusHeaderTitleOn = NSLocalizedString("network.protection.status.header.title.on", value: "DuckDuckGo VPN is On", comment: "Header title label text for the status view when VPN is connected")
    static let netPStatusHeaderMessageOff = NSLocalizedString("network.protection.status.header.message.off", value: "Connect to secure all of your device’s\nInternet traffic.", comment: "Message label text for the status view when VPN is disconnected")
    static let netPStatusHeaderMessageOn = NSLocalizedString("network.protection.status.header.message.on", value: "All device Internet traffic is being secured\nthrough the VPN.", comment: "Message label text for the status view when VPN is disconnected")
    static let netPStatusDisconnected = NSLocalizedString("network.protection.status.disconnected", value: "Not connected", comment: "The label for the NetP VPN when disconnected")
    static let netPStatusDisconnecting = NSLocalizedString("network.protection.status.disconnecting", value: "Disconnecting...", comment: "The label for the NetP VPN when disconnecting")
    static let netPStatusConnecting = NSLocalizedString("network.protection.status.connecting", value: "Connecting...", comment: "The label for the NetP VPN when connecting")
    static func netPStatusConnected(since timeLapsedString: String) -> String {
        let localized = NSLocalizedString("network.protection.status.connected.format", value: "Connected · %@", comment: "The label for when NetP VPN is connected plus the length of time connected as a formatter HH:MM:SS string")
        return String(format: localized, timeLapsedString)
    }
    static let netPStatusViewLocation = NSLocalizedString("network.protection.status.view.location", value: "Location", comment: "Location label shown in NetworkProtection's status view.")
    static let netPStatusViewIPAddress = NSLocalizedString("network.protection.status.view.ip.address", value: "IP Address", comment: "IP Address label shown in NetworkProtection's status view.")
    static let netPStatusViewConnectionDetails = NSLocalizedString("network.protection.status.view.connection.details", value: "Connection Details", comment: "Connection details label shown in NetworkProtection's status view.")
    static let netPStatusViewSettingsSectionTitle = NSLocalizedString("network.protection.status.view.settings.section.title", value: "Manage", comment: "Label shown on the title of the settings section in NetworkProtection's status view.")
    static let netPVPNSettingsTitle = NSLocalizedString("network.protection.vpn.settings.title", value: "VPN Settings", comment: "Title for the VPN Settings screen.")
    static let netPVPNSettingsFAQ = NSLocalizedString("network.protection.vpn.settings.faq", value: "Frequently Asked Questions", comment: "Title for the FAQ row in the VPN status screen.")
    static let netPVPNSettingsShareFeedback = NSLocalizedString("network.protection.vpn.settings.share-feedback", value: "Share VPN Feedback", comment: "Title for the feedback row in the VPN status screen.")
    static func netPVPNSettingsLocationSubtitleFormattedCityAndCountry(city: String, country: String) -> String {
        let localized = NSLocalizedString("network.protection.vpn.location.subtitle.formatted.city.and.country", value: "%@, %@", comment: "Subtitle for the preferred location item that formats a city and country. E.g Chicago, United States")
        return localized.format(arguments: city, country)
    }
    static let netPVPNNotificationsTitle = NSLocalizedString("network.protection.vpn.notifications.title", value: "VPN Notifications", comment: "Title for the VPN Notifications management screen.")
    static let netPStatusViewShareFeedback = NSLocalizedString("network.protection.status.menu.share.feedback", value: "Share Feedback", comment: "The status view 'Share Feedback' button which is shown inline on the status view after the temporary free use footer text")
    static let netPStatusViewErrorConnectionFailedTitle = NSLocalizedString("network.protection.status.view.error.connection.failed.title", value: "Failed to Connect.", comment: "Generic connection failed error title shown in NetworkProtection's status view.")
    static let netPStatusViewErrorConnectionFailedMessage = NSLocalizedString("network.protection.status.view.error.connection.failed.message", value: "Please try again later.", comment: "Generic connection failed error message shown in NetworkProtection's status view.")
    static let netPPreferredLocationSettingTitle = NSLocalizedString("network.protection.vpn.preferred.location.title", value: "Preferred Location", comment: "Title for the Preferred Location VPN Settings item.")
    static let netPPreferredLocationNearest = NSLocalizedString("network.protection.vpn.preferred.location.nearest", value: "Nearest Location", comment: "Label for the Preferred Location VPN Settings item when the nearest available location is selected.")
    static let netPVPNLocationTitle = NSLocalizedString("network.protection.vpn.location.title", value: "VPN Location", comment: "Title for the VPN Location screen.")
    static let netPVPNLocationRecommendedSectionTitle = NSLocalizedString("network.protection.vpn.location.recommended.section.title", value: "Recommended", comment: "Title for the VPN Location screen's Recommended section.")
    static let netPVPNLocationRecommendedSectionFooter = NSLocalizedString("network.protection.vpn.location.recommended.section.footer", value: "Automatically connect to the nearest server we can find.", comment: "Footer describing the VPN Location screen's Recommended section which just has Nearest Available.")
    static let netPVPNLocationAllCountriesSectionTitle = NSLocalizedString("network.protection.vpn.location.all.countries.section.title", value: "All Countries", comment: "Title for the VPN Location screen's All Countries section.")
    static func netPVPNLocationCountryItemFormattedCitiesCount(_ count: Int) -> String {
        let message = NSLocalizedString("network.protection.vpn.location.country.item.formatted.cities.count", value: "%d cities", comment: "Subtitle of countries item when there are multiple cities, example : ")
        return message.format(arguments: count)
    }
    static let netPVPNLocationNearest = NSLocalizedString("network.protection.vpn.location.nearest", value: "(Nearest)", comment: "Description of the location type in the VPN status screen")
    static let vpnLocationConnected = NSLocalizedString("network.protection.vpn.location.connected", value: "Connected Location", comment: "Description of the location type in the VPN status screen")
    static let vpnLocationSelected = NSLocalizedString("network.protection.vpn.location.selected", value: "Selected Location", comment: "Description of the location type in the VPN status screen")
    static let vpnDataVolume = NSLocalizedString("network.protection.vpn.data-volume", value: "Data Volume", comment: "Title for the data volume section in the VPN status screen")
    static let vpnAbout = NSLocalizedString("network.protection.vpn.about", value: "About", comment: "Title of the About section in the VPN status screen")
    static let netPExcludeLocalNetworksSettingTitle = NSLocalizedString("network.protection.vpn.exclude.local.networks.setting.title", value: "Exclude Local Networks", comment: "Title for the Exclude Local Networks setting item.")
    static let netPExcludeLocalNetworksSettingFooter = NSLocalizedString("network.protection.vpn.exclude.local.networks.setting.footer", value: "Let local traffic bypass the VPN and connect to devices on your local network, like a printer.", comment: "Footer text for the Exclude Local Networks setting item.")
    static let netPSecureDNSSettingFooter = NSLocalizedString("network.protection.vpn.secure.dns.setting.footer", value: "Our VPN uses Secure DNS to keep your online activity private, so that your Internet provider can't see what websites you visit.", comment: "Footer text for the Always on VPN setting item.")
    static let netPTurnOnNotificationsButtonTitle = NSLocalizedString("network.protection.turn.on.notifications.button.title", value: "Turn On Notifications", comment: "Title for the button to link to the iOS app settings and enable notifications app-wide.")
    static let netPTurnOnNotificationsSectionFooter = NSLocalizedString("network.protection.turn.on.notifications.section.footer", value: "Allow DuckDuckGo to notify you if your connection drops or VPN status changes.", comment: "Footer text under the button to link to the iOS app settings and enable notifications app-wide.")
    static let netPVPNAlertsToggleTitle = NSLocalizedString("network.protection.vpn.alerts.toggle.title", value: "VPN Alerts", comment: "Title for the toggle for VPN alerts.")
    static let netPVPNAlertsToggleSectionFooter = NSLocalizedString("network.protection.vpn.alerts.toggle.section.footer", value: "Get notified if your connection drops or VPN status changes.", comment: "List section footer for the toggle for VPN alerts.")
    static let netPFrequentlyAskedQuestionsTitle = NSLocalizedString("network.protection.faq.title", value: "DuckDuckGo VPN FAQ", comment: "Title for the VPN FAQ screen.")

    static let netPOpenVPNQuickAction = NSLocalizedString("network.protection.quick-action.open-vpn", value: "Open VPN", comment: "Title text for an iOS quick action that opens VPN settings")
    
    static let inviteDialogContinueButton = NSLocalizedString("invite.dialog.continue.button", value: "Continue", comment: "Continue button on an invite dialog")
    static let inviteDialogGetStartedButton = NSLocalizedString("invite.dialog.get.started.button", value: "Get Started", comment: "Get Started button on an invite dialog")
    static let inviteDialogUnrecognizedCodeMessage = NSLocalizedString("invite.dialog.unrecognized.code.message", value: "We didn’t recognize this Invite Code.", comment: "Message to show after user enters an unrecognized invite code")
    static let inviteDialogErrorAlertOKButton = NSLocalizedString("invite.alert.ok.button", value: "OK", comment: "OK title for invite screen alert dismissal button")

    // MARK: - Feedback Form
    static let vpnFeedbackFormTitle = NSLocalizedString("vpn.feedback-form.title", value: "Help Improve the DuckDuckGo VPN", comment: "Title for each screen of the VPN feedback form")
    static let vpnFeedbackFormCategorySelect = NSLocalizedString("vpn.feedback-form.category.select-category", value: "Select a category", comment: "Title for the category selection state of the VPN feedback form")
    static let vpnFeedbackFormCategoryUnableToInstall = NSLocalizedString("vpn.feedback-form.category.unable-to-install", value: "Unable to install VPN", comment: "Title for the 'unable to install' category of the VPN feedback form")
    static let vpnFeedbackFormCategoryFailsToConnect = NSLocalizedString("vpn.feedback-form.category.fails-to-connect", value: "VPN fails to connect", comment: "Title for the 'VPN fails to connect' category of the VPN feedback form")
    static let vpnFeedbackFormCategoryTooSlow = NSLocalizedString("vpn.feedback-form.category.too-slow", value: "VPN connection is too slow", comment: "Title for the 'VPN is too slow' category of the VPN feedback form")
    static let vpnFeedbackFormCategoryIssuesWithApps = NSLocalizedString("vpn.feedback-form.category.issues-with-apps", value: "VPN causes issues with other apps or websites", comment: "Title for the category 'VPN causes issues with other apps or websites' category of the VPN feedback form")
    static let vpnFeedbackFormCategoryLocalDeviceConnectivity = NSLocalizedString("vpn.feedback-form.category.local-device-connectivity", value: "VPN won't let me connect to local device", comment: "Title for the local device connectivity category of the VPN feedback form")
    static let vpnFeedbackFormCategoryBrowserCrashOrFreeze = NSLocalizedString("vpn.feedback-form.category.browser-crash-or-freeze", value: "VPN causes browser to crash or freeze", comment: "Title for the browser crash/freeze category of the VPN feedback form")
    static let vpnFeedbackFormCategoryFeatureRequest = NSLocalizedString("vpn.feedback-form.category.feature-request", value: "VPN feature request", comment: "Title for the 'VPN feature request' category of the VPN feedback form")
    static let vpnFeedbackFormCategoryOther = NSLocalizedString("vpn.feedback-form.category.other", value: "Other VPN feedback", comment: "Title for the 'other VPN feedback' category of the VPN feedback form")

    static let vpnFeedbackFormText1 = NSLocalizedString("vpn.feedback-form.text-1", value: "Please describe what's happening, what you expected to happen, and the steps that led to the issue:", comment: "Text for the body of the VPN feedback form")
    static let vpnFeedbackFormText2 = NSLocalizedString("vpn.feedback-form.text-2", value: "In addition to the details entered into this form, your app issue report will contain:", comment: "Text for the body of the VPN feedback form")
    static let vpnFeedbackFormText3 = NSLocalizedString("vpn.feedback-form.text-3", value: "• Whether specific DuckDuckGo features are enabled", comment: "Bullet text for the body of the VPN feedback form")
    static let vpnFeedbackFormText4 = NSLocalizedString("vpn.feedback-form.text-4", value: "• Aggregate DuckDuckGo app diagnostics", comment: "Bullet text for the body of the VPN feedback form")
    static let vpnFeedbackFormText5 = NSLocalizedString("vpn.feedback-form.text-5", value: "By tapping \"Submit\" I agree that DuckDuckGo may use the information in this report for purposes of improving the app's features.", comment: "Text for the body of the VPN feedback form")

    static let vpnFeedbackFormSendingConfirmationTitle = NSLocalizedString("vpn.feedback-form.sending-confirmation.title", value: "Thank you!", comment: "Title for the feedback sent view title of the VPN feedback form")
    static let vpnFeedbackFormSendingConfirmationDescription = NSLocalizedString("vpn.feedback-form.sending-confirmation.description", value: "Your feedback will help us improve the\nDuckDuckGo VPN.", comment: "Title for the feedback sent view description of the VPN feedback form")
    static let vpnFeedbackFormSendingConfirmationError = NSLocalizedString("vpn.feedback-form.sending-confirmation.error", value: "We couldn't send your feedback right now, please try again.", comment: "Title for the feedback sending error text of the VPN feedback form")

    static let vpnFeedbackFormButtonDone = NSLocalizedString("vpn.feedback-form.button.done", value: "Done", comment: "Title for the Done button of the VPN feedback form")
    static let vpnFeedbackFormButtonCancel = NSLocalizedString("vpn.feedback-form.button.cancel", value: "Cancel", comment: "Title for the Cancel button of the VPN feedback form")
    static let vpnFeedbackFormButtonSubmit = NSLocalizedString("vpn.feedback-form.button.submit", value: "Submit", comment: "Title for the Submit button of the VPN feedback form")
    static let vpnFeedbackFormButtonSubmitting = NSLocalizedString("vpn.feedback-form.button.submitting", value: "Submitting…", comment: "Title for the Submitting state of the VPN feedback form")

    static let vpnFeedbackFormSubmittedMessage = NSLocalizedString("vpn.feedback-form.submitted.message", value: "Thank You! Feedback submitted.", comment: "Toast message when the VPN feedback form is submitted successfully")

    static let vpnAccessRevokedAlertTitle = NSLocalizedString("vpn.access-revoked.alert.title", value: "VPN disconnected due to expired subscription", comment: "Alert title for the alert when the Privacy Pro subscription expires")
    static let vpnAccessRevokedAlertMessage = NSLocalizedString("vpn.access-revoked.alert.message", value: "Subscribe to Privacy Pro to reconnect DuckDuckGo VPN.", comment: "Alert message for the alert when the Privacy Pro subscription expiress")
    static let vpnAccessRevokedAlertActionSubscribe = NSLocalizedString("vpn.access-revoked.alert.action.subscribe", value: "Subscribe", comment: "Primary action for the alert when the subscription expires")
    static let vpnAccessRevokedAlertActionCancel = NSLocalizedString("vpn.access-revoked.alert.action.cancel", value: "Dismiss", comment: "Cancel action for the alert when the subscription expires")

    // MARK: VPN Widget

    public static let vpnSettingsAddWidget = NSLocalizedString("vpn.settings.add.widget", value: "Add VPN Widget to Home Screen", comment: "VPN settings screen cell text for adding the VPN widget to the home screen")
    public static let addVPNWidgetSettingsThirdParagraph = NSLocalizedString("vpn.addWidget.settings.title", value: "Find and select DuckDuckGo. Then swipe to VPN and select Add Widget.", comment: "Title for the VPN widget onboarding screen")

    // MARK: Notifications
    
    public static let macWaitlistAvailableNotificationTitle = NSLocalizedString("mac-waitlist.available.notification.title", value: "DuckDuckGo for Mac is ready!", comment: "Title for the macOS waitlist notification")
    
    // MARK: Settings Screen
    
    public static let emailSettingsSubtitle = NSLocalizedString("email.settings.subtitle", value: "Block email trackers and hide your address", comment: "Subtitle for the email settings cell")
    public static let macWaitlistBrowsePrivately = NSLocalizedString("mac-waitlist.settings.browse-privately", value: "Browse privately with our app for Mac", comment: "Title for the settings subtitle")
    public static let favoritesDisplayPreferencesHeader = NSLocalizedString("favorites.settings.header", value: "Display Preferences", comment: "Header of the favorites settings table")
    public static let favoritesDisplayPreferencesFooter = NSLocalizedString("favorites.settings.footer", value: "Choose which favorites to display on a new tab based on their origin.", comment: "Footer of the favorites settings table")
    public static let favoritesDisplayPreferencesMobileOnly = NSLocalizedString("favorites.settings.mobile-only", value: "Mobile Favorites Only", comment: "Display Mode for favorites")
    public static let favoritesDisplayPreferencesAllDevices = NSLocalizedString("favorites.settings.all-devices", value: "All Device Favorites", comment: "Display Mode for favorites")
    
    // MARK: Share Sheet
    
    public static let macWaitlistShareSheetTitle = NSLocalizedString("mac-waitlist.share-sheet.title", value: "DuckDuckGo for Mac", comment: "Title for the share sheet entry")
    public static let macWaitlistShareSheetMessage = NSLocalizedString("mac-waitlist.share-sheet.message", value: """
        Ready to start browsing privately on Mac?
        
        Visit this URL on your Mac to download:
        https://duckduckgo.com/mac
        """, comment: "Message used when sharing to iMessage")
    public static let windowsWaitlistDownloadLinkShareSheetMessage = NSLocalizedString("windows-waitlist.share-sheet.message", value: """
        Ready to start browsing privately on Windows?
        
        Visit this URL on your Computer to download:
        https://duckduckgo.com/windows
        """, comment: "Message used when sharing to iMessage")
    
    // MARK: Autofill

    public static let autofillLoginDetailsLoginName = NSLocalizedString("autofill.logins.details.login-name", value:"Title", comment: "Login name label for login details on autofill")
    public static let autofillLoginDetailsUsername = NSLocalizedString("autofill.logins.details.username", value:"Username", comment: "Username label for login details on autofill")
    public static let autofillLoginDetailsPassword = NSLocalizedString("autofill.logins.details.password", value:"Password", comment: "Password label for login details on autofill")
    
    public static let autofillLoginDetailsAddress = NSLocalizedString("autofill.logins.details.address", value:"Website URL", comment: "Address label for login details on autofill")
    public static let autofillLoginDetailsNotes = NSLocalizedString("autofill.logins.details.notes", value:"Notes", comment: "Notes label for login details on autofill")
    public static let autofillEmptyViewTitle = NSLocalizedString("autofill.logins.empty-view.title", value:"No passwords saved yet", comment: "Title for view displayed when autofill has no items")
    public static let autofillEmptyViewSubtitle = NSLocalizedString("autofill.logins.empty-view.subtitle", value:"Passwords from other browsers or apps can be imported using the desktop version of the DuckDuckGo browser.", comment: "Subtitle for view displayed when no autofill passwords have been saved")
    public static let autofillEmptyViewButtonTitle = NSLocalizedString("autofill.logins.empty-view.button.title", value:"Import Passwords", comment: "Title for button to Import Passwords when autofill has no items")

    public static let autofillSearchNoResultTitle = NSLocalizedString("autofill.logins.search.no-results.title", value:"No Results", comment: "Title displayed when there are no results on Autofill search")
    public static func autofillSearchNoResultSubtitle(for query: String) -> String {
        let message = NSLocalizedString("autofill.logins.search.no-results.subtitle", value: "for '%@'", comment: "Subtitle displayed when there are no results on Autofill search, example : No Result (Title) for Duck (Subtitle)")
        return message.format(arguments: query)
    }
    
    public static let aboutText = NSLocalizedString("settings.about.text", value: """
DuckDuckGo is the independent Internet privacy company founded in 2008 for anyone who’s tired of being tracked online and wants an easy solution. We’re proof you can get real privacy protection online without tradeoffs.

The DuckDuckGo browser comes with the features you expect from a go-to browser, like bookmarks, tabs, passwords, and more, plus over [a dozen powerful privacy protections](ddgQuickLink://duckduckgo.com/duckduckgo-help-pages/privacy/web-tracking-protections/) not offered in most popular browsers by default. This uniquely comprehensive set of privacy protections helps protect your online activities, from searching to browsing, emailing, and more.

Our privacy protections work without having to know anything about the technical details or deal with complicated settings. All you have to do is switch your browser to DuckDuckGo across all your devices and you get privacy by default.

But if you *do* want a peek under the hood, you can find more information about how DuckDuckGo privacy protections work on our [help pages](ddgQuickLink://duckduckgo.com/duckduckgo-help-pages/).
""", comment: "about page")

    public static let autofillEnableSettings = NSLocalizedString("autofill.logins.list.enable", value:"Save and autofill passwords", comment: "Title for a toggle that enables autofill")
    public static let autofillNeverSavedSettings = NSLocalizedString("autofill.logins.list.never.saved", value:"Reset Excluded Sites", comment: "Title for a button that allows a user to reset their list of never saved sites")
    public static let autofillSettingsFooter = NSLocalizedString("autofill.logins.list.enable.footer", value:"Passwords are stored securely on your device.", comment: "Footer label displayed below table section with option to enable autofill")
    public static let autofillLoginListTitle = NSLocalizedString("autofill.logins.list.title", value:"Passwords", comment: "Title for screen listing autofill logins")
    public static let autofillLoginListSearchPlaceholder = NSLocalizedString("autofill.logins.list.search-placeholder", value:"Search passwords", comment: "Placeholder for search field on autofill login listing")
    public static let autofillLoginListSuggested = NSLocalizedString("autofill.logins.list.suggested", value:"Suggested", comment: "Section title for group of suggested saved logins")

    public static let autofillResetNeverSavedActionTitle = NSLocalizedString("autofill.logins.list.never.saved.reset.action.title", value:"If you reset excluded sites, you will be prompted to save your password next time you sign in to any of these sites.", comment: "Alert title")
    public static let autofillResetNeverSavedActionConfirmButton = NSLocalizedString("autofill.logins.list.never.saved.reset.action.confirm", value: "Reset Excluded Sites", comment: "Confirm button to reset list of never saved sites")
    public static let autofillResetNeverSavedActionCancelButton = NSLocalizedString("autofill.logins.list.never.saved.reset.action.cancel", value: "Cancel", comment: "Cancel button for resetting list of never saved sites")
    
    public static let autofillLoginListToolbarDeleteAllButton = NSLocalizedString("autofill.logins.list.delete.all", value:"Delete All", comment: "Title for button to delete all saved autofill passwords")
    public static func autofillLoginListToolbarPasswordsCount(_ count: Int) -> String {
        let message = NSLocalizedString("autofill.number.of.passwords", comment: "Do not translate - stringsdict entry")
        return message.format(arguments: count)
    }
    public static func autofillDeleteAllPasswordsActionTitle(for count: Int) -> String {
        let message = NSLocalizedString("autofill.delete.all.passwords.confirmation.title", comment: "Do not translate - stringsdict entry")
        return message.format(arguments: count)
    }
    public static func autofillDeleteAllPasswordsActionMessage(for count: Int) -> String {
        let message = NSLocalizedString("autofill.delete.all.passwords.confirmation.body", comment: "Do not translate - stringsdict entry")
        return message.format(arguments: count, count)
    }
    public static func autofillDeleteAllPasswordsSyncActionMessage(for count: Int) -> String {
        let message = NSLocalizedString("autofill.delete.all.passwords.sync.confirmation.body", comment: "Do not translate - stringsdict entry")
        return message.format(arguments: count, count)
    }

    public static let autofillDeleteAllPasswordsAuthenticationPromptTitle = NSLocalizedString("autofill.logins.delete.all.authentication.prompt.title", value: "Authenticate To Delete All Passwords", comment: "Title of prompt requiring authentication before all passwords are deleted")
    public static let autofillDeleteAllPasswordsAuthenticationPromptButton = NSLocalizedString("autofill.logins.delete.all.authentication.prompt.button", value: "Authenticate Now", comment: "Title of button in prompt requiring authentication before all passwords are deleted")
    public static let autofillDeleteAllPasswordsAuthenticationReason = NSLocalizedString("autofill.logins.delete.all.authentication.reason", value:"Authenticate to confirm you want to delete all passwords", comment: "Reason for authentication when deleting all logins")
    public static func autofillAllPasswordsDeletedToastMessage(for count: Int) -> String {
        let message = NSLocalizedString("autofill.delete.all.passwords.completion", comment: "Do not translate - stringsdict entry")
        return message.format(arguments: count)
    }

    public static let autofillLoginPromptAuthenticationCancelButton = NSLocalizedString("autofill.logins.prompt.auth.cancel", value:"Cancel", comment: "Cancel button for auth during login prompt")
    public static let autofillLoginPromptAuthenticationReason = NSLocalizedString("autofill.logins.prompt.auth.reason", value:"Unlock to use saved password", comment: "Reason for auth during login prompt")
    public static let autofillLoginPromptTitle = NSLocalizedString("autofill.logins.prompt.title", value:"Use a saved password?", comment: "Title for autofill login prompt")
    public static let autofillLoginPromptExactMatchTitle = NSLocalizedString("autofill.logins.prompt.exact.match.title", value:"From this website", comment: "Title for section of autofill logins that are an exact match to the current website")
    public static func autofillLoginPromptPartialMatchTitle(for type: String) -> String {
        let message = NSLocalizedString("autofill.logins.prompt.partial.match.title", value: "From %@", comment: "Title for section of autofill logins that are an approximate match to the current website")
        return message.format(arguments: type)
    }
    public static func autofillLoginPromptPasswordButtonTitle(for site: String) -> String {
        let message = NSLocalizedString("autofill.logins.prompt.password.button.title", value: "Password for %@", comment: "Title of button for autofill login prompt to use a saved password for a website")
        return message.format(arguments: site)
    }
    
    public static let autofillLoginPromptMoreOptions = NSLocalizedString("autofill.logins.prompt.more-options", value:"More Options", comment: "Button title for autofill login prompt if more options are available")

    public static let autofillNoAuthViewTitle = NSLocalizedString("autofill.logins.no-auth.title", value:"Secure your device to save passwords", comment: "Title for view displayed when autofill is locked on devices where a passcode has not been set")
    public static let autofillNoAuthViewSubtitle = NSLocalizedString("autofill.logins.no-auth.subtitle", value:"A passcode is required to protect your passwords.", comment: "Title for view displayed when autofill is locked on devices where a passcode has not been set")

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
        let message = NSLocalizedString("autofill.logins.details.last-updated", value: "Last updated %@", comment: "Message displaying when the login was last updated")
        return message.format(arguments: date)
    }
    public static let autofillLoginListAuthenticationCancelButton = NSLocalizedString("autofill.logins.list.auth.cancel", value:"Cancel", comment: "Cancel button for auth when opening login list")
    public static let autofillLoginListAuthenticationReason = NSLocalizedString("autofill.logins.list.auth.reason", value:"Unlock device to access passwords", comment: "Reason for auth when opening login list")
    public static let autofillLoginDetailsDefaultTitle = NSLocalizedString("autofill.logins.details.default-title", value:"Password", comment: "Title for autofill login details")
    public static let autofillLoginDetailsEditTitle = NSLocalizedString("autofill.logins.details.edit-title", value:"Edit Password", comment: "Title when editing autofill login details")
    public static let autofillLoginDetailsNewTitle = NSLocalizedString("autofill.logins.details.new-title", value:"Add password", comment: "Title when adding new autofill login")
    public static let autofillLoginDetailsDeleteButton = NSLocalizedString("autofill.logins.details.delete", value:"Delete Password", comment: "Delete button when deleting an autofill login")
    public static let autofillLoginDetailsDeleteConfirmationButtonTitle = NSLocalizedString("autofill.logins.details.delete-confirmation.button", value:"Delete Password", comment: "Autofill alert button confirming delete autofill login")

    public static func autofillLoginListLoginDeletedToastMessage(for title: String) -> String {
        let message = NSLocalizedString("autofill.logins.list.login-deleted-message", value: "Password for %@ deleted", comment: "Toast message when a login item is deleted")
        return message.format(arguments: title)
    }
    public static let autofillLoginListLoginDeletedToastMessageNoTitle = NSLocalizedString("autofill.logins.list.login-deleted-message-no-title", value: "Password deleted", comment: "Toast message when a login item without a title is deleted")

    public static let autofillLoginDetailsEditTitlePlaceholder = NSLocalizedString("autofill.logins.details.edit.title-placeholder", value:"Title", comment: "Placeholder for title field on autofill login details")
    public static let autofillLoginDetailsEditUsernamePlaceholder = NSLocalizedString("autofill.logins.details.edit.username-placeholder", value:"username@example.com", comment: "Placeholder for userbane field on autofill login details")
    public static let autofillLoginDetailsEditPasswordPlaceholder = NSLocalizedString("autofill.logins.details.edit.password-placeholder", value:"Password", comment: "Placeholder for password field on autofill login details")
    public static let autofillLoginDetailsEditURLPlaceholder = NSLocalizedString("autofill.logins.details.edit.url-placeholder", value:"example.com", comment: "Placeholder for url field on autofill login details")

    public static let autofillLoginDetailsSaveDuplicateLoginAlertTitle = NSLocalizedString("autofill.logins.details.save-duplicate-alert.title", value:"Duplicate Password", comment: "Title for alert when attempting to save a duplicate login")
    public static let autofillLoginDetailsSaveDuplicateLoginAlertMessage = NSLocalizedString("autofill.logins.details.save-duplicate-alert.message", value:"You already have a password saved for this username and website.", comment: "Message for alert when attempting to save a duplicate login")
    public static let autofillLoginDetailsSaveDuplicateLoginAlertAction = NSLocalizedString("autofill.logins.details.save-duplicate-alert.action", value:"OK", comment: "Action text for alert when attempting to save a duplicate login")
    
    public static let autofillNavigationButtonItemTitleClose = NSLocalizedString("autofill.logins.list.close-title", value:"Close", comment: "Title for close navigation button")
    
    // Autofill Password Generation Prompt
    public static let autofillPasswordGenerationPromptTitle = NSLocalizedString("autofill.password-generation-prompt.title", value:"Use a strong password from DuckDuckGo?", comment: "Title for prompt to use suggested strong password for creating a login")
    public static let autofillPasswordGenerationPromptSubtitle = NSLocalizedString("autofill.password-generation-prompt.subtitle", value:"Passwords are stored securely on your device.", comment: "Subtitle for prompt to use suggested strong password for creating a login")
    public static let autofillPasswordGenerationPromptUseGeneratedPasswordCTA = NSLocalizedString("autofill.password-generation-prompt.use-generated-password.cta", value:"Use Strong Password", comment: "Button title choosing to use the suggested generated password for creating a login")
    public static let autofillPasswordGenerationPromptUseOwnPasswordCTA = NSLocalizedString("autofill.password-generation-prompt.use-own-password.cta", value:"Create My Own", comment: "Button title choosing to use own password for creating a login")
    
    // Autofill Email Management
    static let autofillPrivateEmailMessageError = NSLocalizedString("autofill.private.email.mesage.error", value: "Management of this address is temporarily unavailable", comment: "Mesasage displayed when a user tries to manage a private email address but the service is not available, returns an error or network is down")
    static let autofillPrivateEmailMessageActive = NSLocalizedString("autofill.private.email.mesage.active", value: "Active", comment: "Mesasage displayed when a private email address is active")
    static let autofillPrivateEmailMessageDeactivated = NSLocalizedString("autofill.private.email.mesage.inactive", value: "Deactivated", comment: "Mesasage displayed when a private email address is inactive")
    static let autofillEnableEmailProtection = NSLocalizedString("autofill.enable.email.protection", value: "Enable Email Protection", comment: "Text link to email protection website")
    static let autofillSignInToManageEmail = NSLocalizedString("autofill.signin.to.manage", value: "%@ to manage your Duck Addresses on this device.", comment: "Message displayed to the user when they are logged out of Email protection.")
    
    static let autofillCancel = NSLocalizedString("pm.cancel", value: "Cancel", comment: "Cancel button")
    static let autofillEmailActivateConfirmTitle = NSLocalizedString("autofill.private.email.mesage.activate.confirm.title", value: "Reactivate Private Duck Address?", comment: "Title for the confirmation message  displayed when a user tries activate a Private Email Address")
    static let autofillEmailActivateConfirmContent = NSLocalizedString("autofill.private.email.mesage.activate.confirm.content", value: "Emails sent to %@ will again be forwarded to your inbox.", comment: "Text for the confirmation message displayed when a user tries activate a Private Email Address")
    static let autofillEmailDeactivateConfirmTitle = NSLocalizedString("autofill.private.email.mesage.deactivate.confirm.title", value: "Deactivate Private Duck Address?", comment: "Title for the confirmation message displayed when a user tries deactivate a Private Email Address")
    static let autofillEmailDeactivateConfirmContent = NSLocalizedString("autofill.private.email.mesage.deactivate.confirm.content", value: "Emails sent to %@ will no longer be forwarded to your inbox.", comment: "Text for the confirmation message displayed when a user tries deactivate a Private Email Address")
    static let autofillRemovedDuckAddressTitle = NSLocalizedString("autofill.removed.duck.address.title", value: "Private Duck Address username was removed", comment: "Title for the alert dialog telling the user an updated username is no longer a private email address")
    static let autofillRemovedDuckAddressContent = NSLocalizedString("autofill.removed.duck.address.content", value: "You can still manage this Duck Address from emails received from it in your personal inbox.", comment: "Content for the alert dialog telling the user an updated username is no longer a private email address")
    static let autofillRemovedDuckAddressButton = NSLocalizedString("autofill.removed.duck.address.button", value: "Got it", comment: "Button text for the alert dialog telling the user an updated username is no longer a private email address")
    static let autofillDeactivate = NSLocalizedString("pm.deactivate", value: "Deactivate", comment: "Deactivate button")
    static let autofillActivate = NSLocalizedString("pm.activate", value: "Reactivate", comment: "Activate button")

    // Autofill Password Import
    public static let autofillImportPasswordsTitle = NSLocalizedString("autofill.import.passwords.title", value:"How To Import Passwords", comment: "Title for screen to import passwords")
    public static let autofillImportPasswordsSubtitle = NSLocalizedString("autofill.import.passwords.subtitle", value:"Import passwords in the desktop version of the DuckDuckGo browser, then sync across devices.", comment: "Subtitle for screen to import passwords")
    public static let autofillImportPasswordsGetBrowserButton = NSLocalizedString("autofill.import.passwords.get-browser-button", value:"Get Desktop Browser", comment: "Button label to get link to download the desktop browser")
    public static let autofillImportPasswordsSyncButton = NSLocalizedString("autofill.import.passwords.sync-button", value:"Sync With Desktop", comment: "Button label to sync passwords with desktop browser")
    public static let autofillImportPasswordsInstructionsTitle = NSLocalizedString("autofill.import.passwords.instructions.title", value:"Import from the desktop browser:", comment: "Title for section with instructions to import passwords")
    public static let autofillImportPasswordsInstructionsStep1 = NSLocalizedString("autofill.import.passwords.instructions.step1", value:"Open DuckDuckGo on Mac or Windows", comment: "Step 1 for instructions to import passwords")
    public static let autofillImportPasswordsInstructionsStep2 = NSLocalizedString("autofill.import.passwords.instructions.step2", value:"Go to %@ > %@", comment: "Step 2 for instructions to import passwords. This reads as 'Go to Settings > Passwords'")
    public static let autofillImportPasswordsInstructionsStep2Settings = NSLocalizedString("autofill.import.passwords.instructions.step2.settings", value:"Settings", comment: "first parameter for autofill.import.passwords.instructions.step2")
    public static let autofillImportPasswordsInstructionsStep2Autofill = NSLocalizedString("autofill.import.passwords.instructions.step2.passwords", value:"Passwords", comment: "second parameter for autofill.import.passwords.instructions.step2")
    public static let autofillImportPasswordsInstructionsStep3 = NSLocalizedString("autofill.import.passwords.instructions.step3", value:"Select %@ and follow the steps to import", comment: "Step 3 for instructions to import passwords. This reads as 'Select Import Passwords and follow the steps'")
    public static let autofillImportPasswordsInstructionsStep3Import = NSLocalizedString("autofill.import.passwords.instructions.step3.import", value:"Import Passwords...", comment: "Parameter for autofill.import.passwords.instructions.step3")
    public static let autofillImportPasswordsInstructionsStep4 = NSLocalizedString("autofill.import.passwords.instructions.step4", value:"Once imported on your computer you can set up sync on this %@", comment: "Step 4 for instructions to import passwords: Once imported on your computer you can set up sync on this iPhone|iPad|device")
    public static let deviceTypeiPhone = NSLocalizedString("device.type.iphone", value:"iPhone", comment: "Device type is iPhone")
    public static let deviceTypeiPad = NSLocalizedString("device.type.pad", value:"iPad", comment: "Device type is iPad")
    public static let deviceTypeDefault = NSLocalizedString("device.type.default", value:"device", comment: "Default string used if users device is not iPhone or iPad")

    // Email Protection In-context Signup
    public static let emailProtection = NSLocalizedString("email-protection", value: "Email Protection", comment: "Email protection service offered by DuckDuckGo")
    public static let emailSignupPromptTitle = NSLocalizedString("email.signup-prompt.title", value:"Hide Your Email and\nBlock Trackers", comment: "Title for prompt to sign up for email protection")
    public static let emailSignupPromptSubtitle = NSLocalizedString("email.signup-prompt.subtitle", value:"Create a unique, random address that also removes hidden trackers and forwards email to your inbox.", comment: "Subtitle for prompt to sign up for email protection")
    public static let emailSignupPromptSignUpButton = NSLocalizedString("email.signup-prompt.signup-button.cta", value:"Protect My Email", comment: "Button title choosing to sign up for email protection")
    public static let emailSignupPromptDoNotSignUpButton = NSLocalizedString("email.signup-prompt.do-not-signup-button.cta", value:"Don’t Show Again", comment: "Button title choosing not to sign up for email protection and not to be prompted again")
    public static let emailSignupExitEarlyAlertTitle = NSLocalizedString("email.signup-prompt.alert.title", value: "If you exit now, your Duck Address will not be saved!", comment: "Title for exiting the Email Protection signup early alert")
    public static let emailSignupExitEarlyActionContinue = NSLocalizedString("email.signup-prompt.alert.continue", value: "Continue Setup", comment: "Option to continue the Email Protection signup")
    public static let emailSignupExitEarlyActionExit = NSLocalizedString("email.signup-prompt.alert.exit", value: "Exit Setup", comment: "Option to exit the Email Protection signup")
    
    public static let backButtonTitle = NSLocalizedString("navbar.back-button.title", value:"Back", comment: "Title for back button in navigation bar")
    public static let nextButtonTitle = NSLocalizedString("navbar.next-button.title", value:"Next", comment: "Title for next button in navigation bar to progress forward")
    
    // MARK: Omnibar
    
    public static let omnibarNotificationCookiesManaged = NSLocalizedString("omnibar.notification.cookies-managed", value:"Cookies Managed", comment: "Text displayed on notification appearing in the address bar when the browser  dismissed the cookie popup automatically rejecting it")
    public static let omnibarNotificationPopupHidden = NSLocalizedString("omnibar.notification.popup-hidden", value:"Pop-up Hidden", comment: "Text displayed on notification appearing in the address bar when the browser  hides a cookie popup")
    
    // MARK: Sync

    public static let syncUserUserAuthenticationReason = NSLocalizedString("sync.user.auth.reason", value:"Unlock device to set up Sync & Backup", comment: "Reason for auth when setting up Sync")
    public static let syncTurnOffConfirmTitle = NSLocalizedString("sync.turn.off.confirm.title", value:"Turn Off Sync?", comment: "Title of the dialog to confirm turning off Sync")
    public static let syncTurnOffConfirmMessage = NSLocalizedString("sync.turn.off.confirm.message", value:"This Device will no longer be able to access your synced data.", comment: "Message for the dialog to confirm turning off Sync")
    public static let syncTurnOffConfirmAction = NSLocalizedString("sync.turn.off.confirm.action", value:"Remove", comment: "Caption for a button to remove current device from Sync")
    public static let syncDeleteAllConfirmTitle = NSLocalizedString("sync.delete.all.confirm.title", value:"Delete Server Data?", comment: "Title of the dialog to confirm deleting Sync server data")
    public static let syncDeleteAllConfirmMessage = NSLocalizedString("sync.delete.all.confirm.message", value:"All devices will be disconnected and your synced data will be deleted from the server.", comment: "Message for the dialog to confirm deleting Sync server data")
    public static let syncDeleteAllConfirmAction = NSLocalizedString("sync.delete.all.confirm.action", value:"Delete Server Data", comment: "Caption for a button to delete Sync server data")
    public static let syncRemoveDeviceTitle = NSLocalizedString("sync.remove-device.title", value:"Remove Device?", comment: "Title of the dialog to remove device from Sync")
    public static func syncRemoveDeviceMessage(_ deviceName: String) -> String {
        let message = NSLocalizedString("sync.remove-device.message", value: "\"%@\" will no longer be able to access your synced data.", comment: "")
        return message.format(arguments: deviceName)
    }
    public static let syncRemoveDeviceConfirmAction = NSLocalizedString("sync.remove-device.action", value:"Remove", comment: "Caption for a button to remove device from Sync")
    public static let syncCodeCopied = NSLocalizedString("sync.code.copied", value:"Recovery code copied to clipboard", comment: "Message confirming that recovery code was copied to clipboard")

    // MARK: Sync Errors
    static let syncLimitExceededTitle = NSLocalizedString("prefrences.sync.limit-exceeded-title", value: "Sync Paused", comment: "Title for sync limits exceeded warning")
    static let syncErrorTitle = NSLocalizedString("alert.sync.warning.sync-error", value: "Sync Error", comment: "Title of the warning message that tells the user that there was an error with the sync feature.")
    static let bookmarksLimitExceededDescription = NSLocalizedString("prefrences.sync.bookmarks-limit-exceeded-description", value: "You've reached the maximum number of bookmarks. Please delete some to resume sync.", comment: "Description for sync bookmarks limits exceeded warning")
    static let credentialsLimitExceededDescription = NSLocalizedString("prefrences.sync.credentials-limit-exceeded-description", value: "You've reached the maximum number of passwords. Please delete some to resume sync.", comment: "Description for sync credentials limits exceeded warning")
    public static let invalidLoginCredentialErrorDescription = NSLocalizedString("prefrences.sync.invalid-login-description", value: "Sync encountered an error. Try disabling sync on this device and then reconnect using another device or your recovery code.", comment: "Description invalid credentials error when syncing.")
    static let tooManyRequestsErrorDescription = NSLocalizedString("prefrences.sync.invalid-login-description", value: "Sync & Backup is temporarily unavailable.", comment: "Description of too many requests error when syncing.")
    static let badRequestErrorDescription = NSLocalizedString("prefrences.sync.invalid-login-description", value: "Some bookmarks or passwords are formatted incorrectly or too long and were not synced.", comment: "Description of incorrectly formatted data error when syncing.")
    static let bookmarksLimitExceededAction = NSLocalizedString("prefrences.sync.bookmarks-limit-exceeded-action", value: "Manage Bookmarks", comment: "Button title for sync bookmarks limits exceeded warning to go to manage bookmarks")
    static let credentialsLimitExceededAction = NSLocalizedString("prefrences.sync.credentials-limit-exceeded-action", value: "Manage passwords…", comment: "Button title for sync credentials limits exceeded warning to go to manage passwords")
    static let syncPausedAlertTitle = NSLocalizedString("alert.sync-paused-title", value: "Sync is Paused", comment: "Title for alert shown when sync paused for an error")
    static let syncInvalidLoginAlertDescription = NSLocalizedString("alert.sync-invalid-login-error-description", value: "Sync has been paused. If you want to continue syncing this device, reconnect using another device or your recovery code.", comment: "Description for alert shown when user logged off from sync")
    static let syncTooManyRequestsAlertDescription = NSLocalizedString("alert.sync-too-many-requests-error-description", value: "Sync & Backup is temporarily unavailable.", comment: "Description for alert shown when sync error occurs because of too many requests")
    static let syncBadRequestAlertDescription = NSLocalizedString("alert.sync-bad-data-error-description", value: "Some bookmarks or passwords are formatted incorrectly or too long and were not synced.", comment: "Description for alert shown when sync error occurs because of bad data")
    static let syncErrorAlertAction  = NSLocalizedString("alert.sync-error-action", value: "Sync Settings", comment: "Sync error alert action button title, takes the user to the sync settings page.")
    static let syncBookmarkPausedAlertTitle = NSLocalizedString("alert.sync-bookmarks-paused-title", value: "Bookmark Sync is Paused", comment: "Title for alert shown when sync bookmarks paused for too many items")
    static let syncBookmarkPausedAlertDescription = NSLocalizedString("alert.sync-bookmarks-paused-description", value: "You've reached the maximum number of bookmarks. Please delete some bookmarks to resume sync.", comment: "Description for alert shown when sync bookmarks paused for too many items")
    static let syncCredentialsPausedAlertTitle = NSLocalizedString("alert.sync-credentials-paused-title", value: "Password Sync is Paused", comment: "Title for alert shown when sync credentials paused for too many items")
    static let syncCredentialsPausedAlertDescription = NSLocalizedString("alert.sync-credentials-paused-description", value: "You've reached the maximum number of passwords. Please delete some passwords to resume sync.", comment: "Description for alert shown when sync credentials paused for too many items")
    static let syncPausedTitle = NSLocalizedString("alert.sync.warning.sync-paused", value: "Sync & Backup is Paused", comment: "Title of the warning message")
    static let unknownErrorTryAgainMessage = NSLocalizedString("error.unknown.try.again", value: "An unknown error has occurred", comment: "Generic error message on a dialog for when the cause is not known.")
    public static let syncPausedAlertOkButton = NSLocalizedString("alert.sync-paused-alert-ok-button", value: "OK", comment: "Confirmation button in alert")
    public static let syncPausedAlertLearnMoreButton = NSLocalizedString("alert.sync-paused-alert-learn-more-button", value: "Learn More", comment: "Learn more button in alert")
    public static let syncErrorAlertTitle = NSLocalizedString("alert.sync-error", value: "Sync & Backup Error", comment: "Title for sync error alert")
    public static let unableToSyncToServerDescription = NSLocalizedString("alert.unable-to-sync-to-server-description", value: "Unable to connect to the server.", comment: "Description for unable to sync to server error")
    public static let unableToSyncWithOtherDeviceDescription = NSLocalizedString("alert.unable-to-sync-with-other-device-description", value: "Unable to Sync with another device.", comment: "Description for unable to sync with another device error")
    public static let unableToMergeTwoAccountsErrorDescription = NSLocalizedString("alert.unable-to-merge-two-accounts-description", value: "To pair these devices, turn off Sync & Backup on one device then tap \"Sync With Another Device\" on the other device.", comment: "Description for unable to merge two accounts error")
    public static let unableToUpdateDeviceNameDescription = NSLocalizedString("alert.unable-to-update-device-name-description", value: "Unable to update the device name.", comment: "Description for unable to update device name error")
    public static let unableToTurnSyncOffDescription = NSLocalizedString("alert.unable-to-turn-sync-off-description", value: "Unable to turn Sync & Backup off.", comment: "Description for unable to turn sync off error")
    public static let unableToDeleteDataDescription = NSLocalizedString("alert.unable-to-delete-data-description", value: "Unable to delete data on the server.", comment: "Description for unable to delete data error")
    public static let unableToRemoveDeviceDescription = NSLocalizedString("alert.unable-to-remove-device-description", value: "Unable to remove this device from Sync & Backup.", comment: "Description for unable to remove device error")
    public static let unableToCreateRecoveryPDF = NSLocalizedString("alert.unable-to-create-recovery-pdf-description", value: "Unable to create the recovery PDF.", comment: "Description for unable to create recovery pdf error")
    static let syncUnavailableMessage = NSLocalizedString("sync.warning.data.syncing.disabled", value: "Sorry, but Sync & Backup is currently unavailable. Please try again later.", comment: "Data syncing unavailable warning message")
    static let syncUnavailableMessageUpgradeRequired = NSLocalizedString("sync.warning.data.syncing.disabled.upgrade.required", value: "Sorry, but Sync & Backup is no longer available in this app version. Please update DuckDuckGo to the latest version to continue.", comment: "Data syncing unavailable warning message")

    static let preemptiveCrashTitle = NSLocalizedString("error.preemptive-crash.title", value: "App issue detected", comment: "Alert title")
    static let preemptiveCrashBody = NSLocalizedString("error.preemptive-crash.body", value: "Looks like there's an issue with the app and it needs to close. Please reopen to continue.", comment: "Alert message")
    static let preemptiveCrashAction = NSLocalizedString("error.preemptive-crash.action", value: "Close App", comment: "Button title that is shutting down the app")
    
    static let insufficientDiskSpaceTitle = NSLocalizedString("error.insufficient-disk-space.title", value: "Not enough storage", comment: "Alert title")
    static let insufficientDiskSpaceBody = NSLocalizedString("error.insufficient-disk-space.body", value: "Looks like your device has run out of storage space. Please free up space to continue.", comment: "Alert message")
    static let insufficientDiskSpaceAction = NSLocalizedString("error.insufficient-disk-space.action", value: "Open Settings", comment: "Button title to open device settings")
    
    static let emailProtectionSignInTitle = NSLocalizedString("error.email-protection-sign-in.title", value: "Email Protection Error", comment: "Alert title")
    static let emailProtectionSignInBody = NSLocalizedString("error.email-protection-sign-in.body", value: "Sorry, please sign in again to re-enable Email Protection features on this browser.", comment: "Alert message")
    static let emailProtectionSignInAction = NSLocalizedString("error.email-protection-sign-in.action", value: "Sign In", comment: "Button title to Sign In")
    
    // MARK: - VPN Waitlist
    
    static let networkProtectionWaitlistJoinTitle = NSLocalizedString("network-protection.waitlist.join.title", value: "VPN Early Access", comment: "Title for Network Protection join waitlist screen")
    static let networkProtectionWaitlistJoinSubtitle1 = NSLocalizedString("network-protection.waitlist.join.subtitle.1", value: "Secure your connection anytime, anywhere with Network Protection, the VPN from DuckDuckGo.", comment: "First subtitle for Network Protection join waitlist screen")
    static let networkProtectionWaitlistJoinSubtitle2 = NSLocalizedString("network-protection.waitlist.join.subtitle.2", value: "Join the waitlist, and we’ll notify you when it’s your turn.", comment: "Second subtitle for Network Protection join waitlist screen")
    
    static let networkProtectionWaitlistJoinedTitle = NSLocalizedString("network-protection.waitlist.joined.title", value: "You’re on the list!", comment: "Title for Network Protection joined waitlist screen")
    static let networkProtectionWaitlistJoinedWithNotificationsSubtitle1 = NSLocalizedString("network-protection.waitlist.joined.with-notifications.subtitle.1", value: "New invites are sent every few days, on a first come, first served basis.", comment: "Subtitle 1 for Network Protection joined waitlist screen when notifications are enabled")
    static let networkProtectionWaitlistJoinedWithNotificationsSubtitle2 = NSLocalizedString("network-protection.waitlist.joined.with-notifications.subtitle.2", value: "We’ll notify you when your invite is ready.", comment: "Subtitle 2 for Network Protection joined waitlist screen when notifications are enabled")
    
    static let networkProtectionWaitlistNotificationTitle = NSLocalizedString("network-protection.waitlist.notification.title", value: "DuckDuckGo VPN is ready!", comment: "Title for Network Protection waitlist notification")
    static let networkProtectionWaitlistNotificationText = NSLocalizedString("network-protection.waitlist.notification.text", value: "Open your invite", comment: "Title for Network Protection waitlist notification")
    
    static let networkProtectionWaitlistInvitedTitle = NSLocalizedString("network-protection.waitlist.invited.title", value: "You’re invited to try\nDuckDuckGo VPN early access!", comment: "Title for Network Protection invited screen")
    static let networkProtectionWaitlistInvitedSubtitle = NSLocalizedString("network-protection.waitlist.invited.subtitle", value: "Get an extra layer of protection online with the VPN built for speed and simplicity. Encrypt your internet connection across your entire device and hide your location and IP address from sites you visit.", comment: "Subtitle for Network Protection invited screen")
    
    static let networkProtectionWaitlistInvitedSection1Title = NSLocalizedString("network-protection.waitlist.invited.section-1.title", value: "Full-device coverage", comment: "Title for section 1 of the Network Protection invited screen")
    static let networkProtectionWaitlistInvitedSection1Subtitle = NSLocalizedString("network-protection.waitlist.invited.section-1.subtitle", value: "Encrypt online traffic across your browsers and apps.", comment: "Subtitle for section 1 of the Network Protection invited screen")
    
    static let networkProtectionWaitlistInvitedSection2Title = NSLocalizedString("network-protection.waitlist.invited.section-2.title", value: "Fast, reliable, and easy to use", comment: "Title for section 2 of the Network Protection invited screen")
    static let networkProtectionWaitlistInvitedSection2Subtitle = NSLocalizedString("network-protection.waitlist.invited.section-2.subtitle", value: "No need for a separate app. Connect in one click and see your connection status at a glance.", comment: "Subtitle for section 2 of the Network Protection invited screen")
    
    static let networkProtectionWaitlistInvitedSection3Title = NSLocalizedString("network-protection.waitlist.invited.section-3.title", value: "Strict no-logging policy", comment: "Title for section 3 of the Network Protection invited screen")
    static let networkProtectionWaitlistInvitedSection3Subtitle = NSLocalizedString("network-protection.waitlist.invited.section-3.subtitle", value: "We do not log or save any data that can connect you to your online activity.", comment: "Subtitle for section 3 of the Network Protection invited screen")
    
    static let networkProtectionWaitlistButtonEnableNotifications = NSLocalizedString("network-protection.waitlist.button.enable-notifications", value: "Enable Notifications", comment: "Enable Notifications button for Network Protection joined waitlist screen")
    static let networkProtectionWaitlistButtonJoinWaitlist = NSLocalizedString("network-protection.waitlist.button.join-waitlist", value: "Join the Waitlist", comment: "Join Waitlist button for Network Protection join waitlist screen")
    static let networkProtectionWaitlistButtonAgreeAndContinue = NSLocalizedString("network-protection.waitlist.button.agree-and-continue", value: "Agree and Continue", comment: "Agree and Continue button for Network Protection join waitlist screen")
    static let networkProtectionWaitlistButtonExistingInviteCode = NSLocalizedString("network-protection.waitlist.button.existing-invite-code", value: "I Have an Invite Code", comment: "Button title for users who already have an invite code")
    
    static let networkProtectionWaitlistAvailabilityDisclaimer = NSLocalizedString("network-protection.waitlist.availability-disclaimer", value: "DuckDuckGo VPN is free to use during early access.", comment: "Availability disclaimer for Network Protection join waitlist screen")
    
    static let networkProtectionPrivacyPolicyTitle = NSLocalizedString("network-protection.privacy-policy.title", value: "Privacy Policy", comment: "Privacy Policy title for Network Protection")
    
    static let networkProtectionWaitlistNotificationAlertDescription = NSLocalizedString("network-protection.waitlist.notification-alert.description", value: "We’ll send you a notification when your invite to test DuckDuckGo VPN is ready.", comment: "Body text for the alert to enable notifications")

    static let networkProtectionWaitlistGetStarted = NSLocalizedString("network-protection.waitlist.get-started", value: "Get Started", comment: "Button title text for the Network Protection waitlist confirmation prompt")
    static let networkProtectionWaitlistAgreeAndContinue = NSLocalizedString("network-protection.waitlist.agree-and-continue", value: "Agree and Continue", comment: "Title text for the Network Protection terms and conditions accept button")
    
    static let networkProtectionSettingsSubtitleNotJoined = NSLocalizedString("network-protection.waitlist.settings-subtitle.waitlist-not-joined", value: "Join the private waitlist", comment: "Subtitle text for the Network Protection settings row")
    static let networkProtectionSettingsSubtitleJoinedButNotInvited = NSLocalizedString("network-protection.waitlist.settings-subtitle.joined-but-not-invited", value: "You’re on the list!", comment: "Subtitle text for the Network Protection settings row")
    static let networkProtectionSettingsSubtitleJoinedAndInvited = NSLocalizedString("network-protection.waitlist.settings-subtitle.joined-and-invited", value: "Your invite is ready!", comment: "Subtitle text for the Network Protection settings row")
    
    static let networkProtectionNotificationPromptTitle = NSLocalizedString("network-protection.waitlist.notification-prompt-title", value: "Know the instant you're invited", comment: "Title for the alert to confirm enabling notifications")
    static let networkProtectionNotificationPromptDescription = NSLocalizedString("network-protection.waitlist.notification-prompt-description", value: "Get a notification when your copy of Network Protection early access is ready.", comment: "Subtitle for the alert to confirm enabling notifications")

    static let networkProtectionNotificationsTitle = NSLocalizedString("network.protection.notification.title", value: "DuckDuckGo", comment: "The title of the notifications shown from Network Protection")
    static let networkProtectionConnectionSuccessNotificationBody = NSLocalizedString("network.protection.success.notification.body", value: "Network Protection is On. Your location and online activity are protected.", comment: "The body of the notification shown when Network Protection reconnects successfully")
    static func networkProtectionConnectionSuccessNotificationBody(serverLocation: String) -> String {
        let localized = NSLocalizedString(
            "network.protection.success.notification.subtitle.including.serverLocation",
            value: "Routing device traffic through %@.",
            comment: "The body of the notification shown when Network Protection connects successfully with the city + state/country as formatted parameter"
        )
        return String(format: localized, serverLocation)
    }
    static let networkProtectionConnectionInterruptedNotificationBody = NSLocalizedString("network.protection.interrupted.notification.body", value: "Network Protection was interrupted. Attempting to reconnect now...", comment: "The body of the notification shown when Network Protection's connection is interrupted")
    static let networkProtectionConnectionFailureNotificationBody = NSLocalizedString("network.protection.failure.notification.body", value: "Network Protection failed to connect. Please try again later.", comment: "The body of the notification shown when Network Protection fails to reconnect")
    static let networkProtectionEntitlementExpiredNotificationBody = NSLocalizedString("network.protection.entitlement.expired.notification.body", value: "VPN disconnected due to expired subscription. Subscribe to Privacy Pro to reconnect DuckDuckGo VPN.", comment: "The body of the notification when Privacy Pro subscription expired")

    // MARK: Settings Screeen
    public static let settingsTitle = NSLocalizedString("settings.title", value: "Settings", comment: "Title for the Settings View")
    public static let settingsOn = NSLocalizedString("settings.on", value: "On", comment: "Label describing a feature which is turned on")
    public static let settingsOff = NSLocalizedString("settings.off", value: "Off", comment: "Label describing a feature which is turned off")
    public static let settingsAlwaysOn = NSLocalizedString("settings.always.on", value: "Always On", comment: "Label describing a feature which is turned on always")

    // Privacy Protections
    public static let privateSearchExplanation = NSLocalizedString("settings.private.search.explanation", value: "DuckDuckGo Private Search is your default search engine, so you can search the web without being tracked.", comment: "Explanation in Settings how the private search feature works")
    public static let webTrackingProtectionExplanation = NSLocalizedString("settings.web.tracking.protection.explanation", value: "DuckDuckGo automatically blocks hidden trackers as you browse the web.\n[Learn More](ddgQuickLink://duckduckgo.com/duckduckgo-help-pages/privacy/web-tracking-protections/)", comment: "Explanation in Settings how the web tracking protection feature works")
    public static let cookiePopUpProtectionExplanation = NSLocalizedString("settings.cookie.pop.up.protection.explanation", value: "DuckDuckGo will try to select the most private settings available and hide these pop-ups for you.\n[Learn More](ddgQuickLink://duckduckgo.com/duckduckgo-help-pages/privacy/web-tracking-protections/#cookie-pop-up-management)", comment: "Explanation in Settings how the cookie pop up protection feature works")
    public static let emailProtectionExplanation = NSLocalizedString("settings.email.protection.explanation", value: "Block email trackers and hide your address without switching your email provider.\n[Learn More](ddgQuickLink://duckduckgo.com/duckduckgo-help-pages/email-protection/what-is-duckduckgo-email-protection/)", comment: "Explanation in Settings how the email protection feature works")
    public static let emailProtectionSigningOutAlert = NSLocalizedString("settings.email.protection.signing.out.alert", value: "Signing out of your Email Protection account will disable Duck Address autofill in this browser. You can still use these addresses and receive forwarded email as usual.", comment: "Alert presented to user after clicking on 'Sign out' in Email Protection Settings")
    public static let defaultBrowser = NSLocalizedString("settings.default.browser", value: "Default Browser", comment: "The name of Settings category in Privacy Features related to configuration of the default browser")
    public static let privateSearch = NSLocalizedString("settings.private.search", value: "Private Search", comment: "The name of Settings category in Privacy Features related to configuration of the search")
    public static let searchSettings = NSLocalizedString("settings.search.settings", value: "Search Settings", comment: "Header of settings related to search")
    public static let moreSearchSettings = NSLocalizedString("settings.more.search.settings", value: "More Search Settings", comment: "Button navigating to other settings related to search")
    public static let moreSearchSettingsExplanation = NSLocalizedString("settings.more.search.settings.explanation", value: "Customize your language, region, and more", comment: "Subtitle of the 'More Search Settings' button")

    public static let webTrackingProtection = NSLocalizedString("settings.web.tracking.protection", value: "Web Tracking Protection", comment: "The name of Settings category in Privacy Features related to configuration of the web tracking protection feature")
    public static let cookiePopUpProtection = NSLocalizedString("settings.cookie.pop-up-protection.protection", value: "Cookie Pop-Up Protection", comment: "The name of Settings category in Privacy Features related to configuration of the privacy feature related to cookie pop-ups")
    public static let letDuckDuckGoManageCookieConsentPopups = NSLocalizedString("settings.let.duckduckgo.manage.cookie.consent.popups", value: "Let DuckDuckGo manage cookie consent pop-ups", comment: "Switch button label.")

    public static let disableEmailProtectionAutofill = NSLocalizedString("settings.disable.email.protection.autofill", value: "Disable Email Protection Autofill", comment: "Label of a button disabling email protection")
    public static let manageAccount = NSLocalizedString("settings.manage.account", value: "Manage Account", comment: "Label of a button managing email protection account")
    public static let support = NSLocalizedString("settings.support", value: "Support", comment: "Label of a button navigating to the Support page")
    public static let enableEmailProtection = NSLocalizedString("settings.enable.email.protection", value: "Enable Email Protection", comment: "Label of a button enabling the email protection feature")

    // Main Settings

    public static let mainSettings = NSLocalizedString("settings.main.settings", value: "Main Settings", comment: "The name of the settings section containing main settings")
    public static let general = NSLocalizedString("settings.general", value: "General", comment: "The name of the settings subsection containing general settings")
    public static let settingsAppearanceSection = NSLocalizedString("settings.appearance", value: "Appearance", comment: "Settings screen appearance section title")
    public static let accessibility = NSLocalizedString("settings.accessibility", value: "Accessibility", comment: "Settings screen accessibility section title")
    public static let dataClearing = NSLocalizedString("settings.data.clearing", value: "Data Clearing", comment: "The name of a settings subsection related to the data clearing")
    public static let addressBar = NSLocalizedString("settings.address.bar", value: "Address Bar", comment: "Name of the settings subsection related to the address bar")

    // Next Steps
    public static let nextSteps = NSLocalizedString("settings.next.steps", value: "Next Steps", comment: "The name of a settings category listing next steps")
    public static let settingsAddToDock = NSLocalizedString("settings.add.to.dock", value: "Add App to Your Dock", comment: "Settings screen cell text for adding the app to the dock")
    public static let settingsAddWidget = NSLocalizedString("settings.add.widget", value: "Add Widget to Home Screen", comment: "Settings screen cell text for add widget to the home screen")
    public static let setYourAddressBarPosition = NSLocalizedString("settings.set.your.address.bar.position", value: "Set Your Address Bar Position", comment: "Settings screen cell text for setting address bar position")
    public static let enableVoiceSearch = NSLocalizedString("settings.enable.voice.search", value: "Enable Voice Search", comment: "Settings screen cell text for enabling voice search")

    // Others
    public static let settingsAboutSection = NSLocalizedString("settings.about.section", value: "About", comment: "Settings section title for About DuckDuckGo")
    public static let settingsFeedback = NSLocalizedString("settings.feedback", value: "Share Feedback", comment: "Settings cell for Feedback")
    public static let duckduckgoOnOtherPlatforms = NSLocalizedString("settings.duckduckgo.on.other.platforms", value: "DuckDuckGo on Other Platforms", comment: "Settings cell to link users to other products by DuckDuckGo")

    // General Section
    public static let settingsSetDefault = NSLocalizedString("settings.default.browser", value: "Set as Default Browser", comment: "Settings screen cell text for setting the app as default browser")
    public static let settingsSync = NSLocalizedString("settings.sync", value: "Sync & Backup", comment: "Settings screen cell text for sync and backup")
    public static let settingsLogins = NSLocalizedString("settings.logins", value: "Passwords", comment: "Settings screen cell text for passwords")
    
    // Appeareance Section
    public static let settingsTheme = NSLocalizedString("settings.theme", value: "Theme", comment: "Settings screen cell text for theme")
    public static let settingsIcon = NSLocalizedString("settings.icon", value: "App Icon", comment: "Settings screen cell text for app icon selection")
    public static let settingsFirebutton = NSLocalizedString("settings.firebutton", value: "Fire Button Animation", comment: "Settings screen cell text for fire button animation")
    public static let settingsText = NSLocalizedString("settings.text.size", value: "Text Size", comment: "Settings screen cell text for text size")
    public static let settingsAddressBar = NSLocalizedString("settings.address.bar", value: "Address Bar Position", comment: "Settings screen cell text for addess bar position")
    public static let settingsFullURL = NSLocalizedString("settings.address.full.url", value: "Show Full Site Address", comment: "Settings screen cell title for toggling full URL visibility in address bar")

    // Privacy Section
    public static let settingsPrivacySection = NSLocalizedString("settings.privacy", value: "Privacy", comment: "Settings title for the privacy section")
    public static let settingsGPC = NSLocalizedString("settings.gpc", value: "Global Privacy Control (GPC)", comment: "Settings screen cell text for GPC")
    public static let settingsCookiePopups = NSLocalizedString("settings.cookie.popups", value: "Manage Cookie Pop-ups", comment: "Settings screen cell text for Cookie popups")
    public static let settingsUnprotectedSites = NSLocalizedString("settings.unprotected.sites", value: "Unprotected Sites", comment: "Settings screen cell text for Unprotected Sites")
    public static let settingsFireproofSites = NSLocalizedString("settings.fireproof.sites", value: "Fireproof Sites", comment: "Settings screen cell text for Fireproof Sites")
    public static let settingsClearData = NSLocalizedString("settings.clear.data", value: "Automatically Clear Data", comment: "Settings screen cell text for Automatically Clearing Data")
    public static let settingsAutolock = NSLocalizedString("settings.autolock", value: "Application Lock", comment: "Settings screen cell text for Application Lock")
    public static let settingsAutoLockDescription = NSLocalizedString("settings.autolock.description", value: "If Touch ID, Face ID, or a system passcode is enabled, you'll be asked to unlock the app when opening it.", comment: "Section footer Autolock description")
    
    // Subscription Section
    public static let settingsPProSection = NSLocalizedString("settings.ppro", value: "Privacy Pro", comment: "Product name for the subscription bundle")
    public static let settingsPProSubscribe = NSLocalizedString("settings.subscription.subscribe", value: "Subscribe to Privacy Pro", comment: "Call to action title for Privacy Pro")
    public static let settingsPProDescription = NSLocalizedString("settings.subscription.description", value:"More seamless privacy with three new protections, including:", comment: "Privacy pro description subtext")
    public static let settingsPProFeatures = NSLocalizedString("settings.subscription.features", value:
                                                                """
                                                                 • VPN
                                                                 • Personal Information Removal
                                                                 • Identity Theft Restoration
                                                                """, comment: "Privacy pro features list")

    public static let settingsPProLearnMore = NSLocalizedString("settings.subscription.learn.more", value: "Get Privacy Pro", comment: "Get Privacy Pro button text for privacy pro")
    public static let settingsPProIHaveASubscription = NSLocalizedString("settings.subscription.existing.subscription", value: "I Have a Subscription", comment: "I have a Subscription button text for privacy pro")
    
    public static let settingsPProManageSubscription = NSLocalizedString("settings.subscription.manage", value: "Subscription Settings", comment: "Subscription Settings button text for privacy pro")
    
    public static let settingsPProVPNTitle = NSLocalizedString("settings.subscription.VPN.title", value: "VPN", comment: "VPN cell title for privacy pro")
    public static let settingsPProDBPTitle = NSLocalizedString("settings.subscription.DBP.title", value: "Personal Information Removal", comment: "Data Broker protection cell title for privacy pro")
    public static let settingsPProDBPSubTitle = NSLocalizedString("settings.subscription.DBP.subtitle", value: "Remove your info from sites that sell it", comment: "Data Broker protection cell subtitle for privacy pro")
    public static let settingsPProITRTitle = NSLocalizedString("settings.subscription.ITR.title", value: "Identity Theft Restoration", comment: "Identity theft restoration cell title for privacy pro")
    public static let settingsPProITRSubTitle = NSLocalizedString("settings.subscription.ITR.subtitle", value: "If your identity is stolen, we'll help restore it", comment: "Identity theft restoration cell subtitle for privacy pro")
    
    public static let settingsPProActivationPendingTitle = NSLocalizedString("settings.subscription.activation.pending.title", value: "Your Subscription is Being Activated", comment: "Subscription activation pending title")
    public static let settingsPProActivationPendingDescription = NSLocalizedString("settings.subscription.activation.pending.description", value: "This is taking longer than usual, please check back later.", comment: "Subscription activation pending description")
    
    // Expired Subscription
    public static let settingsPProSubscriptionExpiredTitle = NSLocalizedString("settings.subscription.expired.title", value: "Your Privacy Pro subscription expired", comment: "Subscription expired tittle message")
    public static let settingsPProSubscribeAgain = NSLocalizedString("settings.subscription.expired.comment", value: "Subscribe again to continue using Privacy Pro", comment: "Subscription expired description")

    
    // Customize Section
    public static let settingsCustomizeSection = NSLocalizedString("settings.customize", value: "Customize", comment: "Settings title for the customize section")
    public static let settingsKeyboard = NSLocalizedString("settings.keyboard", value: "Keyboard", comment: "Settings screen cell for Keyboard")
    public static let settingsPreviews = NSLocalizedString("settings.previews", value: "Long-Press Previews", comment: "Settings screen cell for long press previews")
    public static let settingsAutocomplete = NSLocalizedString("settings.autocomplete", value: "Autocomplete Suggestions", comment: "Settings screen cell for autocomplete")

    // Hardcoded for the experiment
    public static let settingsAutocompleteSubtitle = "See search suggestions, including your bookmarks and recently visited sites"
    public static let settingsVoiceSearch = NSLocalizedString("settings.voice.search", value: "Private Voice Search", comment: "Settings screen cell for voice search")
    public static let settingsAssociatedApps = NSLocalizedString("settings.associated.apps", value: "Open Links in Associated Apps", comment: "Settings screen cell for opening links in associated apps")
    public static let settingsAssociatedAppsDescription = NSLocalizedString("settings.associated.apps.description", value: "Disable to prevent links from automatically opening in other installed apps.", comment: "Description for associated apps description")
    
    // More Section
    public static let settingsMoreSection = NSLocalizedString("settings.more", value: "More from DuckDuckGo", comment: "Settings title for the 'More' section")
    public static let settingsEmailProtectionDescription = NSLocalizedString("settings.emailProtection.description", value: "Block email trackers and hide your address", comment: "Settings cell for Email Protection")

    public static let settingsAboutDDG = NSLocalizedString("settings.about.ddg", value: "About DuckDuckGo", comment: "Settings cell for About DDG")
    public static let settingsVersion = NSLocalizedString("settings.version", value: "Version", comment: "Settings cell for Version")
    public static let settingsSendCrashReports = NSLocalizedString("settings.send.crash.reports", value: "Send Crash Reports", comment: "Settings cell for Send Crash Reports")
    public static let settingsSendCrashReportsDescription = NSLocalizedString("settings.send.crash.reports.description", value: "Automatically send crash reports to DuckDuckGo.", comment: "Explanation of Send Crash Reports settings option")

    // MARK: Crash Reporting

    public static let crashReportDialogTitle = NSLocalizedString("crash.report.dialog.title", value: "Automatically send crash reports?", comment: "Crash Report dialog title")
    public static let crashReportDialogMessage = NSLocalizedString("crash.report.dialog.message", value: "Crash reports help DuckDuckGo diagnose issues and improve our products. They contain no personally identifiable information.", comment: "Crash Report dialog message")
    public static let crashReportShowDetails = NSLocalizedString("crash.report.dialog.show.details", value: "See what's sent", comment: "Crash Report show details button title")
    public static let crashReportHideDetails = NSLocalizedString("crash.report.dialog.hide.details", value: "Hide", comment: "Crash Report hide details button title")
    public static let crashReportAlwaysSend = NSLocalizedString("crash.report.dialog.always.send", value: "Always Send Crash Reports", comment: "Crash Report always send button title")
    public static let crashReportNeverSend = NSLocalizedString("crash.report.dialog.never.send", value: "Never Send", comment: "Crash Report never send button title")

    // MARK: Subscriptions
    
    // Loaders
    static let subscriptionPurchasingTitle = NSLocalizedString("subscription.progress.view.purchasing.subscription", value: "Purchase in progress...", comment: "Progress view title when starting the purchase")
    static let subscriptionRestoringTitle = NSLocalizedString("subscription.progress.view.restoring.subscription", value: "Restoring subscription...", comment: "Progress view title when restoring past subscription purchase")
    static let subscriptionCompletingPurchaseTitle = NSLocalizedString("subscription.progress.view.completing.purchase", value: "Completing purchase...", comment: "Progress view title when completing the purchase")
        
    // Subscription Settings
    public static let subscriptionTitle = NSLocalizedString("subscription.title", value: "Privacy Pro", comment: "Navigation bar Title for subscriptions")
    public static let subscriptionCloseButton = NSLocalizedString("subscription.close", value: "Close", comment: "Navigation Button for closing subscription view")
    
    static func subscriptionInfo(status: String, expiration: String) -> String {
        let localized = NSLocalizedString("subscription.subscription.active.caption",
                                          value: "Your subscription %@ on %@",
                                          comment: "Subscription Expiration Data. This reads as 'Your subscription (renews or expires) on (date)'")
        return String(format: localized, status, expiration)
    }
    
    static func expiredSubscriptionInfo(expiration: String) -> String {
        let localized = NSLocalizedString("subscription.subscription.expired.caption",
                                          value: "Your subscription expired on %@",
                                          comment: "Subscription Expired Data. This reads as 'Your subscription expired on (date)'")
        return String(format: localized, expiration)
    }
    
    public static let subscriptionRenews = NSLocalizedString("subscription.renews", value: "renews", comment: "text for renewal string")
    public static let subscriptionExpires = NSLocalizedString("subscription.expires", value: "expires", comment: "text for expiration string")
    public static let subscriptionMonthly = NSLocalizedString("subscription.monthly", value: "Monthly Subscription", comment: "Subscription type")
    public static let subscriptionAnnual = NSLocalizedString("subscription.annual", value: "Annual Subscription", comment: "Subscription type")
    
    public static let subscriptionManageDevices = NSLocalizedString("subscription.manage.devices", value: "Manage Devices", comment: "Header for the device management section")
    public static let subscriptionAddDeviceButton = NSLocalizedString("subscription.add.device.button", value: "Add to Another Device", comment: "Add to another device button")
    public static let subscriptionRemoveFromDevice = NSLocalizedString("subscription.remove.from.device.button", value: "Remove From This Device", comment: "Remove from this device button")
    public static let subscriptionManageTitle = NSLocalizedString("subscription.manage.title", value: "Subscription", comment: "Header for the subscription section")
    public static let subscriptionManagePlan = NSLocalizedString("subscription.manage.plan", value: "Manage Plan", comment: "Manage Plan header")
    public static let subscriptionChangePlan = NSLocalizedString("subscription.change.plan", value: "Change Plan or Billing", comment: "Change plan or billing title")
    public static let subscriptionHelpAndSupport = NSLocalizedString("subscription.help", value: "Help and support", comment: "Help and support Section header")
    public static let subscriptionFAQ = NSLocalizedString("subscription.faq", value: "Privacy Pro FAQ", comment: "FAQ Button")
    public static let subscriptionFAQFooter = NSLocalizedString("subscription.faq.description", value: "Get answers to frequently asked questions about Privacy Pro in our help pages.", comment: "FAQ Description")
    
    // Remove subscription confirmation
    public static let subscriptionRemoveFromDeviceConfirmTitle = NSLocalizedString("subscription.remove.from.device.title", value: "Remove from this device?", comment: "Remove from device confirmation dialog title")
    public static let subscriptionRemoveFromDeviceConfirmText = NSLocalizedString("subscription.remove.from.device.text", value: "You will no longer be able to access your Privacy Pro subscription on this device. This will not cancel your subscription, and it will remain active on your other devices.", comment: "Remove from device confirmation dialog text")
    public static let subscriptionRemove = NSLocalizedString("subscription.remove.subscription", value: "Remove Subscription", comment: "Remove subscription button text")
    public static let subscriptionRemoveCancel = NSLocalizedString("subscription.remove.subscription.cancel", value: "Cancel", comment: "Remove subscription cancel button text")
    public static let subscriptionRemovalConfirmation = NSLocalizedString("subscription.cancel.message", value: "Your subscription has been removed from this device.", comment: "Subscription Removal confirmation message")
    
    // Subscription Restore
    public static let subscriptionActivate = NSLocalizedString("subscription.activate", value: "Activate Subscription", comment: "Subscription Activation Window Title")
    public static let subscriptionActivateTitle = NSLocalizedString("subscription.activate.title", value: "Activate your subscription on this device", comment: "Subscription Activation Title")
    public static let subscriptionActivateDescription = NSLocalizedString("subscription.activate.description", value: "Your subscription is automatically available in DuckDuckGo on any device signed in to your Apple ID.", comment: "Subscription Activation Info")
    public static let subscriptionActivateHeaderDescription = NSLocalizedString("subscription.activate..header.description", value: "Access your Privacy Pro subscription on this device via Apple ID or an email address.", comment: "Subscription Activation Info")
    public static let subscriptionActivateAppleID = NSLocalizedString("subscription.activate.appleid", value: "Apple ID", comment: "Apple ID option for activation")
    public static let subscriptionActivateAppleIDButton = NSLocalizedString("subscription.activate.appleid.button", value: "Restore Purchase", comment: "Button text for restoring purchase via Apple ID")
    public static let subscriptionActivateAppleIDDescription = NSLocalizedString("subscription.activate.appleid.description", value: "Restore your purchase to activate your subscription on this device.", comment: "Description for Apple ID activation")
    public static let subscriptionRestoreAppleID = NSLocalizedString("subscription.activate.restore.apple", value: "Restore Purchase", comment: "Restore button title for AppleID")
    public static let subscriptionActivateEmail = NSLocalizedString("subscription.activate.email", value: "Email", comment: "Email option for activation")
    public static let subscriptionActivateEmailTitle = NSLocalizedString("subscription.activate.email.title", value: "Activate Subscription", comment: "Activate subscription title")
    public static let subscriptionActivateEmailDescription = NSLocalizedString("subscription.activate.email.description", value: "Use your email to activate your subscription on this device.", comment: "Description for Email activation")
    public static let subscriptionAddDeviceEmailDescription = NSLocalizedString("subscription.addDevice.email.description", value: "Add an email address to access your subscription in DuckDuckGo on other devices. We’ll only use this address to verify your subscription.", comment: "Description for Email adding")
    public static let subscriptionAddEmailButton = NSLocalizedString("subscription.activate.add.email.button", value: "Add Email", comment: "Restore button title for Email")
    public static let subscriptionActivateEmailButton = NSLocalizedString("subscription.activate.email.button", value: "Enter Email", comment: "Restore button title for Email")
            
    // Add to other devices (AppleID / Email)
    public static let subscriptionAddDeviceTitle = NSLocalizedString("subscription.add.device.title", value: "Add Device", comment: "Add to another device view title")
    public static let subscriptionAddDeviceHeaderTitle = NSLocalizedString("subscription.add.device.header.title", value: "Use your subscription on other devices", comment: "Add subscription to other device title ")
    public static let subscriptionAddDeviceDescription = NSLocalizedString("subscription.add.device.description", value: "Access your Privacy Pro subscription via an email address.", comment: "Subscription Add device Info")
    public static let subscriptionAvailableInApple = NSLocalizedString("subscription.available.apple", value: "Privacy Pro is available on any device signed in to the same Apple ID.", comment: "Subscription availability message on Apple devices")
    public static let subscriptionManageEmailResendInstructions = NSLocalizedString("subscription.add.device.resend.instructions", value: "Resend Instructions", comment: "Resend activation instructions button")
    
    public static let subscriptionConfirmTitle = NSLocalizedString("subscription.confirm.title", value: "Are you sure?", comment: "Title for Confirm messages")
    public static let subscriptionAlertTitle = NSLocalizedString("subscription.alert.title", value: "", comment: "Title for Alert messages")
    
    // Add Email To subscription
    public static let subscriptionAddEmail = NSLocalizedString("subscription.add.email", value: "Add an email address to activate your subscription on your other devices. We’ll only use this address to verify your subscription.", comment: "Add email to an existing subscription")
    public static let subscriptionRestoreAddEmailButton = NSLocalizedString("subscription.add.email.button", value: "Add Email", comment: "Button title for adding email to subscription")
    public static let subscriptionRestoreAddEmailTitle = NSLocalizedString("subscription.add.email.title", value: "Add Email", comment: "View title for adding email to subscription")
    
    // Manage Subscription Email
    public static let subscriptionManageEmailDescription = NSLocalizedString("subscription.manage.email.description", value: "You can use this email to activate your subscription from browser settings in the DuckDuckGo app on your other devices.", comment: "Description for Email Management options")
    public static let subscriptionManageEmailButton = NSLocalizedString("subscription.activate.manage.email.button", value: "Manage", comment: "Restore button title for Managing Email")
    public static let subscriptionManageEmailTitle = NSLocalizedString("subscription.activate.manage.email.title", value: "Manage Email", comment: "View Title for managing your email account")
    public static let subscriptionManageEmailCancelButton = NSLocalizedString("subscription.activate.manage.email.cancel", value: "Cancel", comment: "Button title for cancelling email deletion")
    public static let subscriptionManageEmailOKButton = NSLocalizedString("subscription.activate.manage.email.OK", value: "OK", comment: "Button title for confirming email deletion")
    
    // Subscribe & Restore Flow
    public static let subscriptionFoundTitle = NSLocalizedString("subscription.found.title", value: "Subscription Found", comment: "Title for the existing subscription dialog")
    public static let subscriptionFoundText = NSLocalizedString("subscription.found.text", value: "We found a subscription associated with this Apple ID.", comment: "Message for the existing subscription dialog")
    public static let subscriptionFoundCancel = NSLocalizedString("subscription.found.cancel", value: "Cancel", comment: "Cancel action for the existing subscription dialog")
    public static let subscriptionFoundRestore = NSLocalizedString("subscription.found.restore", value: "Restore", comment: "Restore action for the existing subscription dialog")
    public static let subscriptionRestoreNotFoundTitle = NSLocalizedString("subscription.notFound.alert.title", value: "Subscription Not Found", comment: "Alert title for not found subscription")
    public static let subscriptionRestoreNotFoundMessage = NSLocalizedString("subscription.notFound.alert.message", value: "There is no subscription associated with this Apple ID.", comment: "Alert content for not found subscription")
    public static let subscriptionRestoreExpiredFoundMessage = NSLocalizedString("subscription.expired.alert.message", value: "The subscription associated with this Apple ID is no longer active.", comment: "Alert content for not found subscription")
    public static let subscriptionRestoreNotFoundPlans = NSLocalizedString("subscription.notFound.view.plans", value: "View Plans", comment: "View plans button text")
    public static let subscriptionRestoreSuccessfulTitle = NSLocalizedString("subscription.restore.success.alert.title", value: "You’re all set.", comment: "Alert title for restored purchase")
    public static let subscriptionRestoreSuccessfulMessage = NSLocalizedString("subscription.restore.success.alert.message", value: "Your purchases have been restored.", comment: "Alert message for restored purchase")
    public static let subscriptionRestoreSuccessfulButton = NSLocalizedString("subscription.restore.success.alert.button", value: "OK", comment: "Alert button text for restored purchase alert")
    
    public static let subscriptionRestoreEmailInactiveTitle = NSLocalizedString("subscription.email.inactive.alert.title", value: "Subscription Not Found", comment: "Alert title for not found subscription")
    public static let subscriptionRestoreEmailInactiveMessage = NSLocalizedString("subscription.email.inactive.alert.message", value: "The subscription associated with this email is no longer active.", comment: "Alert content for not found subscription")
    
    public static let subscriptionAppStoreErrorTitle = NSLocalizedString("subscription.restore.general.error.title", value: "Something Went Wrong", comment: "Alert for general error title")
    public static let subscriptionAppStoreErrorMessage = NSLocalizedString("subscription.restore.general.error.message", value: "The App Store was unable to process your purchase. Please try again later.", comment: "Alert for general error message")
    
    public static let subscriptionBackendErrorTitle = NSLocalizedString("subscription.restore.backend.error.title", value: "Something Went Wrong", comment: "Alert for general error title")
    public static let subscriptionBackendErrorMessage = NSLocalizedString("subscription.restore.backend.error.message", value: "We’re having trouble connecting. Please try again later.", comment: "Alert for general error message")
    public static let subscriptionBackendErrorButton = NSLocalizedString("subscription.restore.backend.error.button", value: "Back to Settings", comment: "Button text for general error message")
    
    public static let subscriptionManageBillingGoogleTitle = NSLocalizedString("subscription.billing.google.title", value: "Subscription Plans", comment: "Title for the manage billing page")
    public static let subscriptionManageBillingGoogleText = NSLocalizedString("subscription.billing.google.text", value: "Your subscription was purchased through the Google Play Store. To renew your subscription, please open Google Play Store subscription settings on a device signed in to the same Google Account used to originally purchase your subscription.", comment: "Text for the manage billing page")
    
    
    // PIR:
    public static let subscriptionPIRHeroText = NSLocalizedString("subscription.pir.hero", value: "Activate Privacy Pro on desktop to set up Personal Information Removal", comment: "Hero Text for Personal information removal")
    public static let subscriptionPIRHeroDetail = NSLocalizedString("subscription.pir.heroText", value: "In the DuckDuckGo browser for desktop, go to %@ and click %@ to get started.", comment: "Description on how to use Personal information removal in desktop. The first placeholder references a location in the Desktop application. <i.e: Settings > Privacy Pro>, and the second, the menu entry. i.e. <I have a Subscription>")
    public static let subscriptionPIRHeroDesktopMenuLocation = NSLocalizedString("subscription.pir.heroTextLocation", value: "Settings > Privacy Pro", comment: "Settings references a menu in the Desktop app, Privacy Pro, references our product name")
    public static let subscriptionPIRHeroDesktopMenuItem = NSLocalizedString("subscription.pir.heroTextMenyEntry", value: "I have a subscription", comment: "Menu item for enabling Personal Information Removal on Desktop")
    public static let subscriptionPIRWindows = NSLocalizedString("subscription.pir.windows", value: "Windows", comment: "Text for the 'Windows' button")
    public static let subscriptionPIRMacOS = NSLocalizedString("subscription.pir.macos", value: "macOS", comment: "Text for the 'macOS' button")
    
}
