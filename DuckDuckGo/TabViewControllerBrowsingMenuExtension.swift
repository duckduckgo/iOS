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
        
        entires.append(BrowsingMenuEntry.regular(name: UserText.actionNewTab, image: UIImage(named: "NewTab")!, action: { [weak self] in
            self?.onNewTabAction()
        }))
        
        entires.append(BrowsingMenuEntry.regular(name: UserText.actionShare, image: UIImage(named: "Share")!, action: { [weak self] in
            guard let self = self else { return }
            guard let menu = self.chromeDelegate?.omniBar.menuButton else { return }
            self.onShareAction(forLink: self.link!, fromView: menu)
        }))
        
        entires.append(BrowsingMenuEntry.regular(name: UserText.actionCopy, image: UIImage(named: "Copy")!, action: { [weak self] in
            self?.onNewTabAction()
        }))
        
        entires.append(BrowsingMenuEntry.regular(name: "Print", image: UIImage(named: "Print")!, action: { [weak self] in
            self?.onNewTabAction()
        }))
        
        return entires
    }
    
    func buildBrowsingMenu() -> [BrowsingMenuEntry] {
        
        var entires = [BrowsingMenuEntry]()
        
        if let link = link, !isError {
            if let entry = buildSaveBookmarkEntry(forLink: link) {
                entires.append(entry)
            }
            
            if let entry = buildSaveFavoriteEntry(forLink: link) {
                entires.append(entry)
            }
            
            entires.append(BrowsingMenuEntry.regular(name: "Bookmarks", image: UIImage(named: "Bookmarks")!, action: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.tabDidRequestBookmarks(tab: strongSelf)
            }))
            
            entires.append(.separator)

            if let entry = buildKeepSignInEntry(forLink: link) {
                entires.append(entry)
            }
            
            let title = tabModel.isDesktop ? UserText.actionRequestMobileSite : UserText.actionRequestDesktopSite
            let image = tabModel.isDesktop ? UIImage(named: "DesktopMode")! : UIImage(named: "MobileMode")!
            entires.append(BrowsingMenuEntry.regular(name: title, image: image, action: { [weak self] in
                self?.onToggleDesktopSiteAction(forUrl: link.url)
            }))
            
            entires.append(buildFindInPageEntry(forLink: link))
        }
        
        if let domain = siteRating?.domain {
            entires.append(buildToggleProtectionEntry(forDomain: domain))
        }
        
        entires.append(BrowsingMenuEntry.regular(name: UserText.actionReportBrokenSite, image: UIImage(named: "Feedback")!, action: { [weak self] in
            self?.onReportBrokenSiteAction()
        }))
        
        entires.append(BrowsingMenuEntry.regular(name: UserText.actionSettings, image: UIImage(named: "Settings")!, action: { [weak self] in
            self?.onBrowsingSettingsAction()
        }))
        
        return entires
    }
    
    private func buildKeepSignInEntry(forLink link: Link) -> BrowsingMenuEntry? {
        guard #available(iOS 13, *) else { return nil }
        guard let domain = link.url.host, !appUrls.isDuckDuckGo(url: link.url) else { return nil }
        guard !PreserveLogins.shared.isAllowed(cookieDomain: domain) else { return nil }
        return BrowsingMenuEntry.regular(name: UserText.preserveLoginsFireproofConfirm, image: UIImage(named: "Fireproof")!, action: { [weak self] in
            self?.fireproofWebsite(domain: domain)
        })
    }
    
    private func onNewTabAction() {
        Pixel.fire(pixel: .browsingMenuNewTab)
        delegate?.tabDidRequestNewTab(self)
    }
    
    private func buildFindInPageEntry(forLink link: Link) -> BrowsingMenuEntry {
        return BrowsingMenuEntry.regular(name: UserText.findInPage, image: UIImage(named: "Find")!, action: { [weak self] in
            Pixel.fire(pixel: .browsingMenuFindInPage)
            self?.requestFindInPage()
        })
    }
    
    private func buildSaveBookmarkEntry(forLink link: Link) -> BrowsingMenuEntry? {
        let bookmarksManager = BookmarksManager()
        guard !bookmarksManager.containsBookmark(url: link.url) else { return nil }
        
        return BrowsingMenuEntry.regular(name: UserText.actionSaveBookmark, image: UIImage(named: "Bookmarks")!, action: { [weak self] in
            Pixel.fire(pixel: .browsingMenuAddToBookmarks)
            bookmarksManager.save(bookmark: link)
            self?.view.showBottomToast(UserText.webSaveBookmarkDone)
        })
    }
    
    private func buildSaveFavoriteEntry(forLink link: Link) -> BrowsingMenuEntry? {
        let bookmarksManager = BookmarksManager()
        guard !bookmarksManager.containsFavorite(url: link.url) else { return nil }

        // Capture flow state here as will be reset after menu is shown
        let addToFavoriteFlow = DaxDialogs.shared.isAddFavoriteFlow

        let title = [
            addToFavoriteFlow ? "👋 " : "",
            UserText.actionSaveFavorite
        ].joined()

        return BrowsingMenuEntry.regular(name: title, image: UIImage(named: "Favorite")!, action: { [weak self] in
            Pixel.fire(pixel: addToFavoriteFlow ? .browsingMenuAddToFavoritesAddFavoriteFlow : .browsingMenuAddToFavorites)
            bookmarksManager.save(favorite: link)
            self?.view.showBottomToast(UserText.webSaveFavoriteDone)
        })
        
        // TODO
//        action.accessibilityLabel = UserText.actionSaveFavorite
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
        let image = isProtected ? UIImage(named: "DisableProtection")! : UIImage(named: "EnableProtection")!
        let operation = isProtected ? manager.add : manager.remove
        
        return BrowsingMenuEntry.regular(name: title, image: image, action: {
            let window = UIApplication.shared.keyWindow
            window?.hideAllToasts()
            
            if isProtected {
               window?.showBottomToast(UserText.toastProtectionDisabled.format(arguments: domain), duration: 1)
            } else {
                window?.showBottomToast(UserText.toastProtectionEnabled.format(arguments: domain), duration: 1)
            }
            
            Pixel.fire(pixel: isProtected ? .browsingMenuDisableProtection : .browsingMenuEnableProtection)
            operation(domain)
        })
    }
}
