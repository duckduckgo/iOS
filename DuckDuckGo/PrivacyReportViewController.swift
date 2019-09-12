//
//  PrivacyReportViewController.swift
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

class PrivacyReportViewController: UIViewController {
    
    struct Constants {
        static let numberOfCells = 3
        
        static let margin: CGFloat = 16
        static let maxCellWidth: CGFloat = 400
    }
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    
    private let dataSource = PrivacyReportDataSource()
    
    private let dateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateStyle = .medium
        applyTheme(ThemeManager.shared.currentTheme)
    }

    @IBAction func onClosePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension PrivacyReportViewController: UICollectionViewDelegate {}

extension PrivacyReportViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Constants.numberOfCells
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        switch indexPath.row {
        case 0, 1:
            cell = reportCell(collectionView, at: indexPath)
        default:
            cell = footerCell(collectionView, at: indexPath)
        }
        
        return cell
    }
    
    private func reportCell(_ collectionView: UICollectionView,
                            at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "privacyReportCell", for: indexPath) as? PrivacyReportCell else {
            fatalError("not a PrivacyReportCell")
        }
        
        switch indexPath.row {
        case 0:
            cell.title.setAttributedTextString(UserText.privacyReportTrackersBlocked)
            cell.count.textColor = .midGreen
            cell.count.setAttributedTextString(String(dataSource.trackersCount))
            cell.image.image = UIImage(named: "PP Report Trackers")
            
        default:
            cell.title.setAttributedTextString(UserText.privacyReportSitesEncrypted)
            cell.count.textColor = .cornflowerBlue
            cell.count.setAttributedTextString(String(dataSource.httpsUpgradesCount))
            cell.image.image = UIImage(named: "PP Report Encryption")
        }
        
        let date = dataSource.startDate ?? Date()
        let dateText = dateFormatter.string(from: date)
        cell.date.setAttributedTextString(UserText.privacyReportDate.format(arguments: dateText))
        
        let theme = ThemeManager.shared.currentTheme
        cell.roundedBackground.backgroundColor = theme.privacyReportCellBackgroundColor
        
        return cell
    }
    
    private func footerCell(_ collectionView: UICollectionView,
                            at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "footerCell", for: indexPath) as? PrivacyReportFooterCell else {
            fatalError("not a PrivacyReportFooterCell")
        }
        
        return cell
    }
}

extension PrivacyReportViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = min(collectionView.frame.width - Constants.margin * 2, Constants.maxCellWidth)
        return CGSize(width: width, height: 124)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: Constants.margin, left: Constants.margin, bottom: 0, right: Constants.margin)
    }
}

extension PrivacyReportViewController: Themable {
    
    func decorate(with theme: Theme) {
        decorateNavigationBar(with: theme)
        
        if #available(iOS 13.0, *) {
            overrideSystemTheme(with: theme)
        }
        
        view.backgroundColor = theme.backgroundColor
    }
    
}
