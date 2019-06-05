//
//  BookmarksButton.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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

protocol FavoritesOverlayDelegate: class {
    
    func favoritesOverlay(_ overlay: FavoritesOverlay, didSelect link: Link)
}

class FavoritesOverlay: UIViewController {
    
    struct Constants {
        static let margin: CGFloat = 28
    }
    
    private var collectionView: UICollectionView!
    private var renderer: FavoritesHomeViewSectionRenderer!
    
    private var theme: Theme!
    
    private weak var delegate: FavoritesOverlayDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        
        collectionView.register(UINib(nibName: "FavoriteHomeCell", bundle: nil), forCellWithReuseIdentifier: "favorite")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
        
        renderer = FavoritesHomeViewSectionRenderer(allowsEditing: false)
        renderer.install(into: self)
        
        registerForKeyboardNotifications()
        
        applyTheme(ThemeManager.shared.currentTheme)
    }
    
    func install(into controller: FavoritesOverlayDelegate) {
        loadViewIfNeeded()
        
        delegate = controller
        collectionView.reloadData()
    }
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidShow),
                                               name: UIResponder.keyboardDidShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc private func keyboardDidShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardSize = keyboardFrame.size
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height + Constants.margin * 2, right: 0.0)
        collectionView.contentInset = contentInsets
        collectionView.scrollIndicatorInsets = contentInsets
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        collectionView.contentInset = contentInsets
        collectionView.scrollIndicatorInsets = contentInsets
    }
}

extension FavoritesOverlay: FavoritesHomeViewSectionRendererDelegate {
    
    func favoritesRenderer(_ renderer: FavoritesHomeViewSectionRenderer, didSelect link: Link) {
        delegate?.favoritesOverlay(self, didSelect: link)
    }
}

extension FavoritesOverlay: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        renderer.collectionView(collectionView, didSelectItemAt: indexPath)
    }
    
}

extension FavoritesOverlay: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return renderer.collectionView(collectionView, numberOfItemsInSection: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = renderer.collectionView(collectionView, cellForItemAt: indexPath)
        if let themable = cell as? Themable {
            themable.decorate(with: theme)
        }
        return cell
    }
}

extension FavoritesOverlay: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath)
        -> CGSize {
            return renderer.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int)
        -> UIEdgeInsets {
            
            var insets = renderer.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: section) ?? UIEdgeInsets.zero
            
            insets.top += Constants.margin
            return insets
    }
}

extension FavoritesOverlay: Themable {
    
    func decorate(with theme: Theme) {
        self.theme = theme
        
        view.backgroundColor = theme.backgroundColor
        collectionView.backgroundColor = .clear
    }
}
