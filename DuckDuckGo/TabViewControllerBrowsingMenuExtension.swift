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
import BrowserServicesKit
import simd

extension TabViewController {
    
    func buildBrowsingMenuHeaderContent() -> [BrowsingMenuEntry] {
        
        var entries = [BrowsingMenuEntry]()
        
        entries.append(BrowsingMenuEntry.regular(name: UserText.actionNewTab, image: UIImage(named: "MenuNewTab")!, action: { [weak self] in
            self?.onNewTabAction()
        }))
        
        entries.append(BrowsingMenuEntry.regular(name: UserText.actionShare, image: UIImage(named: "MenuShare")!, action: { [weak self] in
            guard let self = self else { return }
            guard let menu = self.chromeDelegate?.omniBar.menuButton else { return }
            self.onShareAction(forLink: self.link!, fromView: menu, orginatedFromMenu: true)
        }))
        
        entries.append(BrowsingMenuEntry.regular(name: UserText.actionCopy, image: UIImage(named: "MenuCopy")!, action: { [weak self] in
            guard let strongSelf = self else { return }
            if !strongSelf.isError, let url = strongSelf.webView.url {
                strongSelf.onCopyAction(forUrl: url)
            } else if let text = self?.chromeDelegate?.omniBar.textField.text {
                strongSelf.onCopyAction(for: text)
            }
            
            Pixel.fire(pixel: .browsingMenuCopy)
            ActionMessageView.present(message: UserText.actionCopyMessage)
        }))
        
        entries.append(BrowsingMenuEntry.regular(name: UserText.actionPrint, image: UIImage(named: "MenuPrint")!, action: { [weak self] in
            Pixel.fire(pixel: .browsingMenuPrint)
            self?.print()
        }))
        
        return entries
    }
    
    var favoriteEntryIndex: Int { 1 }
    
    func buildBrowsingMenu(completion: @escaping ([BrowsingMenuEntry]) -> Void) {
        
        var entries = [BrowsingMenuEntry]()
        
        buildLinkEntries() { linkEntries in
            entries.append(contentsOf: linkEntries)
            
            if let domain = self.siteRating?.domain {
                entries.append(self.buildToggleProtectionEntry(forDomain: domain))
            }
            
            entries.append(BrowsingMenuEntry.regular(name: UserText.actionReportBrokenSite,
                                                     image: UIImage(named: "MenuFeedback")!,
                                                     action: { [weak self] in
                self?.onReportBrokenSiteAction()
            }))
            
            entries.append(BrowsingMenuEntry.regular(name: UserText.actionSettings,
                                                     image: UIImage(named: "MenuSettings")!,
                                                     action: { [weak self] in
                self?.onBrowsingSettingsAction()
            }))
            
            completion(entries)
        }
    }
    
    private func buildLinkEntries(completion: @escaping ([BrowsingMenuEntry]) -> Void) {
        guard let link = link, !isError else {
            completion([])
            return
        }
        
        var entries = [BrowsingMenuEntry]()
        
        buildBookmarkEntry(for: link) { bookmarkEntry in
            if let bookmarkEntry = bookmarkEntry {
                entries.append(bookmarkEntry)
            }
            
            self.buildFavoriteEntry(for: link) { favoriteEntry in
                if let favoriteEntry = favoriteEntry {
                    assert(self.favoriteEntryIndex == entries.count, "Entry index should be in sync with entry placement")
                    entries.append(favoriteEntry)
                }
                
                entries.append(BrowsingMenuEntry.regular(name: UserText.actionOpenBookmarks,
                                                         image: UIImage(named: "MenuBookmarks")!,
                                                         action: { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.delegate?.tabDidRequestBookmarks(tab: strongSelf)
                }))
                
                entries.append(.separator)

                if let entry = self.buildKeepSignInEntry(forLink: link) {
                    entries.append(entry)
                }
                
                if let entry = self.buildUseNewDuckAddressEntry(forLink: link) {
                    entries.append(entry)
                }
                
                let title = self.tabModel.isDesktop ? UserText.actionRequestMobileSite : UserText.actionRequestDesktopSite
                let image = self.tabModel.isDesktop ? UIImage(named: "MenuMobileMode")! : UIImage(named: "MenuDesktopMode")!
                entries.append(BrowsingMenuEntry.regular(name: title, image: image, action: { [weak self] in
                    self?.onToggleDesktopSiteAction(forUrl: link.url)
                }))
                
                entries.append(self.buildFindInPageEntry(forLink: link))
                
                completion(entries)
            }
        }
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
    
    //omg so much to do here
    private func buildBookmarkEntry(for link: Link, completion: @escaping (BrowsingMenuEntry?) -> Void) {
        bookmarksManager.containsBookmark(url: link.url) { contains in
            if contains {
                let entry = BrowsingMenuEntry.regular(name: UserText.actionEditBookmark,
                                                      image: UIImage(named: "MenuBookmarkSolid")!,
                                                      action: { [weak self] in
                                                         self?.performEditBookmarkAction(for: link)
                                                      })
                completion(entry)
            } else {
                let entry = BrowsingMenuEntry.regular(name: UserText.actionSaveBookmark,
                                                      image: UIImage(named: "MenuBookmark")!,
                                                      action: { [weak self] in
                                                        self?.performSaveBookmarkAction(for: link)
                                                      })
                completion(entry)
            }
        }
    }
    
    private func performSaveBookmarkAction(for link: Link) {
        Pixel.fire(pixel: .browsingMenuAddToBookmarks)
        bookmarksManager.saveNewBookmark(withTitle: link.title ?? "", url: link.url, parentID: nil)

        ActionMessageView.present(message: UserText.webSaveBookmarkDone,
                                  actionTitle: UserText.actionGenericEdit) {
            self.performEditBookmarkAction(for: link)
        }
    }
    
    private func performEditBookmarkAction(for link: Link) {
        Pixel.fire(pixel: .browsingMenuEditBookmark)
        
        delegate?.tabDidRequestEditBookmark(tab: self)
    }
    
    private func buildFavoriteEntry(for link: Link, completion: @escaping (BrowsingMenuEntry?) -> Void) {
        bookmarksManager.containsFavorite(url: link.url) { contains in

            if contains {
                let action: () -> Void = { [weak self] in
                    Pixel.fire(pixel: .browsingMenuRemoveFromFavorites)
                    self?.performRemoveFavoriteAction(for: link)
                }

                let entry = BrowsingMenuEntry.regular(name: UserText.actionRemoveFavorite,
                                                      image: UIImage(named: "MenuFavoriteSolid")!,
                                                      action: action)
                completion(entry)

            } else {
                // Capture flow state here as will be reset after menu is shown
                let addToFavoriteFlow = DaxDialogs.shared.isAddFavoriteFlow

                let entry = BrowsingMenuEntry.regular(name: UserText.actionSaveFavorite, image: UIImage(named: "MenuFavorite")!, action: { [weak self] in
                    Pixel.fire(pixel: addToFavoriteFlow ? .browsingMenuAddToFavoritesAddFavoriteFlow : .browsingMenuAddToFavorites)
                    self?.performSaveFavoriteAction(for: link)
                })
                completion(entry)
            }
        }
    }
    
    private func performSaveFavoriteAction(for link: Link) {
        //TODO okay, this might need a completion to actually return when it's done
        bookmarksManager.saveNewFavorite(withTitle: link.title ?? "", url: link.url)

        ActionMessageView.present(message: UserText.webSaveFavoriteDone, actionTitle: UserText.actionGenericUndo) {
            self.performRemoveFavoriteAction(for: link)
        }
    }
    
    //TODO this is an unnecessaryily long way around of doing things
    //we might be able to get rid of some core data methods if we do this sensibly
    private func performRemoveFavoriteAction(for link: Link) {
        let bookmarksManager = BookmarksManager()
        bookmarksManager.favorite(forURL: link.url) { bookmark in
            guard let bookmark = bookmark else {
                return
            }
            
            //TODO we arguably need a call back here
            bookmarksManager.delete(bookmark)

            DispatchQueue.main.async {
                ActionMessageView.present(message: UserText.webFavoriteRemoved, actionTitle: UserText.actionGenericUndo) {
                    self.performSaveFavoriteAction(for: link)
                }
            }
        }
    }
    
    private func buildUseNewDuckAddressEntry(forLink link: Link) -> BrowsingMenuEntry? {
        guard emailManager.isSignedIn else { return nil }
        let title = UserText.emailBrowsingMenuUseNewDuckAddress
        let image = UIImage(named: "MenuEmail")!

        return BrowsingMenuEntry.regular(name: title, image: image) { [weak self] in
            guard let emailManager = self?.emailManager else { return }

            var pixelParameters: [String: String] = [:]

            if let cohort = emailManager.cohort {
                pixelParameters[PixelParameters.emailCohort] = cohort
            }
            pixelParameters[PixelParameters.emailLastUsed] = emailManager.lastUseDate
            emailManager.updateLastUseDate()

            Pixel.fire(pixel: .emailUserCreatedAlias, withAdditionalParameters: pixelParameters, includedParameters: [])

            emailManager.getAliasIfNeededAndConsume { alias, _ in
                guard let alias = alias else {
                    // we may want to communicate this failure to the user in the future
                    return
                }
                let pasteBoard = UIPasteboard.general
                pasteBoard.string = emailManager.emailAddressFor(alias)
                ActionMessageView.present(message: UserText.emailBrowsingMenuAlert)
            }
        }
    }

    func onShareAction(forLink link: Link, fromView view: UIView, orginatedFromMenu: Bool) {
        Pixel.fire(pixel: .browsingMenuShare,
                   withAdditionalParameters: [PixelParameters.originatedFromMenu: orginatedFromMenu ? "1" : "0"])
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
        let protectionStore = DomainsProtectionUserDefaultsStore()
        let isProtected = !protectionStore.unprotectedDomains.contains(domain)
        let title = isProtected ? UserText.actionDisableProtection : UserText.actionEnableProtection
        let image = isProtected ? UIImage(named: "MenuDisableProtection")! : UIImage(named: "MenuEnableProtection")!
    
        return BrowsingMenuEntry.regular(name: title, image: image, action: { [weak self] in
            Pixel.fire(pixel: isProtected ? .browsingMenuDisableProtection : .browsingMenuEnableProtection)
            self?.togglePrivacyProtection(protectionStore: protectionStore, domain: domain)
        })
    }
    
    private func togglePrivacyProtection(protectionStore: DomainsProtectionStore, domain: String) {
        let isProtected = !protectionStore.unprotectedDomains.contains(domain)
        let operation = isProtected ? protectionStore.disableProtection : protectionStore.enableProtection
        
        operation(domain)
        
        let message: String
        if isProtected {
            message = UserText.messageProtectionDisabled.format(arguments: domain)
        } else {
            message = UserText.messageProtectionEnabled.format(arguments: domain)
        }
        
        ActionMessageView.present(message: message, actionTitle: UserText.actionGenericUndo) { [weak self] in
            self?.togglePrivacyProtection(protectionStore: protectionStore, domain: domain)
        }
    }
}
