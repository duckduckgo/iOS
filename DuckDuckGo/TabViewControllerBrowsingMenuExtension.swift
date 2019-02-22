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
        alert.addAction(title: UserText.actionRefresh) { [weak self] in
            self?.onRefreshAction()
        }
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

            alert.addAction(title: UserText.actionShare) { [weak self] in
                self?.onShareAction(forLink: link)
            }
            
            let title = tabModel.isDesktop ? UserText.actionRequestMobileSite : UserText.actionRequestDesktopSite
            alert.addAction(title: title) { [weak self] in
                self?.onToggleDesktopSiteAction(forUrl: link.url)
            }
        }
        
        if let domain = siteRating?.domain {
            alert.addAction(buildWhitelistAction(forDomain: domain))
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
    
    private func onRefreshAction() {
        Pixel.fire(pixel: .browsingMenuRefresh)
        if isError {
            if let url = URL(string: chromeDelegate?.omniBar.textField.text ?? "") {
                load(url: url)
            }
        } else {
            reload(scripts: false)
        }
    }
    
    private func onNewTabAction() {
        Pixel.fire(pixel: .browsingMenuNewTab)
        delegate?.tabDidRequestNewTab(self)
    }
    
    private func buildFindInPageAction(forLink link: Link) -> UIAlertAction? {
        return UIAlertAction(title: UserText.findInPage, style: .default) { [weak self] _ in
            
            self?.requestFindInPage()
        }
    }
    
    private func buildSaveBookmarkAction(forLink link: Link) -> UIAlertAction? {
        let bookmarksManager = BookmarksManager()
        guard !bookmarksManager.contains(url: link.url) else { return nil }
        
        return UIAlertAction(title: UserText.actionSaveBookmark, style: .default) { [weak self] _ in
            Pixel.fire(pixel: .browsingMenuAddToBookmarks)
            let saveCompletion: (Link) -> Void = { [weak self] updatedBookmark in
                bookmarksManager.save(bookmark: updatedBookmark)
                self?.view.showBottomToast(UserText.webSaveBookmarkDone)
            }
            let alert = EditBookmarkAlert.buildAlert (
                title: UserText.alertSaveBookmark,
                bookmark: link,
                saveCompletion: saveCompletion)
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    private func buildSaveFavoriteAction(forLink link: Link) -> UIAlertAction? {
        guard let currentVariant = DefaultVariantManager().currentVariant,
                currentVariant.features.contains(.homeScreen) else {
            return nil
        }
        
        let bookmarksManager = BookmarksManager()
        guard !bookmarksManager.contains(url: link.url) else { return nil }

        return UIAlertAction(title: UserText.actionSaveFavorite, style: .default) { [weak self] _ in
            Pixel.fire(pixel: .browsingMenuAddToFavorites)
            let saveCompletion: (Link) -> Void = { [weak self] favorite in
                bookmarksManager.save(favorite: favorite)
                self?.view.showBottomToast(UserText.webSaveFavoriteDone)
            }
            let alert = EditBookmarkAlert.buildAlert (
                title: UserText.alertSaveFavorite,
                bookmark: link,
                saveCompletion: saveCompletion)
            self?.present(alert, animated: true, completion: nil)
        }
    }

    private func onShareAction(forLink link: Link) {
        Pixel.fire(pixel: .browsingMenuShare)
        guard let menu = chromeDelegate?.omniBar.menuButton else { return }
        let url = appUrls.removeATBAndSource(fromUrl: link.url)
        presentShareSheet(withItems: [ url, link ], fromView: menu)
    }
    
    private func onToggleDesktopSiteAction(forUrl url: URL) {
        Pixel.fire(pixel: .browsingMenuToggleBrowsingMode)
        tabModel.toggleDesktopMode()
        updateUserAgent()
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
    
    private func buildWhitelistAction(forDomain domain: String) -> UIAlertAction {
        let whitelistManager = WhitelistManager()
        let whitelisted = whitelistManager.isWhitelisted(domain: domain)
        let title = whitelisted ? UserText.actionRemoveFromWhitelist : UserText.actionAddToWhitelist
        let operation = whitelisted ? whitelistManager.remove : whitelistManager.add
        
        return UIAlertAction(title: title, style: .default) { _ in
            Pixel.fire(pixel: .browsingMenuWhitelist)
            operation(domain)
        }
    }
}
