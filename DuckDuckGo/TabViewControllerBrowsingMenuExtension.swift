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
    
    func buildBrowsingMenu() -> UIAlertController {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.overrideUserInterfaceStyle()
        alert.addAction(title: UserText.actionNewTab) { [weak self] in
            self?.onNewTabAction()
        }
        
        if let link = link, !isError {
            if let action = buildFindInPageAction(forLink: link) {
                alert.addAction(action)
            }
            
            if let action = buildSaveBookmarkAction(forLink: link) {
                alert.addAction(action)
            }
            
            if let action = buildSaveFavoriteAction(forLink: link) {
                alert.addAction(action)
            }

            if let action = buildKeepSignInAction(forLink: link) {
                alert.addAction(action)
            }

            alert.addAction(title: UserText.actionShare) { [weak self] in
                guard let self = self else { return }
                guard let menu = self.chromeDelegate?.omniBar.menuButton else { return }
                self.onShareAction(forLink: link, fromView: menu)
            }
            
            let title = tabModel.isDesktop ? UserText.actionRequestMobileSite : UserText.actionRequestDesktopSite
            alert.addAction(title: title) { [weak self] in
                self?.onToggleDesktopSiteAction(forUrl: link.url)
            }
        }
        
        if let domain = siteRating?.domain {
            alert.addAction(buildToggleProtectionAction(forDomain: domain))
        }
        
        alert.addAction(title: UserText.actionReportBrokenSite) { [weak self] in
            self?.onReportBrokenSiteAction()
        }
        alert.addAction(title: UserText.actionSettings) { [weak self] in
            self?.onBrowsingSettingsAction()
        }
        alert.addAction(title: UserText.actionCancel, style: .cancel)
        return alert
    }
    
    private func buildKeepSignInAction(forLink link: Link) -> UIAlertAction? {
        guard #available(iOS 13, *) else { return nil }
        guard let domain = link.url.host, !appUrls.isDuckDuckGo(url: link.url) else { return nil }
        guard !PreserveLogins.shared.isAllowed(cookieDomain: domain) else { return nil }
        return UIAlertAction(title: UserText.preserveLoginsFireproofConfirm, style: .default) { [weak self] _ in
            self?.fireproofWebsite(domain: domain)
        }
    }
    
    private func onNewTabAction() {
        Pixel.fire(pixel: .browsingMenuNewTab)
        delegate?.tabDidRequestNewTab(self)
    }
    
    private func buildFindInPageAction(forLink link: Link) -> UIAlertAction? {
        return UIAlertAction(title: UserText.findInPage, style: .default) { [weak self] _ in
            Pixel.fire(pixel: .browsingMenuFindInPage)
            self?.requestFindInPage()
        }
    }
    
    private func buildSaveBookmarkAction(forLink link: Link) -> UIAlertAction? {
        let bookmarksManager = BookmarksManager()
        guard !bookmarksManager.containsBookmark(url: link.url) else { return nil }
        
        return UIAlertAction(title: UserText.actionSaveBookmark, style: .default) { [weak self] _ in
            Pixel.fire(pixel: .browsingMenuAddToBookmarks)
            bookmarksManager.save(bookmark: link)
            self?.view.showBottomToast(UserText.webSaveBookmarkDone)
        }
    }
    
    private func buildSaveFavoriteAction(forLink link: Link) -> UIAlertAction? {
        let bookmarksManager = BookmarksManager()
        guard !bookmarksManager.containsFavorite(url: link.url) else { return nil }

        // Capture flow state here as will be reset after menu is shown
        let addToFavoriteFlow = DaxDialogs.shared.isAddFavoriteFlow

        let title = [
            addToFavoriteFlow ? "👋 " : "",
            UserText.actionSaveFavorite
        ].joined()

        let action = UIAlertAction(title: title, style: .default) { [weak self] _ in
            Pixel.fire(pixel: addToFavoriteFlow ? .browsingMenuAddToFavoritesAddFavoriteFlow : .browsingMenuAddToFavorites)
            bookmarksManager.save(favorite: link)
            self?.view.showBottomToast(UserText.webSaveFavoriteDone)
        }
        action.accessibilityLabel = UserText.actionSaveFavorite
        return action
    }

    func onShareAction(forLink link: Link, fromView view: UIView) {
        Pixel.fire(pixel: .browsingMenuShare)
        let url = appUrls.removeATBAndSource(fromUrl: link.url)
        presentShareSheet(withItems: [ url, link, webView.viewPrintFormatter() ], fromView: view)
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
    
    private func buildToggleProtectionAction(forDomain domain: String) -> UIAlertAction {
        let manager = UnprotectedSitesManager()
        let isProtected = manager.isProtected(domain: domain)
        let title = isProtected ? UserText.actionDisableProtection : UserText.actionEnableProtection
        let operation = isProtected ? manager.add : manager.remove
        
        return UIAlertAction(title: title, style: .default) { _ in
            
            let window = UIApplication.shared.keyWindow
            window?.hideAllToasts()
            
            if isProtected {
               window?.showBottomToast(UserText.toastProtectionDisabled.format(arguments: domain), duration: 1)
            } else {
                window?.showBottomToast(UserText.toastProtectionEnabled.format(arguments: domain), duration: 1)
            }
            
            Pixel.fire(pixel: isProtected ? .browsingMenuDisableProtection : .browsingMenuEnableProtection)
            operation(domain)
        }
    }
}
