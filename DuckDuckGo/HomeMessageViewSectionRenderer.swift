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

protocol HomeMessageViewSectionRendererDelegate: class {
    
    func homeMessageRenderer(_ renderer: HomeMessageViewSectionRenderer,
                             didDismissHomeMessage homeMessage: HomeMessage)
    
}

class HomeMessageViewSectionRenderer: NSObject, HomeViewSectionRenderer {
    
    struct Constants {
        
        static let topMargin: CGFloat = 16
        static let horizontalMargin: CGFloat = 16
        
    }
    
    private weak var controller: (UIViewController & HomeMessageViewSectionRendererDelegate)?
    
    private let homePageConfiguration: HomePageConfiguration
    
    private lazy var cellForSizing: HomeMessageCell = {
        let nib = Bundle.main.loadNibNamed("HomeMessageCell", owner: HomeMessageCell.self, options: nil)
        // swiftlint:disable force_cast
        return nib!.first as! HomeMessageCell
        // swiftlint:enable force_cast
    }()
    
    init(homePageConfiguration: HomePageConfiguration) {
        self.homePageConfiguration = homePageConfiguration
        super.init()
    }
    
    func install(into controller: HomeViewController) {
        self.controller = controller
    }
    
    func install(into controller: UIViewController & HomeMessageViewSectionRendererDelegate) {
        self.controller = controller
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
        return homePageConfiguration.homeMessages().count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                               withReuseIdentifier: EmptyCollectionReusableView.reuseIdentifier,
                                                               for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeMessageCell.reuseIdentifier,
                                                            for: indexPath) as? HomeMessageCell else {
            fatalError("not a HomeMessageCell")
        }

        cell.alpha = 1.0
        cell.setWidth(collectionViewCellWidth(collectionView))
        cell.configure(withModel: homeMessageModel(forIndexPath: indexPath))
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionViewCellWidth(collectionView)

        cellForSizing.setWidth(width)
        cellForSizing.configure(withModel: homeMessageModel(forIndexPath: indexPath))

        let targetSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let size = cellForSizing.systemLayoutSizeFitting(targetSize)
        return size
    }

    private func homeMessageModel(forIndexPath indexPath: IndexPath) -> HomeMessageModel {
        return homePageConfiguration.homeMessages()[indexPath.row]
    }
    
    private func collectionViewCellWidth(_ collectionView: UICollectionView) -> CGFloat {
        let marginWidth = Constants.horizontalMargin * 2
        let availableWidth = collectionView.bounds.size.width - marginWidth
        let maxCellWidth = HomeMessageCell.maximumWidth
        return  min(availableWidth, maxCellWidth)
    }
}

extension HomeMessageViewSectionRenderer: HomeMessageCellDelegate {
    
    func homeMessageCellDismissButtonWasPressed(_ cell: HomeMessageCell) {
        Pixel.fire(pixel: .defaultBrowserHomeMessageDismissed)
        setCellDismissed(forHomeMessage: cell.homeMessage)
        UIView.animate(withDuration: 0.3, animations: {
            cell.alpha = 0
        }, completion: { _ in
            self.controller?.homeMessageRenderer(self, didDismissHomeMessage: cell.homeMessage)
        })
    }
    
    func homeMessageCellMainButtonWaspressed(_ cell: HomeMessageCell) {
        switch cell.homeMessage {
        case .defaultBrowserPrompt:
            Pixel.fire(pixel: .defaultBrowserButtonPressedHome)
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
        setCellDismissed(forHomeMessage: cell.homeMessage)
        controller?.homeMessageRenderer(self, didDismissHomeMessage: cell.homeMessage)
    }
    
    private func setCellDismissed(forHomeMessage homeMessage: HomeMessage) {
        let storage = homePageConfiguration.homeMessageStorage
        storage.setDateDismissed(forHomeMessage: homeMessage)
    }
}
