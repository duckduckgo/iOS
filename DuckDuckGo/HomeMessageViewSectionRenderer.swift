//
//  HomeMessageViewSectionRenderer.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

protocol HomeMessageViewSectionRendererDelegate: AnyObject {
    
    func homeMessageRenderer(_ renderer: HomeMessageViewSectionRenderer,
                             didDismissHomeMessage homeMessage: HomeMessage)
    
}

class HomeMessageViewSectionRenderer: NSObject, HomeViewSectionRenderer {
    
    struct Constants {
        
        static let topMargin: CGFloat = 16
        static let horizontalMargin: CGFloat = 16
        
    }
    
    private weak var controller: HomeViewController?
    
    private let homePageConfiguration: HomePageConfiguration
    
    init(homePageConfiguration: HomePageConfiguration) {
        self.homePageConfiguration = homePageConfiguration
        super.init()
    }
    
    func install(into controller: HomeViewController) {
        self.controller = controller
        hideLogoIfThereAreMessagesToDisplay()
    }
    
    private func hideLogoIfThereAreMessagesToDisplay() {
        if !homePageConfiguration.homeMessages.isEmpty {
            controller?.hideLogo()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets? {
        let widthNotTakenByCell = collectionView.frame.width - collectionViewCellWidth(collectionView)
        let horizontalInset = widthNotTakenByCell / 2.0
        
        let isEmpty = collectionView.numberOfItems(inSection: section) == 0
        let top = isEmpty ? 0 : Constants.topMargin
        
        return UIEdgeInsets(top: top, left: horizontalInset, bottom: 0, right: horizontalInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return homePageConfiguration.homeMessages.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                               withReuseIdentifier: EmptyCollectionReusableView.reuseIdentifier,
                                                               for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeMessageCollectionViewCell.reuseIdentifier,
                                                            for: indexPath) as? HomeMessageCollectionViewCell else {
            fatalError("Could not dequeue cell")
        }
        configureCell(cell, in: collectionView, at: indexPath)
        return cell
    }
    
    private func configureCell(_ cell: HomeMessageCollectionViewCell,
                               in collectionView: UICollectionView,
                               at indexPath: IndexPath) {
        if let controller = controller {
            let viewModel = homeMessageViewModel(for: indexPath, collectionView: collectionView)
            cell.configure(with: viewModel, parent: controller)
        }
    }
    
    private func homeMessageViewModel(for indexPath: IndexPath,
                                      collectionView: UICollectionView) -> HomeMessageViewModel {
        let message = homePageConfiguration.homeMessages[indexPath.row]
        switch message {
        case .placeholder:
            return HomeMessageViewModel(image: nil, topText: nil, title: "", subtitle: "", buttons: []) { [weak self] in
                self?.dismissHomeMessage(message, at: indexPath, in: collectionView)
            }
        }
    }
    
    private func dismissHomeMessage(_ message: HomeMessage,
                                    at indexPath: IndexPath,
                                    in collectionView: UICollectionView) {
        homePageConfiguration.dismissHomeMessage(message)
        animateCellDismissal(at: indexPath, in: collectionView) {
            self.controller?.homeMessageRenderer(self, didDismissHomeMessage: message)
        }
    }
    
    private func animateCellDismissal(at indexPath: IndexPath,
                                      in collectionView: UICollectionView,
                                      completion: @escaping () -> Void) {
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            completion()
            return
        }
                
        UIView.animate(withDuration: 0.3, animations: {
            cell.alpha = 0
        }, completion: { _ in
            completion()
        })
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cell = HomeMessageCollectionViewCell()
        configureCell(cell, in: collectionView, at: indexPath)
        let size = cell.host?.sizeThatFits(in: CGSize(width: collectionViewCellWidth(collectionView),
                                                      height: CGFloat.greatestFiniteMagnitude)) ?? .zero
        return size
    }
    
    private func collectionViewCellWidth(_ collectionView: UICollectionView) -> CGFloat {
        let marginWidth = Constants.horizontalMargin * 2
        let availableWidth = collectionView.safeAreaLayoutGuide.layoutFrame.width - marginWidth
        let maxCellWidth = isPad ? HomeMessageCollectionViewCell.maximumWidthPad : HomeMessageCollectionViewCell.maximumWidth
        return min(availableWidth, maxCellWidth)
    }
    
    private var isPad: Bool {
        return controller?.traitCollection.horizontalSizeClass == .regular
    }
}
