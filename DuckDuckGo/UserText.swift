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
    
    public static let autofillSaveLoginTitleNewUser = NSLocalizedString("autofill.save-login.new-user.title", value: "Do you want DuckDuckGo to save your password?", comment: "Title displayed on modal asking for the user to save the login for the first time")
    public static let autofillSaveLoginTitle = NSLocalizedString("autofill.save-login.title", value: "Save Login?", comment: "Title displayed on modal asking for the user to save the login")
    public static let autofillUpdateUsernameTitle = NSLocalizedString("autofill.update-usernamr.title", value: "Update username?", comment: "Title displayed on modal asking for the user to update the username")

    public static let autofillSaveLoginMessageNewUser = NSLocalizedString("autofill.save-login.new-user.message", value: "Passwords are stored securely on your device in the Logins menu.", comment: "Message displayed on modal asking for the user to save the login for the first time")
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
    public static let autofillLoginSavedToastMessage = NSLocalizedString("autofill.login-saved.toast", value: "Login saved", comment: "Message displayed after saving an autofill login")
    public static let autofillLoginUpdatedToastMessage = NSLocalizedString("autofill.login-updated.toast", value: "Login updated", comment: "Message displayed after updating an autofill login")
    public static let autofillLoginSaveToastActionButton = NSLocalizedString("autofill.login-save-action-button.toast", value: "View", comment: "Button displayed after saving/updating an autofill login that takes the user to the saved login")

    public static let autofillKeepEnabledAlertTitle = NSLocalizedString("autofill.keep-enabled.alert.title", value: "Do you want to keep saving Logins?", comment: "Title for alert when asking the user if they want to keep using autofill")
    public static let autofillKeepEnabledAlertMessage = NSLocalizedString("autofill.keep-enabled.alert.message", value: "You can disable this at any time in Settings.", comment: "Message for alert when asking the user if they want to keep using autofill")
    public static let autofillKeepEnabledAlertKeepUsingAction = NSLocalizedString("autofill.keep-enabled.alert.keep-using", value: "Keep Saving", comment: "Confirm action for alert when asking the user if they want to keep using autofill")
    public static let autofillKeepEnabledAlertDisableAction = NSLocalizedString("autofill.keep-enabled.alert.disable", value: "Disable", comment: "Disable action for alert when asking the user if they want to keep using autofill")

    public static let actionAutofillLogins = NSLocalizedString("action.title.autofill.logins", value: "Logins", comment: "Autofill Logins menu item opening the login list")

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
    public static let macWaitlistWindowsComingSoon = NSLocalizedString("mac-waitlist.join-waitlist-screen.windows", value: "Windows coming soon!", comment: "Disclaimer for the Join Waitlist screen")
    public static let macWaitlistWindows = NSLocalizedString("mac-waitlist.join-waitlist-screen.windows-waitlist", value: "Looking for the Windows version?", comment: "Title for the macOS waitlist button redirecting to Windows waitlist")
    public static let macWaitlistCopy = NSLocalizedString("mac-waitlist.copy", value: "Copy", comment: "Title for the copy action")
    public static let macWaitlistShareLink = NSLocalizedString("mac-waitlist.join-waitlist-screen.share-link", value: "Share Link", comment: "Title for the Share Link button")

    // MARK: - Windows Waitlist

    public static let windowsWaitlistTitle = NSLocalizedString("windows-waitlist.title", value: "DuckDuckGo App for Windows", comment: "Title for the Windows Waitlist feature")
    public static let windowsWaitlistSummary = NSLocalizedString("windows-waitlist.summary", value: "DuckDuckGo for Windows has what you need to browse with more privacy — private search, tracker blocking, forced encryption, and cookie pop-up blocking, plus more best-in-class protections on the way.", comment: "Summary text for the Windows browser waitlist")
    public static let windowsWaitlistOnYourComputerGoTo = NSLocalizedString("mac-waitlist.join-waitlist-screen.on-your-computer-go-to", value: "On your Windows computer, go to:", comment: "Description text above the Share Link button")
    public static let windowsWaitlistTryDuckDuckGoForWindowsDownload = NSLocalizedString("windows-waitlist.waitlist-download-screen.try-duckduckgo-for-windows", value: "Get DuckDuckGo for Windows!", comment: "Title for the Windows browser download link page")
    public static let windowsWaitlistTryDuckDuckGoForWindows = NSLocalizedString("windows-waitlist.join-waitlist-screen.try-duckduckgo-for-windows", value: "Get early access to try DuckDuckGo for Windows!", comment: "Title for the Join Windows Waitlist screen")
    public static let windowsWaitlistMac = NSLocalizedString("windows-waitlist.join-waitlist-screen.mac-waitlist", value: "Looking for the Mac version?", comment: "Title for the Windows waitlist button redirecting to Mac waitlist")
    public static let windowsWaitlistBrowsePrivately = NSLocalizedString("windows-waitlist.settings.browse-privately", value: "Browse privately with our app for Windows", comment: "Title for the settings subtitle")

    public static let windowsWaitlistJoinedWithNotifications = NSLocalizedString("windows-waitlist.joined.notifications-enabled",
                                                                                 value: "We’ll send you a notification when your copy of DuckDuckGo for Windows is ready for download.",
                                                                                 comment: "Label text for the Joined Waitlist state with notifications enabled")
    public static let windowsWaitlistJoinedWithoutNotifications = NSLocalizedString("windows-waitlist.joined.notifications-declined",
                                                                                    value: "Your invite to try DuckDuckGo for Windows will arrive here. Check back soon, or we can send you a notification when it’s your turn.",
                                                                                    comment: "Label text for the Joined Waitlist state with notifications declined")
    public static let windowsWaitlistNotifyMeConfirmationMessage = NSLocalizedString("windows-waitlist.joined.no-notification.get-notification-confirmation-message", value: "We’ll send you a notification when your copy of DuckDuckGo for Windows is ready for download. ", comment: "Message for the alert to confirm enabling notifications")
    public static let windowsWaitlistInviteScreenSubtitle = NSLocalizedString("windows-waitlist.invite-screen.subtitle", value: "Ready to use DuckDuckGo on Windows?", comment: "Subtitle for the Windows Waitlist Invite screen")
    public static let windowsWaitlistInviteScreenStep1Description = NSLocalizedString("windows-waitlist.invite-screen.step-1.description", value: "Visit this URL on your Windows device to download:", comment: "Description on the invite screen")
    public static let windowsWaitlistInviteScreenStep2Description = NSLocalizedString("windows-waitlist.invite-screen.step-2.description", value: "Open DuckDuckGo Installer in Downloads, select Install, then enter your invite code.", comment: "Description on the invite screen")
    public static let windowsWaitlistAvailableNotificationTitle = NSLocalizedString("windows-waitlist.available.notification.title", value: "Try DuckDuckGo for Windows!", comment: "Title for the Windows waitlist notification")
    public static func windowsWaitlistShareSheetMessage(code: String) -> String {
        let localized = NSLocalizedString("windows-waitlist.share-sheet.invite-code-message", value: """
            You’re invited!

            Ready to use DuckDuckGo on Windows?

            Step 1
            Visit this URL on your Windows device to download:
            https://duckduckgo.com/windows

            Step 2
            Open DuckDuckGo Installer in Downloads, select Install, then enter your invite code.

            Invite code: %@
            """, comment: "Message used when sharing to iMessage. Parameter is an eight digit invite code.")

        return localized.format(arguments: code)
    }

    
    // MARK: App Tracking Protection
    
    public static let appTPOnboardingTitle1 = NSLocalizedString("appTP.onboarding.title1", value: "One easy step for better app privacy!", comment: "Title for first AppTP onboarding page")
    public static let appTPOnboardingPage1Info1 = NSLocalizedString("appTP.onboarding.page1Info1", value: "Over 85% of free iOS apps", comment: "First part of info on the first AppTP onboarding page")
    public static let appTPOnboardingPage1Info2 = NSLocalizedString("appTP.onboarding.page1Info2", value: " we’ve tested allow other companies to track your personal information, even when you’re sleeping.", comment: "Second part of info on the first AppTP onboarding page (note the leading space)")
    public static let appTPOnboardingPage1Info3 = NSLocalizedString("appTP.onboarding.page1Info3", value: "See who we catch trying to track you in your apps and take back control.", comment: "Third part of info on the first AppTP onboarding page")
    
    public static let appTPOnboardingTitle2 = NSLocalizedString("appTP.onboarding.title2", value: "How does it work?", comment: "Title for second AppTP onboarding page")
    public static let appTPOnboardingPage2Info1 = NSLocalizedString("appTP.onboarding.page2Info1", value: "App Tracking Protection ", comment: "First part of info on the second AppTP onboarding page (note the trailing space)")
    public static let appTPOnboardingPage2Info2 = NSLocalizedString("appTP.onboarding.page2Info2", value: "detects and blocks app trackers from other companies,", comment: "Second part of info on the second AppTP onboarding page")
    public static let appTPOnboardingPage2Info3 = NSLocalizedString("appTP.onboarding.page2Info3", value: " like when Google attempts to track you in a health app.", comment: "Third part of info on the second AppTP onboarding page (note the leading space)")
    public static let appTPOnboardingPage2Info4 = NSLocalizedString("appTP.onboarding.page2Info4", value: "It’s free,", comment: "Fourth part of info on the second AppTP onboarding page")
    public static let appTPOnboardingPage2Info5 = NSLocalizedString("appTP.onboarding.page2Info5", value: " and you can enjoy your apps as you normally would. Working in the background, it helps ", comment: "Fifth part of info on the second AppTP onboarding page (note the leading and trailing space)")
    public static let appTPOnboardingPage2Info6 = NSLocalizedString("appTP.onboarding.page2Info6", value: "protect you night and day.", comment: "Sixth part of info on the second AppTP onboarding page")
    
    public static let appTPOnboardingTitle3 = NSLocalizedString("appTP.onboarding.title3", value: "Who sees your data?", comment: "Title for third AppTP onboarding page")
    public static let appTPOnboardingPage3Info1 = NSLocalizedString("appTP.onboarding.page3Info1", value: "App Tracking Protection is not a VPN.", comment: "First part of info on the third AppTP onboarding page")
    public static let appTPOnboardingPage3Info2 = NSLocalizedString("appTP.onboarding.page3Info2", value: " However, your device will recognize it as one. This is because it uses a local VPN connection to work.", comment: "Second part of info on the third AppTP onboarding page (note the leading space)")
    public static let appTPOnboardingPage3Info3 = NSLocalizedString("appTP.onboarding.page3Info3", value: "App Tracking Protection is different. ", comment: "Third part of info on the third AppTP onboarding page (note the trailing space)")
    public static let appTPOnboardingPage3Info4 = NSLocalizedString("appTP.onboarding.page3Info4", value: "It never routes app data through an external server.", comment: "Fourth part of info on the third AppTP onboarding page")
    
    public static let appTPOnboardingLearnMoreButton = NSLocalizedString("appTP.onboarding.learnMoreButton", value: "Learn More", comment: "Button title for AppTP onboarding to learn more about AppTP")
    public static let appTPOnboardingContinueButton = NSLocalizedString("appTP.onboarding.continueButton", value: "Continue", comment: "Button title for AppTP onboarding")
    public static let appTPOnboardingEnableButton = NSLocalizedString("appTP.onboarding.enableeButton", value: "Enable App Tracking Protection", comment: "Button title for AppTP onboarding to enable AppTP")
    
    public static let appTPAboutNavTitle = NSLocalizedString("appTP.about.navTitle", value: "About App Trackers", comment: "Navigation Title for AppTP about page")
    public static let appTPAboutTitle = NSLocalizedString("appTP.about.title", value: "What Are App Trackers?", comment: "Title for AppTP about page")
    public static let appTPAboutContent1 = NSLocalizedString("appTP.about.content1", value: "You’ve probably heard about companies like Google and Facebook tracking you behind the scenes on third-party websites. But did you know they also track your personal information through apps on your device?\n\nIn 2022, DuckDuckGo found that ", comment: "First part of about page content (note the trailing space)")
    public static let appTPAboutContent2 = NSLocalizedString("appTP.about.content2", value: "over 85% of free iOS apps tested contained hidden trackers from other companies.", comment: "Second part of about page content (note the trailing space)")
    public static let appTPAboutContent3 = NSLocalizedString("appTP.about.content3", value: " Of the 395 apps tested, 60% sent data to Google. This happens even while you’re not using your device.\n\nTrackers in apps may have access to a lot more information than their website tracker cousins, such as your location down to which floor of a building you're on, how often you play games while at work, and when and how long you sleep each day. Even if you haven’t given apps explicit permission to collect data, they can still take it without your knowledge.\n\nTracking networks like Facebook and Google use these little pieces of information to build a digital profile about you. With it, tracking networks can manipulate what you see online and allow advertisers to bid on access to you based on your data.\n\nTrackers in apps is a BIG problem for privacy. But DuckDuckGo has a solution that can help.\n\nWhen enabled in the DuckDuckGo Privacy Browser app, App Tracking Protection blocks many trackers in other apps, not just the trackers we find on websites when you browse. These dual layers of protection reduce what companies know about you overall, so you can use your apps with more peace of mind, knowing you’re more protected.", comment: "Third part of about page content (note the leading space)")
    
    public static let appTPFAQTitle = NSLocalizedString("appTP.faq.title", value: "App Tracking Protection FAQ", comment: "Title for AppTP FAQ page")
    public static let appTPFAQQuestion1 = NSLocalizedString("appTP.faq.question1", value: "How does App Tracking Protection work?", comment: "First question for AppTP FAQ page")
    public static let appTPFAQQuestion2 = NSLocalizedString("appTP.faq.question2", value: "Does App Tracking Protection block trackers in all apps on my device?", comment: "Second question for AppTP FAQ page")
    public static let appTPFAQQuestion3 = NSLocalizedString("appTP.faq.question3", value: "Does App Tracking Protection block all app trackers?", comment: "Third question for AppTP FAQ page")
    public static let appTPFAQQuestion4 = NSLocalizedString("appTP.faq.question4", value: "Why does App Tracking Protection use a VPN connection?", comment: "Fourth question for AppTP FAQ page")
    public static let appTPFAQQuestion5 = NSLocalizedString("appTP.faq.question5", value: "Will App Tracking Protection work if I also use a VPN app?", comment: "Fifth question for AppTP FAQ page")
    public static let appTPFAQQuestion6 = NSLocalizedString("appTP.faq.question6", value: "How is App Tracking Protection different from a VPN?", comment: "Sixth question for AppTP FAQ page")
    public static let appTPFAQQuestion7 = NSLocalizedString("appTP.faq.question7", value: "Is my data private?", comment: "Seventh question for AppTP FAQ page")
    
    public static let appTPFAQAnswer1 = NSLocalizedString("appTP.faq.answer1", value: "App Tracking Protection blocks app trackers from other companies, like when Facebook tries to track you in a banking app. Companies may still track you in apps they own.", comment: "First answer for AppTP FAQ page")
    public static let appTPFAQAnswer2 = NSLocalizedString("appTP.faq.answer2", value: "Yes! App Tracking Protection works across all apps on your device to block the most common hidden trackers we find trying to collect your personal info.", comment: "Second answer for AppTP FAQ page")
    public static let appTPFAQAnswer3 = NSLocalizedString("appTP.faq.answer3", value: "We currently only block the most common trackers that we find on iOS. This helps us to comprehensively test App Tracking Protection and lower frequency of app breakage, while blocking up to 70% of all tracking requests.", comment: "Third answer for AppTP FAQ page")
    public static let appTPFAQAnswer4 = NSLocalizedString("appTP.faq.answer4", value: "You’ll be asked to set up a virtual private network (VPN) connection, but you don't need to install a VPN app for App Tracking Protection to work.\n\nThis permission, which works only on your device, allows App Tracking Protection to monitor network traffic so that it can block known trackers.", comment: "Fourth answer for AppTP FAQ page")
    public static let appTPFAQAnswer5 = NSLocalizedString("appTP.faq.answer5", value: "You can use App Tracking Protection at the same time as using an IKEv2 protocol VPN app on an iOS device. You won’t be able to use App Tracking Protection on an iOS device if you’re using a VPN app that uses a different type of protocol, like WireGuard or OpenVPN type VPNs.", comment: "Fifth answer for AppTP FAQ page")
    public static let appTPFAQAnswer6 = NSLocalizedString("appTP.faq.answer6", value: "A VPN sends your data from the device to its own server, where it secures and anonymizes your data from prying eyes. However, this allows the VPN company to see your network traffic.\n\nApp Tracking Protection is different. Instead of sending your data to a VPN server, App Tracking Protection works only on your device, sitting between your apps and the servers they talk to.\n\nWhenever App Tracking Protection recognizes a known tracker, it blocks the tracker from sending personal information (such as your IP address, activity, and device details) off your device. All other traffic reaches its destination, so your apps work normally.", comment: "Sixth answer for AppTP FAQ page")
    public static let appTPFAQAnswer7 = NSLocalizedString("appTP.faq.answer7", value: "App Tracking Protection works only on your device and doesn’t send your data off your device to DuckDuckGo. We don’t collect or store any data from your apps.", comment: "Seventh answer for AppTP FAQ page")
    
    public static let appTPNavTitle = NSLocalizedString("appTP.title", value: "App Tracking Protection", comment: "Title for the App Tracking Protection feature")
    public static let appTPCellDetail = NSLocalizedString("appTP.cell.detail", value: "Block app trackers on your device", comment: "Detail string describing what AppTP is")
    public static let appTPCellEnabled = NSLocalizedString("appTP.cell.enabled", value: "Enabled", comment: "String indicating AppTP is enabled when viewed from the settings screen")
    public static let appTPCellDisabled = NSLocalizedString("appTP.cell.disabled", value: "Disabled", comment: "String indicating AppTP is disabled when viewed from the settings screen")
    
    public static let appTPEmptyHeading = NSLocalizedString("appTP.empty.enabled.heading", value: "We’re blocking hidden trackers", comment: "Info string informing the user we're looking for trackers in other apps.")
    public static let appTPEmptyDisabledInfo = NSLocalizedString("appTP.empty.disabled.info", value: "Enable App Tracking Protection so we can block pesky trackers in other apps.", comment: "Info string informing the user what App Tracking Protection does.")
    public static let appTPEmptyEnabledInfo = NSLocalizedString("appTP.empty.enabled.info", value: "Come back soon to see a list of all the app trackers we’ve blocked.", comment: "Info string informing the user we're looking for trackers in other apps.")
    
    public static func appTPTrackingAttempts(count: Int32) -> String {
        let message = NSLocalizedString("appTP.trackingattempts", comment: "Do not translate. StringsDict entry -- Subtitle for tracking attempts in App Tracking Protection Activity View. Example: (count) tracking attempts")
        return message.format(arguments: count)
    }
    
    public static func appTPTrackerBlockedTimestamp(timeString: String) -> String {
        let message = NSLocalizedString("appTP.trackerBlockedTimestamp", value: "Last attempt blocked %@", comment: "Text indicating when the tracker was last blocked. Example: Last attempt blocked (timeString)")
        return message.format(arguments: timeString)
    }
    
    public static func appTPTrackerAllowedTimestamp(timeString: String) -> String {
        let message = NSLocalizedString("appTP.trackerAllowedTimestamp", value: "Last attempt allowed %@", comment: "Text indicating when the tracker was last allowed. Example: Last attempt allowed (timeString)")
        return message.format(arguments: timeString)
    }
    
    public static let appTPJustNow = NSLocalizedString("appTP.justNow", value: "just now", comment: "Text indicating the tracking event occured 'just now'. Example: Last attempt 'just now'")
    public static let appTPRestoreDefaults = NSLocalizedString("appTP.restoreDefualts", value: "Restore Defaults", comment: "Button to restore the blocklist to its default state.")
    public static let appTPRestoreDefaultsToast = NSLocalizedString("appTP.restoreDefaultsToast", value: "Default settings restored", comment: "Toast notification diplayed after restoring the blocklist to default settings")
    public static let appTPManageTrackers = NSLocalizedString("appTP.manageTrackers", value: "Manage Trackers", comment: "View to manage trackers for AppTP. Allows the user to turn trackers on or off.")
    public static let appTPBlockTracker = NSLocalizedString("appTP.blockTrackerText", value: "Block this Tracker", comment: "Text label for switch that turns blocking on or off for a tracker")
    
    public static let appTPReportIssueButton = NSLocalizedString("appTP.activityView.reportIssue", value: "Report Issue", comment: "Title for 'Report an Issue' button in the activity view.")
    public static let appTPReportAlertTitle = NSLocalizedString("appTP.reportAlert.title", value: "Report Issue?", comment: "Title for 'Report an Issue' alert.")
    public static let appTPReportAlertMessage = NSLocalizedString("appTP.reportAlert.message", value: "Let us know if you disabled App Tracking Protection for this specific tracker because it caused app issues. Your feedback helps us improve!", comment: "Message for 'Report an Issue' alert.")
    public static let appTPReportAlertConfirm = NSLocalizedString("appTP.reportAlert.confirm", value: "Report Issue", comment: "Confirm button for 'Report an Issue' alert.")
    public static let appTPReportAlertCancel = NSLocalizedString("appTP.reportAlert.cancel", value: "Not Now", comment: "Cancel button for 'Report an Issue' alert.")
    
    public static let appTPReportTitle = NSLocalizedString("appTP.report.title", value: "Report Issue", comment: "Breakage report form title")
    public static let appTPReportCommentPlaceholder = NSLocalizedString("appTP.report.commentPlaceholder", value: "Add additional details", comment: "Breakage report comment placeholder")
    public static let appTPReportCommentLabel = NSLocalizedString("appTP.report.commentLabel", value: "Comments", comment: "Breakage report comment label")
    public static let appTPReportToast = NSLocalizedString("appTP.report.toast", value: "Thank you! Feedback submitted.", comment: "Breakage report succcess message")
    public static let appTPReportAppLabel = NSLocalizedString("appTP.report.appLabel", value: "Which app is having issues?", comment: "Breakage report app name label")
    public static let appTPReportAppPlaceholder = NSLocalizedString("appTP.report.appPlaceholder", value: "App name", comment: "Breakage report app name placeholder")
    public static let appTPReportCategoryLabel = NSLocalizedString("appTP.report.categoryLabel", value: "What’s happening?", comment: "Breakage report category label")
    public static let appTPReportFooter = NSLocalizedString("appTP.report.footer", value: """
In addition to the details entered into this form, your app issue report will contain:
• A list of trackers blocked in the last 10 min
• Whether App Tracking Protection is enabled
• Aggregate DuckDuckGo app diagnostics
""", comment: "Breakage report footer explaining what is collected in the breakage report")
    public static let appTPReportSubmit = NSLocalizedString("appTP.report.submit", value: "Submit", comment: "Breakage report submit button")
    
    public static let appTPHomeBlockedPrefix = NSLocalizedString("appTP.home.blockedPrefix", value: "App Tracking Protection blocked ", comment: "Prefix of string 'App Tracking Protection blocked x tracking attempts today' (note the trailing space)")
    public static let appTPHomeBlockedSuffix = NSLocalizedString("appTP.home.blockedSuffix", value: " in your apps today.", comment: "Prefix of string 'App Tracking Protection blocked x tracking attempts today' (note the leading space)")
    public static func appTPHomeBlockedCount(countString: Int32) -> String {
        let message = NSLocalizedString("appTP.home.blockedCount", comment: "Do not translate. StringsDict entry -- Count part of string 'App Tracking Protection blocked x tracking attempts today'")
        return message.format(arguments: countString)
    }
    
    public static let appTPHomeDisabledPrefix = NSLocalizedString("appTP.home.disabledPrefix", value: "App Tracking Protection disabled. ", comment: "Prefix of string 'App Tracking Protection disabled. Tap to re-enable.' (note the trailing space)")
    public static let appTPHomeDisabledSuffix = NSLocalizedString("appTP.home.disabledSuffix", value: "Tap to continue blocking tracking attempts across your apps.", comment: "Suffix of string 'App Tracking Protection disabled. Tap to re-enable.'")

    // MARK: Network Protection

    public static let netPNavTitle = NSLocalizedString("netP.title", value: "Network Protection", comment: "Title for the Network Protection feature")
    public static let netPCellConnected = NSLocalizedString("netP.cell.connected", value: "Connected", comment: "String indicating NetP is connected when viewed from the settings screen")
    public static let netPCellDisconnected = NSLocalizedString("netP.cell.disconnected", value: "Not connected", comment: "String indicating NetP is disconnected when viewed from the settings screen")

    static let netPInviteTitle = NSLocalizedString("network.protection.invite.dialog.title", value: "You’re invited to try Network Protection", comment: "Title for the network protection invite screen")
    static let netPInviteMessage = NSLocalizedString("network.protection.invite.dialog.message", value: "Enter your invite code to get started.", comment: "Message for the network protection invite dialog")
    static let netPInviteFieldPrompt = NSLocalizedString("network.protection.invite.field.prompt", value: "Invite Code", comment: "Prompt for the network protection invite code text field")
    static let netPInviteSuccessTitle = NSLocalizedString("network.protection.invite.success.title", value: "Success! You’re in.", comment: "Title for the network protection invite success view")
    static let netPInviteSuccessMessage = NSLocalizedString("network.protection.invite.success.message", value: "Hide your location from websites and conceal your online activity from Internet providers and others on your network.", comment: "Message for the network protection invite success view")
    
    static let netPStatusViewTitle = NSLocalizedString("network.protection.status.view.title", value: "Network Protection", comment: "Title label text for the status view when netP is disconnected")
    static let netPStatusHeaderTitleOff = NSLocalizedString("network.protection.status.header.title.off", value: "Network Protection is Off", comment: "Header title label text for the status view when netP is disconnected")
    static let netPStatusHeaderTitleOn = NSLocalizedString("network.protection.status.header.title.on", value: "Network Protection is On", comment: "Header title label text for the status view when netP is connected")
    static let netPStatusHeaderMessage = NSLocalizedString("network.protection.status.header.message", value: "DuckDuckGo's VPN secures all of your device's Internet traffic anytime, anywhere.", comment: "Message label text for the netP status view")
    static let netPStatusDisconnected = NSLocalizedString("network.protection.status.disconnected", value: "Not connected", comment: "The label for the NetP VPN when disconnected")
    static let netPStatusDisconnecting = NSLocalizedString("network.protection.status.disconnecting", value: "Disconnecting...", comment: "The label for the NetP VPN when disconnecting")
    static let netPStatusConnecting = NSLocalizedString("network.protection.status.connecting", value: "Connecting...", comment: "The label for the NetP VPN when connecting")
    static func netPStatusConnected(since timeLapsedString: String) -> String {
        let localized = NSLocalizedString("network.protection.status.connected.format", value: "Connected - %@", comment: "The label for when NetP VPN is connected plus the length of time connected as a formatter HH:MM:SS string")
        return String(format: localized, timeLapsedString)
    }
    static let netPStatusViewLocation = NSLocalizedString("network.protection.status.view.location", value: "Location", comment: "Location label shown in NetworkProtection's status view.")
    static let netPStatusViewIPAddress = NSLocalizedString("network.protection.status.view.ip.address", value: "IP Address", comment: "IP Address label shown in NetworkProtection's status view.")
    static let netPStatusViewConnectionDetails = NSLocalizedString("network.protection.status.view.connection.details", value: "Connection Details", comment: "Connection details label shown in NetworkProtection's status view.")
    static let netPStatusViewSettingsSectionTitle = NSLocalizedString("network.protection.status.view.settings.section.title", value: "Manage", comment: "Label shown on the title of the settings section in NetworkProtection's status view.")
    static let netPVPNSettingsTitle = NSLocalizedString("network.protection.vpn.settings.title", value: "VPN Settings", comment: "Title for the VPN Settings screen.")
    static func netPVPNSettingsLocationSubtitleFormattedCityAndCountry(city: String, country: String) -> String {
        let localized = NSLocalizedString("network.protection.vpn.location.subtitle.formatted.city.and.country", value: "%@, %@", comment: "Subtitle for the preferred location item that formats a city and country. E.g Chicago, United States")
        return localized.format(arguments: city, country)
    }
    static let netPVPNNotificationsTitle = NSLocalizedString("network.protection.vpn.notifications.title", value: "VPN Notifications", comment: "Title for the VPN Notifications management screen.")
    static let netPStatusViewShareFeedback = NSLocalizedString("network.protection.status.menu.share.feedback", value: "Share Feedback", comment: "The status view 'Share Feedback' button which is shown inline on the status view after the temporary free use footer text")
    static let netPStatusViewErrorConnectionFailedTitle = NSLocalizedString("network.protection.status.view.error.connection.failed.title", value: "Failed to Connect.", comment: "Generic connection failed error title shown in NetworkProtection's status view.")
    static let netPStatusViewErrorConnectionFailedMessage = NSLocalizedString("network.protection.status.view.error.connection.failed.message", value: "Please try again later.", comment: "Generic connection failed error message shown in NetworkProtection's status view.")
    static let netPPreferredLocationSettingTitle = NSLocalizedString("network.protection.vpn.preferred.location.title", value: "Preferred Location", comment: "Title for the Preferred Location VPN Settings item.")
    static let netPPreferredLocationNearest = NSLocalizedString("network.protection.vpn.preferred.location.nearest", value: "Nearest Available", comment: "Label for the Preferred Location VPN Settings item when the nearest available location is selected.")
    static let netPVPNLocationTitle = NSLocalizedString("network.protection.vpn.location.title", value: "VPN Location", comment: "Title for the VPN Location screen.")
    static let netPVPNLocationRecommendedSectionTitle = NSLocalizedString("network.protection.vpn.location.recommended.section.title", value: "Recommended", comment: "Title for the VPN Location screen's Recommended section.")
    static let netPVPNLocationRecommendedSectionFooter = NSLocalizedString("network.protection.vpn.location.recommended.section.footer", value: "Automatically connect to the nearest server we can find.", comment: "Footer describing the VPN Location screen's Recommended section which just has Nearest Available.")
    static let netPVPNLocationAllCountriesSectionTitle = NSLocalizedString("network.protection.vpn.location.all.countries.section.title", value: "All Countries", comment: "Title for the VPN Location screen's All Countries section.")
    static let netPVPNLocationNearestAvailableItemTitle = NSLocalizedString("network.protection.vpn.location.nearest.available.item.title", value: "Nearest Available", comment: "Title for the VPN Location screen's Nearest Available selection item.")
    static func netPVPNLocationCountryItemFormattedCitiesCount(_ count: Int) -> String {
        let message = NSLocalizedString("network.protection.vpn.location.country.item.formatted.cities.count", value: "%d cities", comment: "Subtitle of countries item when there are multiple cities, example : ")
        return message.format(arguments: count)
    }
    static let netPExcludeLocalNetworksSettingTitle = NSLocalizedString("network.protection.vpn.exclude.local.networks.setting.title", value: "Exclude Local Networks", comment: "Title for the Exclude Local Networks setting item.")
    static let netPExcludeLocalNetworksSettingFooter = NSLocalizedString("network.protection.vpn.exclude.local.networks.setting.footer", value: "Let local traffic bypass the VPN and connect to devices on your local network, like a printer.", comment: "Footer text for the Exclude Local Networks setting item.")
    static let netPSecureDNSSettingFooter = NSLocalizedString("network.protection.vpn.secure.dns.setting.footer", value: "Our VPN uses Secure DNS to keep your online activity private, so that your Internet provider can't see what websites you visit.", comment: "Footer text for the Always on VPN setting item.")
    static let netPTurnOnNotificationsButtonTitle = NSLocalizedString("network.protection.turn.on.notifications.button.title", value: "Turn On Notifications", comment: "Title for the button to link to the iOS app settings and enable notifications app-wide.")
    static let netPTurnOnNotificationsSectionFooter = NSLocalizedString("network.protection.turn.on.notifications.section.footer", value: "Allow DuckDuckGo to notify you if your connection drops or VPN status changes.", comment: "Footer text under the button to link to the iOS app settings and enable notifications app-wide.")
    static let netPVPNAlertsToggleTitle = NSLocalizedString("network.protection.vpn.alerts.toggle.title", value: "VPN Alerts", comment: "Title for the toggle for VPN alerts.")
    static let netPVPNAlertsToggleSectionFooter = NSLocalizedString("network.protection.vpn.alerts.toggle.section.footer", value: "Get notified if your connection drops or VPN status changes.", comment: "List section footer for the toggle for VPN alerts.")

    static let netPOpenVPNQuickAction = NSLocalizedString("network.protection.quick-action.open-vpn", value: "Open VPN", comment: "Title text for an iOS quick action that opens VPN settings")

    static let inviteDialogContinueButton = NSLocalizedString("invite.dialog.continue.button", value: "Continue", comment: "Continue button on an invite dialog")
    static let inviteDialogGetStartedButton = NSLocalizedString("invite.dialog.get.started.button", value: "Get Started", comment: "Get Started button on an invite dialog")
    static let inviteDialogUnrecognizedCodeMessage = NSLocalizedString("invite.dialog.unrecognized.code.message", value: "We didn’t recognize this Invite Code.", comment: "Message to show after user enters an unrecognized invite code")
    static let inviteDialogErrorAlertOKButton = NSLocalizedString("invite.alert.ok.button", value: "OK", comment: "OK title for invite screen alert dismissal button")


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

    public static let autofillLoginDetailsLoginName = NSLocalizedString("autofill.logins.details.login-name", value:"Login Title", comment: "Login name label for login details on autofill")
    public static let autofillLoginDetailsUsername = NSLocalizedString("autofill.logins.details.username", value:"Username", comment: "Username label for login details on autofill")
    public static let autofillLoginDetailsPassword = NSLocalizedString("autofill.logins.details.password", value:"Password", comment: "Password label for login details on autofill")
    
    public static let autofillLoginDetailsAddress = NSLocalizedString("autofill.logins.details.address", value:"Website URL", comment: "Address label for login details on autofill")
    public static let autofillLoginDetailsNotes = NSLocalizedString("autofill.logins.details.notes", value:"Notes", comment: "Notes label for login details on autofill")
    public static let autofillEmptyViewTitle = NSLocalizedString("autofill.logins.empty-view.title", value:"No Logins saved yet", comment: "Title for view displayed when autofill has no items")
    public static let autofillEmptyViewSubtitle = NSLocalizedString("autofill.logins.empty-view.subtitle", value:"Logins are stored securely on your device.", comment: "Subtitle for view displayed when autofill has no items")
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

    public static let autofillEnableSettings = NSLocalizedString("autofill.logins.list.enable", value:"Save and Autofill Logins", comment: "Title for a toggle that enables autofill")
    public static let autofillNeverSavedSettings = NSLocalizedString("autofill.logins.list.never.saved", value:"Reset Excluded Sites", comment: "Title for a button that allows a user to reset their list of never saved sites")
    public static let autofillLoginListTitle = NSLocalizedString("autofill.logins.list.title", value:"Logins", comment: "Title for screen listing autofill logins")
    public static let autofillLoginListSearchPlaceholder = NSLocalizedString("autofill.logins.list.search-placeholder", value:"Search Logins", comment: "Placeholder for search field on autofill login listing")
    public static let autofillLoginListSuggested = NSLocalizedString("autofill.logins.list.suggested", value:"Suggested", comment: "Section title for group of suggested saved logins")

    public static let autofillResetNeverSavedActionTitle = NSLocalizedString("autofill.logins.list.never.saved.reset.action.title", value:"If you reset excluded sites, you will be prompted to save your Login next time you sign in to any of these sites.", comment: "Alert title")
    public static let autofillResetNeverSavedActionConfirmButton = NSLocalizedString("autofill.logins.list.never.saved.reset.action.confirm", value: "Reset Excluded Sites", comment: "Confirm button to reset list of never saved sites")
    public static let autofillResetNeverSavedActionCancelButton = NSLocalizedString("autofill.logins.list.never.saved.reset.action.cancel", value: "Cancel", comment: "Cancel button for resetting list of never saved sites")

    public static let autofillLoginPromptAuthenticationCancelButton = NSLocalizedString("autofill.logins.prompt.auth.cancel", value:"Cancel", comment: "Cancel button for auth during login prompt")
    public static let autofillLoginPromptAuthenticationReason = NSLocalizedString("autofill.logins.prompt.auth.reason", value:"Unlock To Use Saved Login", comment: "Reason for auth during login prompt")
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

    public static let autofillNoAuthViewTitle = NSLocalizedString("autofill.logins.no-auth.title", value:"Secure your device to save Logins", comment: "Title for view displayed when autofill is locked on devices where a passcode has not been set")
    public static let autofillNoAuthViewSubtitle = NSLocalizedString("autofill.logins.no-auth.subtitle", value:"A passcode is required to protect your Logins.", comment: "Title for view displayed when autofill is locked on devices where a passcode has not been set")

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
    public static let autofillLoginListAuthenticationReason = NSLocalizedString("autofill.logins.list.auth.reason", value:"Unlock device to access saved Logins", comment: "Reason for auth when opening login list")
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
    public static let autofillLoginListLoginDeletedToastMessageNoTitle = NSLocalizedString("autofill.logins.list.login-deleted-message-no-title", value: "Login deleted", comment: "Toast message when a login item without a title is deleted")

    public static let autofillLoginDetailsEditTitlePlaceholder = NSLocalizedString("autofill.logins.details.edit.title-placeholder", value:"Title", comment: "Placeholder for title field on autofill login details")
    public static let autofillLoginDetailsEditUsernamePlaceholder = NSLocalizedString("autofill.logins.details.edit.username-placeholder", value:"username@example.com", comment: "Placeholder for userbane field on autofill login details")
    public static let autofillLoginDetailsEditPasswordPlaceholder = NSLocalizedString("autofill.logins.details.edit.password-placeholder", value:"Password", comment: "Placeholder for password field on autofill login details")
    public static let autofillLoginDetailsEditURLPlaceholder = NSLocalizedString("autofill.logins.details.edit.url-placeholder", value:"example.com", comment: "Placeholder for url field on autofill login details")

    public static let autofillLoginDetailsSaveDuplicateLoginAlertTitle = NSLocalizedString("autofill.logins.details.save-duplicate-alert.title", value:"Duplicated Login", comment: "Title for alert when attempting to save a duplicate login")
    public static let autofillLoginDetailsSaveDuplicateLoginAlertMessage = NSLocalizedString("autofill.logins.details.save-duplicate-alert.message", value:"You already have a login for this username and website.", comment: "Message for alert when attempting to save a duplicate login")
    public static let autofillLoginDetailsSaveDuplicateLoginAlertAction = NSLocalizedString("autofill.logins.details.save-duplicate-alert.action", value:"OK", comment: "Action text for alert when attempting to save a duplicate login")

    public static let autofillNavigationButtonItemTitleClose = NSLocalizedString("autofill.logins.list.close-title", value:"Close", comment: "Title for close navigation button")

    // Autofill Password Generation Prompt
    public static let autofillPasswordGenerationPromptTitle = NSLocalizedString("autofill.password-generation-prompt.title", value:"Use a strong password from DuckDuckGo?", comment: "Title for prompt to use suggested strong password for creating a login")
    public static let autofillPasswordGenerationPromptSubtitle = NSLocalizedString("autofill.password-generation-prompt.subtitle", value:"Passwords are stored securely on your device in the Logins menu.", comment: "Subtitle for prompt to use suggested strong password for creating a login")
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

    // MARK: Dax Dialog

    public static let daxDialogCookieConsentFirst = NSLocalizedString("dax.cookie-consent.first", value:"Looks like this site has a cookie consent pop-up👇", comment: "First part of text displayed on Dax dialog for enabling Autoconsent for Cookie Management feature")
    public static let daxDialogCookieConsentSecond = NSLocalizedString("dax.cookie-consent.second", value:"Want me to handle these for you? I can try to minimize cookies, maximize privacy, and hide pop-ups like these.", comment: "Second part of text displayed on Dax dialog for enabling Autoconsent for Cookie Management feature")

    public static let daxDialogCookieConsentAcceptButton = NSLocalizedString("dax.cookie-consent.button.accept", value:"Manage Cookie Pop-ups", comment: "Button title accepting to enable feature to automatically manage cookie popups")
    public static let daxDialogCookieConsentRejectButton = NSLocalizedString("dax.cookie-consent.button.reject", value:"No Thanks", comment: "Button title rejecting to enable feature to automatically manage cookie popups")

    // MARK: Sync

    public static let syncTurnOffConfirmTitle = "Turn Off Sync?"
    public static let syncTurnOffConfirmMessage = "This Device will no longer be able to access your synced data."
    public static let syncTurnOffConfirmAction = "Remove"
    public static let syncDeleteAllConfirmTitle = "Delete Server Data?"
    public static let syncDeleteAllConfirmMessage = "All devices will be disconnected and your synced data will be deleted from the server."
    public static let syncDeleteAllConfirmAction = "Delete Server Data"
    public static let syncRemoveDeviceTitle = "Remove Device?"
    public static func syncRemoveDeviceMessage(_ deviceName: String) -> String {
        let message = NSLocalizedString("sync.remove-device.message", value: "\"%@\" will no longer be able to access your synced data.", comment: "")
        return message.format(arguments: deviceName)
    }
    public static let syncRemoveDeviceConfirmAction = "Remove"
    public static let syncCodeCopied = "Recovery Code copied"
    public static let syncTitle = "Sync & Backup"

    // MARK: Errors

    static let unknownErrorTryAgainMessage = NSLocalizedString("error.unknown.try.again", value: "An unknown error has occurred", comment: "Generic error message on a dialog for when the cause is not known.")
    static let syncBookmarkPausedAlertTitle = NSLocalizedString("alert.sync-bookmarks-paused-title", value: "Bookmarks Sync is Paused", comment: "Title for alert shown when sync bookmarks paused for too many items")
    static let syncBookmarkPausedAlertDescription = NSLocalizedString("alert.sync-bookmarks-paused-description", value: "You have exceeded the bookmarks sync limit. Try deleting some bookmarks. Until this is resolved your bookmarks will not be backed up.", comment: "Description for alert shown when sync bookmarks paused for too many items")
    static let syncCredentialsPausedAlertTitle = NSLocalizedString("alert.sync-credentials-paused-title", value: "Passwords Sync is Paused", comment: "Title for alert shown when sync credentials paused for too many items")
    static let syncCredentialsPausedAlertDescription = NSLocalizedString("alert.sync-credentials-paused-description", value: "You have exceeded the passwords sync limit. Try deleting some passwords. Until this is resolved your passwords will not be backed up.", comment: "Description for alert shown when sync credentials paused for too many items")
    public static let syncPausedAlertOkButton = NSLocalizedString("alert.sync-paused-alert-ok-button", value: "OK", comment: "Confirmation button in alert")
    public static let syncPausedAlertLearnMoreButton = NSLocalizedString("alert.sync-paused-alert-learn-more-button", value: "Learn More", comment: "Learn more button in alert")

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

    static let networkProtectionWaitlistJoinSubtitle1 = NSLocalizedString("network-protection.waitlist.join.subtitle.1", value: "Secure your connection anytime, anywhere with Network Protection, the VPN from DuckDuckGo.", comment: "First subtitle for Network Protection join waitlist screen")
    static let networkProtectionWaitlistJoinSubtitle2 = NSLocalizedString("network-protection.waitlist.join.subtitle.2", value: "Join the waitlist, and we’ll notify you when it’s your turn.", comment: "Second subtitle for Network Protection join waitlist screen")

    static let networkProtectionWaitlistJoinedTitle = NSLocalizedString("network-protection.waitlist.joined.title", value: "You’re on the list!", comment: "Title for Network Protection joined waitlist screen")
    static let networkProtectionWaitlistJoinedWithNotificationsSubtitle1 = NSLocalizedString("network-protection.waitlist.joined.with-notifications.subtitle.1", value: "New invites are sent every few days, on a first come, first served basis.", comment: "Subtitle 1 for Network Protection joined waitlist screen when notifications are enabled")
    static let networkProtectionWaitlistJoinedWithNotificationsSubtitle2 = NSLocalizedString("network-protection.waitlist.joined.with-notifications.subtitle.2", value: "We’ll notify you when your invite is ready.", comment: "Subtitle 2 for Network Protection joined waitlist screen when notifications are enabled")

    static let networkProtectionWaitlistNotificationTitle = NSLocalizedString("network-protection.waitlist.notification.title", value: "Network Protection is ready!", comment: "Title for Network Protection waitlist notification")
    static let networkProtectionWaitlistNotificationText = NSLocalizedString("network-protection.waitlist.notification.text", value: "Open your invite", comment: "Title for Network Protection waitlist notification")

    static let networkProtectionWaitlistInvitedTitle = NSLocalizedString("network-protection.waitlist.invited.title", value: "You’re invited to try\nNetwork Protection early access!", comment: "Title for Network Protection invited screen")
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

    static let networkProtectionWaitlistAvailabilityDisclaimer = NSLocalizedString("network-protection.waitlist.availability-disclaimer", value: "Network Protection is free to use during early access.", comment: "Availability disclaimer for Network Protection join waitlist screen")

    static let networkProtectionPrivacyPolicyTitle = NSLocalizedString("network-protection.privacy-policy.title", value: "Privacy Policy", comment: "Privacy Policy title for Network Protection")

    static let networkProtectionWaitlistNotificationAlertDescription = NSLocalizedString("network-protection.waitlist.notification-alert.description", value: "We’ll send you a notification when your invite to test Network Protection is ready.", comment: "Body text for the alert to enable notifications")

    static let networkProtectionWaitlistGetStarted = NSLocalizedString("network-protection.waitlist.get-started", value: "Get Started", comment: "Button title text for the Network Protection waitlist confirmation prompt")
    static let networkProtectionWaitlistAgreeAndContinue = NSLocalizedString("network-protection.waitlist.agree-and-continue", value: "Agree and Continue", comment: "Title text for the Network Protection terms and conditions accept button")

    static let networkProtectionSettingsSubtitleNotJoined = NSLocalizedString("network-protection.waitlist.settings-subtitle.waitlist-not-joined", value: "Join the private waitlist", comment: "Subtitle text for the Network Protection settings row")
    static let networkProtectionSettingsSubtitleJoinedButNotInvited = NSLocalizedString("network-protection.waitlist.settings-subtitle.joined-but-not-invited", value: "You’re on the list!", comment: "Subtitle text for the Network Protection settings row")
    static let networkProtectionSettingsSubtitleJoinedAndInvited = NSLocalizedString("network-protection.waitlist.settings-subtitle.joined-and-invited", value: "Your invite is ready!", comment: "Subtitle text for the Network Protection settings row")

    static let networkProtectionNotificationPromptTitle = NSLocalizedString("network-protection.waitlist.notification-prompt-title", value: "Know the instant you're invited", comment: "Title for the alert to confirm enabling notifications")
    static let networkProtectionNotificationPromptDescription = NSLocalizedString("network-protection.waitlist.notification-prompt-description", value: "Get a notification when your copy of Network Protection early access is ready.", comment: "Subtitle for the alert to confirm enabling notifications")
}
