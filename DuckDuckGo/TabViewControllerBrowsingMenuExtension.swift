//
//  TabViewControllerBrowsingMenuExtension.swift
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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

import UIKit
import Core

extension TabViewController {
    
    func buildBrowsingMenuHeaderContent() -> [BrowsingMenuEntry] {
        
        var entires = [BrowsingMenuEntry]()
        
        entires.append(BrowsingMenuEntry.regular(name: UserText.actionNewTab, image: UIImage(named: "MenuNewTab")!, action: { [weak self] in
            self?.onNewTabAction()
        }))
        
        entires.append(BrowsingMenuEntry.regular(name: UserText.actionShare, image: UIImage(named: "MenuShare")!, action: { [weak self] in
            guard let self = self else { return }
            guard let menu = self.chromeDelegate?.omniBar.menuButton else { return }
            self.onShareAction(forLink: self.link!, fromView: menu)
        }))
        
        entires.append(BrowsingMenuEntry.regular(name: UserText.actionCopy, image: UIImage(named: "MenuCopy")!, action: { [weak self] in
            guard let url = self?.webView.url else { return }
            
            self?.onCopyAction(forUrl: url)
            ActionMessageView.present(message: UserText.actionCopyMessage)
        }))
        
        entires.append(BrowsingMenuEntry.regular(name: UserText.actionPrint, image: UIImage(named: "MenuPrint")!, action: { [weak self] in
            self?.print()
        }))
        
        return entires
    }
    
    var favoriteEntryIndex: Int { 1 }
    
    func buildBrowsingMenu() -> [BrowsingMenuEntry] {
        
        var entires = [BrowsingMenuEntry]()
        
        if let link = link, !isError {
            if let entry = buildBookmarkEntry(for: link) {
                entires.append(entry)
            }
            
            if let entry = buildFavoriteEntry(for: link) {
                assert(favoriteEntryIndex == entires.count, "Entry index should be in sync with entry placement")
                entires.append(entry)
            }
            
            entires.append(BrowsingMenuEntry.regular(name: UserText.actionOpenBookmarks,
                                                     image: UIImage(named: "MenuBookmarks")!,
                                                     action: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.tabDidRequestBookmarks(tab: strongSelf)
            }))
            
            entires.append(.separator)

            if let entry = buildKeepSignInEntry(forLink: link) {
                entires.append(entry)
            }
            
            let title = tabModel.isDesktop ? UserText.actionRequestMobileSite : UserText.actionRequestDesktopSite
            let image = tabModel.isDesktop ? UIImage(named: "MenuMobileMode")! : UIImage(named: "MenuDesktopMode")!
            entires.append(BrowsingMenuEntry.regular(name: title, image: image, action: { [weak self] in
                self?.onToggleDesktopSiteAction(forUrl: link.url)
            }))
            
            entires.append(buildFindInPageEntry(forLink: link))
        }
        
        if let domain = siteRating?.domain {
            entires.append(buildToggleProtectionEntry(forDomain: domain))
        }
        
        entires.append(BrowsingMenuEntry.regular(name: UserText.actionReportBrokenSite,
                                                 image: UIImage(named: "MenuFeedback")!,
                                                 action: { [weak self] in
            self?.onReportBrokenSiteAction()
        }))
        
        entires.append(BrowsingMenuEntry.regular(name: UserText.actionSettings,
                                                 image: UIImage(named: "MenuSettings")!,
                                                 action: { [weak self] in
            self?.onBrowsingSettingsAction()
        }))
        
        return entires
    }
    
    private func buildKeepSignInEntry(forLink link: Link) -> BrowsingMenuEntry? {
        guard #available(iOS 13, *) else { return nil }
        guard let domain = link.url.host, !appUrls.isDuckDuckGo(url: link.url) else { return nil }
        let isFireproofed = PreserveLogins.shared.isAllowed(cookieDomain: domain)
        
        if isFireproofed {
            return BrowsingMenuEntry.regular(name: UserText.disablePreservingLogins,
                                             image: UIImage(named: "MenuRemoveFireproof")!,
                                             action: { [weak self] in
                                                self?.disableFireproofingForDomain(domain)
                                             })
        } else {
            return BrowsingMenuEntry.regular(name: UserText.enablePreservingLogins,
                                             image: UIImage(named: "MenuFireproof")!,
                                             action: { [weak self] in
                                                self?.enableFireproofingForDomain(domain)
                                             })
        }

    }
    
    private func onNewTabAction() {
        Pixel.fire(pixel: .browsingMenuNewTab)
        delegate?.tabDidRequestNewTab(self)
    }
    
    private func buildFindInPageEntry(forLink link: Link) -> BrowsingMenuEntry {
        return BrowsingMenuEntry.regular(name: UserText.findInPage, image: UIImage(named: "MenuFind")!, action: { [weak self] in
            Pixel.fire(pixel: .browsingMenuFindInPage)
            self?.requestFindInPage()
        })
    }
    
    private func buildBookmarkEntry(for link: Link) -> BrowsingMenuEntry? {
        
        let bookmarksManager = BookmarksManager()
        let isBookmark = bookmarksManager.containsBookmark(url: link.url)
        if isBookmark {
            return BrowsingMenuEntry.regular(name: UserText.actionEditBookmark,
                                             image: UIImage(named: "MenuBookmarkSolid")!,
                                             action: { [weak self] in
                                                self?.performEditBookmarkAction(for: link)
                                             })
        } else {
            return BrowsingMenuEntry.regular(name: UserText.actionSaveBookmark,
                                             image: UIImage(named: "MenuBookmark")!,
                                             action: { [weak self] in
                                                self?.performSaveBookmarkAction(for: link)
                                             })
        }
    }
    
    private func performSaveBookmarkAction(for link: Link) {
        Pixel.fire(pixel: .browsingMenuAddToBookmarks)
        
        BookmarksManager().save(bookmark: link)
        
        ActionMessageView.present(message: UserText.webSaveBookmarkDone,
                                  actionTitle: UserText.actionGenericEdit) {
            self.performEditBookmarkAction(for: link)
        }
    }
    
    private func performEditBookmarkAction(for link: Link) {
        Pixel.fire(pixel: .browsingMenuEditBookmark)
        
        delegate?.tabDidRequestEditBookmark(tab: self)
    }
    
    private func buildFavoriteEntry(for link: Link) -> BrowsingMenuEntry? {
        let bookmarksManager = BookmarksManager()
        let isFavorite = bookmarksManager.containsFavorite(url: link.url)
        
        if isFavorite {
            
            let action: () -> Void = { [weak self] in
                Pixel.fire(pixel: .browsingMenuRemoveFromFavorites)
                self?.performRemoveFavoriteAction(for: link)
            }
            
            return BrowsingMenuEntry.regular(name: UserText.actionRemoveFavorite,
                                             image: UIImage(named: "MenuFavoriteSolid")!,
                                             action: action)
                                                
        } else {
            // Capture flow state here as will be reset after menu is shown
            let addToFavoriteFlow = DaxDialogs.shared.isAddFavoriteFlow

            return BrowsingMenuEntry.regular(name: UserText.actionSaveFavorite, image: UIImage(named: "MenuFavorite")!, action: { [weak self] in
                Pixel.fire(pixel: addToFavoriteFlow ? .browsingMenuAddToFavoritesAddFavoriteFlow : .browsingMenuAddToFavorites)
                self?.performSaveFavoriteAction(for: link)
            })
        }
    }
    
    private func performSaveFavoriteAction(for link: Link) {
        let bookmarksManager = BookmarksManager()
        bookmarksManager.save(favorite: link)
        
        ActionMessageView.present(message: UserText.webSaveFavoriteDone, actionTitle: UserText.actionGenericUndo) {
            self.performRemoveFavoriteAction(for: link)
        }
    }
    
    private func performRemoveFavoriteAction(for link: Link) {
        let bookmarksManager = BookmarksManager()
        guard let index = bookmarksManager.indexOfFavorite(url: link.url) else { return }
        
        bookmarksManager.deleteFavorite(at: index)
        
        ActionMessageView.present(message: UserText.webFavoriteRemoved, actionTitle: UserText.actionGenericUndo) {
            self.performSaveFavoriteAction(for: link)
        }
    }

    func onShareAction(forLink link: Link, fromView view: UIView) {
        Pixel.fire(pixel: .browsingMenuShare)
        presentShareSheet(withItems: [ link, webView.viewPrintFormatter() ], fromView: view)
    }
    
    private func onToggleDesktopSiteAction(forUrl url: URL) {
        Pixel.fire(pixel: .browsingMenuToggleBrowsingMode)
        tabModel.toggleDesktopMode()
        updateContentMode()
        tabModel.isDesktop ? load(url: url.toDesktopUrl()) : reload(scripts: false)
    }
    
    private func onReportBrokenSiteAction() {
        Pixel.fire(pixel: .browsingMenuReportBrokenSite)
        delegate?.tabDidRequestReportBrokenSite(tab: self)
    }
    
    private func onBrowsingSettingsAction() {
        Pixel.fire(pixel: .browsingMenuSettings)
        delegate?.tabDidRequestSettings(tab: self)
    }
    
    private func buildToggleProtectionEntry(forDomain domain: String) -> BrowsingMenuEntry {
        let manager = UnprotectedSitesManager()
        let isProtected = manager.isProtected(domain: domain)
        let title = isProtected ? UserText.actionDisableProtection : UserText.actionEnableProtection
        let image = isProtected ? UIImage(named: "MenuDisableProtection")! : UIImage(named: "MenuEnableProtection")!
    
        return BrowsingMenuEntry.regular(name: title, image: image, action: { [weak self] in
            Pixel.fire(pixel: isProtected ? .browsingMenuDisableProtection : .browsingMenuEnableProtection)
            self?.togglePrivacyProtection(manager: manager, domain: domain)
        })
    }
    
    private func togglePrivacyProtection(manager: UnprotectedSitesManager, domain: String) {
        let isProtected = manager.isProtected(domain: domain)
        let operation = isProtected ? manager.add : manager.remove
        
        operation(domain)
        
        let message: String
        if isProtected {
            message = UserText.messageProtectionDisabled.format(arguments: domain)
        } else {
            message = UserText.messageProtectionEnabled.format(arguments: domain)
        }
        
        ActionMessageView.present(message: message, actionTitle: UserText.actionGenericUndo) { [weak self] in
            self?.togglePrivacyProtection(manager: manager, domain: domain)
        }
    }
}
