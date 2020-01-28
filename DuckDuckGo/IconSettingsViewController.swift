//
//  IconSettingsViewController.swift
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

class IconSettingsViewController: UICollectionViewController {

    private var icons = Icon.allCases

    override func viewDidLoad() {
        super.viewDidLoad()

        applyTheme(ThemeManager.shared.currentTheme)
        initSelection()
    }

    private func initSelection() {
        let icon = IconManager.shared.applicationIcon
        let index = icons.firstIndex(of: icon) ?? 0
        let indexPath = IndexPath(row: index, section: 0)
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
    }

    private func changeIcon(_ icon: Icon) {
        IconManager.shared.changeApplicationIcon(icon) { error in
            if error != nil {
                DispatchQueue.main.async {
                    self.initSelection()
                }
            }
        }
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return icons.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IconSettingsCell.reuseIdentifier,
                                                            for: indexPath)
            as? IconSettingsCell else {
                fatalError("Expected IconSettingsCell")
        }
        cell.decorate(with: ThemeManager.shared.currentTheme)

        let icon = icons[indexPath.row]
        cell.imageView.image = icon.mediumImage

        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let icon = icons[indexPath.row]
        changeIcon(icon)
    }

}

extension IconSettingsViewController: Themable {
    
    func decorate(with theme: Theme) {
        collectionView.backgroundColor = theme.backgroundColor
    }

}
