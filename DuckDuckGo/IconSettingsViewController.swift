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
    private var initialSelectedIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()

        applyTheme(ThemeManager.shared.currentTheme)
        initFirstSelection()
    }

    private func initFirstSelection() {
        let icon = IconManager.shared.applicationIcon
        let index = icons.firstIndex(of: icon) ?? 0
        initialSelectedIndexPath = IndexPath(row: index, section: 0)
    }

    private func selectIfNeeded(_ indexPath: IndexPath) {
        if let firstSelectedIndexPath = initialSelectedIndexPath,
            firstSelectedIndexPath == indexPath {
            DispatchQueue.main.async {
                self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .bottom)
            }
            self.initialSelectedIndexPath = nil
        }
    }

    private func changeIcon(_ icon: Icon) {
        do {
            try IconManager.shared.changeApplicationIcon(icon)
        } catch {
            Pixel.fire(pixel: .settingsIconChangeFailed, error: error)
            Logger.log(text: "Error while changing icon: \(error.localizedDescription)")
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
        selectIfNeeded(indexPath)
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
