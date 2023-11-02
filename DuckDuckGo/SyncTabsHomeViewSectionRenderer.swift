//
//  SyncTabsHomeViewSectionRenderer.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

class SyncTabsHomeViewSectionRenderer: NSObject, HomeViewSectionRenderer {

    struct Constants {
        static let topMargin: CGFloat = 16
        static let topMarginPad: CGFloat = 28
        static let horizontalMargin: CGFloat = 16
    }

    fileprivate lazy var featureFlagger = AppDependencyProvider.shared.featureFlagger

    private weak var controller: HomeViewController?

    let syncTabsHomeViewModel: SyncTabsHomeViewModel

    init(syncTabsHomeViewModel: SyncTabsHomeViewModel) {
        self.syncTabsHomeViewModel = syncTabsHomeViewModel
        super.init()
    }

    func install(into controller: HomeViewController) {
        self.controller = controller
        controller.hideLogo()
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets? {
        let widthNotTakenByCell = collectionView.frame.width - collectionViewCellWidth(collectionView)
        let horizontalInset = widthNotTakenByCell / 2.0

        return UIEdgeInsets(top: isPad ? Constants.topMarginPad : Constants.topMargin, left: horizontalInset, bottom: 0, right: horizontalInset)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cell = SyncTabsCollectionViewCell()
        configureCell(cell, in: collectionView, at: indexPath)
        let size = cell.host?.sizeThatFits(in: CGSize(width: collectionViewCellWidth(collectionView),
                                                      height: CGFloat.greatestFiniteMagnitude)) ?? .zero
        return size
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SyncTabsCollectionViewCell.reuseIdentifier,
                                                            for: indexPath) as? SyncTabsCollectionViewCell else {
            fatalError("Could not dequeue cell")
        }
        configureCell(cell, in: collectionView, at: indexPath)
        return cell
    }

    private func configureCell(_ cell: SyncTabsCollectionViewCell,
                               in collectionView: UICollectionView,
                               at indexPath: IndexPath) {
        if let controller = controller {
            cell.configure(with: syncTabsHomeViewModel, parent: controller)
        }
    }

    private func collectionViewCellWidth(_ collectionView: UICollectionView) -> CGFloat {
        let marginWidth = Constants.horizontalMargin * 2
        let availableWidth = collectionView.safeAreaLayoutGuide.layoutFrame.width - marginWidth
        let maxCellWidth = isPad ? SyncTabsCollectionViewCell.maximumWidthPad : SyncTabsCollectionViewCell.maximumWidth
        return min(availableWidth, maxCellWidth)
    }

    private var isPad: Bool {
        return controller?.traitCollection.horizontalSizeClass == .regular
    }

}
