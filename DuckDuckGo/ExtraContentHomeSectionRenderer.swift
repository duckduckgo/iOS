//
//  ExtraContentHomeSectionRenderer.swift
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

class ExtraContentHomeSectionRenderer: HomeViewSectionRenderer {
    
    var controller: HomeViewController?
    
    func install(into controller: HomeViewController) {
        self.controller = controller
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "extraContent", for: indexPath) as? ExtraContentHomeCell else {
            fatalError("not an Extra Content cell")
        }
        
        cell.decorate(with: ThemeManager.shared.currentTheme)
        
        cell.onDismiss = { [weak self] _ in
            guard let strongSelf = self else { return }
            DefaultHomePageSettings().showCovidInfo = false
            strongSelf.controller?.remove(strongSelf)
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let preferredWidth = collectionView.frame.width - (HomeViewSectionRenderers.Constants.sideInsets * 2)
        let width: CGFloat = min(preferredWidth, CenteredSearchHomeCell.Constants.searchWidth)
        return CGSize(width: width, height: 56)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        controller?.load(url: AppUrls().searchUrl(text: "covid 19"))
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize? {
        return CGSize(width: 1, height: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                               withReuseIdentifier: EmptyCollectionReusableView.reuseIdentifier,
                                                               for: indexPath)
    }
}
