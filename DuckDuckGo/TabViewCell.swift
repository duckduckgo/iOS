//
//  TabViewCell.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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
import Kingfisher

protocol TabViewCellDelegate: class {

    func deleteTab(tab: Tab)

    func isCurrent(tab: Tab) -> Bool
    
}

class TabViewCell: UICollectionViewCell {

    struct Constants {
        
        static let selectedBorderWidth: CGFloat = 2.0
        static let unselectedBorderWidth: CGFloat = 0.0
        static let selectedAlpha: CGFloat = 1.0
        static let unselectedAlpha: CGFloat = 0.92
        static let swipeToDeleteAlpha: CGFloat = 0.5
        
        static let cellCornerRadius: CGFloat = 8.0
        static let cellHeaderHeight: CGFloat = 38.0
        static let cellLogoSize: CGFloat = 68.0
        
    }
    
    static let reuseIdentifier = "TabCell"

    var removeThreshold: CGFloat {
        return frame.width / 3
    }

    weak var delegate: TabViewCellDelegate?
    weak var tab: Tab?
    var isCurrent = false
    var isDeleting = false
    var canDelete = false

    @IBOutlet weak var background: UIView!
    @IBOutlet weak var border: UIView!
    @IBOutlet weak var favicon: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var unread: UIImageView!
    @IBOutlet weak var preview: UIImageView!
    
    weak var previewAspectRatio: NSLayoutConstraint?
    @IBOutlet var previewTopConstraint: NSLayoutConstraint?
    @IBOutlet var previewBottomConstraint: NSLayoutConstraint?
    @IBOutlet var previewTrailingConstraint: NSLayoutConstraint?
    
    weak var collectionReorderRecognizer: UIGestureRecognizer?

    override func awakeFromNib() {
        super.awakeFromNib()
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handleSwipe(recognizer:)))
        recognizer.delegate = self
        addGestureRecognizer(recognizer)
        
        setupSubviews()
    }
    
    private func setupSubviews() {

        unread.tintColor = .cornflowerBlue
        
        backgroundColor = .clear
        layer.cornerRadius = backgroundView?.layer.cornerRadius ?? 0.0
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 3.0
        layer.shadowOpacity = 0.15
        layer.masksToBounds = false
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    private func updatePreviewToDisplay(image: UIImage) {
        let imageAspectRatio = image.size.height / image.size.width
        let containerAspectRatio = (background.bounds.height - TabViewCell.Constants.cellHeaderHeight) / background.bounds.width
        
        let strechContainerVerically = containerAspectRatio < imageAspectRatio
        
        if let constraint = previewAspectRatio {
            preview.removeConstraint(constraint)
        }
        
        previewTopConstraint?.constant = Constants.cellHeaderHeight
        previewBottomConstraint?.isActive = !strechContainerVerically
        previewTrailingConstraint?.isActive = strechContainerVerically
        
        previewAspectRatio = preview.heightAnchor.constraint(equalTo: preview.widthAnchor, multiplier: imageAspectRatio)
        previewAspectRatio?.isActive = true
    }
    
    private func updatePreviewToDisplayLogo() {
        if let constraint = previewAspectRatio {
            preview.removeConstraint(constraint)
            previewAspectRatio = nil
        }
        
        previewTopConstraint?.constant = 0
        previewBottomConstraint?.isActive = true
        previewTrailingConstraint?.isActive = true
    }
    
    private static var darkThemeUnreadImage = PrivacyProtectionIconSource.stackedIconImage(withIconImage: UIImage(named: "TabUnread")!,
                                                                                     borderWidth: 6.0,
                                                                                     foregroundColor: .cornflowerBlue,
                                                                                     borderColor: DarkTheme().tabSwitcherCellBackgroundColor)
    private static var lighThemeUnreadImage = PrivacyProtectionIconSource.stackedIconImage(withIconImage: UIImage(named: "TabUnread")!,
                                                                                     borderWidth: 6.0,
                                                                                     foregroundColor: .cornflowerBlue,
                                                                                     borderColor: LightTheme().tabSwitcherCellBackgroundColor)
    
    private static func unreadImage(for theme: Theme) -> UIImage {
        switch theme.currentImageSet {
        case .dark:
            return darkThemeUnreadImage
        case .light:
            return lighThemeUnreadImage
        }
    }
    
    static let logoImage: UIImage = {
        let image = UIImage(named: "Logo")!
        let renderFormat = UIGraphicsImageRendererFormat.default()
        renderFormat.opaque = false
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: Constants.cellLogoSize,
                                                            height: Constants.cellLogoSize),
                                               format: renderFormat)
        return renderer.image { _ in
            image.draw(in: CGRect(x: 0,
                                  y: 0,
                                  width: Constants.cellLogoSize,
                                  height: Constants.cellLogoSize))
        }
    }()

    var startX: CGFloat = 0
    @objc func handleSwipe(recognizer: UIGestureRecognizer) {
        let currentLocation = recognizer.location(in: nil)
        let diff = startX - currentLocation.x

        switch recognizer.state {

        case .began:
            startX = currentLocation.x

        case .changed:
            let offset = max(0, startX - currentLocation.x)
            transform = CGAffineTransform.identity.translatedBy(x: -offset, y: 0)            
            if diff > removeThreshold {
                if !canDelete {
                    makeTranslucent()
                    UIImpactFeedbackGenerator().impactOccurred()
                }
                canDelete = true
            } else {
                if canDelete {
                   makeOpaque()
                }
                canDelete = false
            }

        case .ended:
            if canDelete {
                startRemoveAnimation()
            } else {
                startCancelAnimation()
            }
            canDelete = false

        case .cancelled:
            startCancelAnimation()
            canDelete = false

        default: break

        }

    }
    
    private func makeTranslucent() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = Constants.swipeToDeleteAlpha
        })
    }
    
    private func makeOpaque() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 1.0
        })
    }

    private func startRemoveAnimation() {
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform.identity.translatedBy(x: -self.frame.width, y: 0)
        }, completion: { _ in
            self.isHidden = true
            self.isDeleting = true
            self.deleteTab()
        })
    }

    private func startCancelAnimation() {
        UIView.animate(withDuration: 0.2) {
            self.transform = .identity
        }
    }

    func update(withTab tab: Tab,
                preview: UIImage?,
                reorderRecognizer: UIGestureRecognizer?) {
        accessibilityElements = [ title as Any, removeButton as Any ]

        self.tab = tab
        self.collectionReorderRecognizer = reorderRecognizer

        if !isDeleting {
            isHidden = false
        }
        isCurrent = delegate?.isCurrent(tab: tab) ?? false
        
        decorate(with: ThemeManager.shared.currentTheme)
        
        border.layer.borderWidth = isCurrent ? Constants.selectedBorderWidth : Constants.unselectedBorderWidth

        if let link = tab.link {
            removeButton.accessibilityLabel = UserText.closeTab(withTitle: link.displayTitle ?? "", atAddress: link.url.host ?? "")
            title.accessibilityLabel = UserText.openTab(withTitle: link.displayTitle ?? "", atAddress: link.url.host ?? "")
            title.text = tab.link?.displayTitle
        }
        
        unread.isHidden = tab.viewed
        
        if tab.link == nil {
            updatePreviewToDisplayLogo()
            self.preview.image = Self.logoImage
            self.preview.contentMode = .center
            
            title.text = UserText.homeTabTitle
            favicon.image = UIImage(named: "Logo")
        } else {
            if let preview = preview {
                self.updatePreviewToDisplay(image: preview)
                self.preview.contentMode = .scaleAspectFill
                self.preview.image = preview
            } else {
                self.preview.image = nil
            }
            
            removeButton.isHidden = false
            favicon.loadFavicon(forDomain: tab.link?.url.host)
        }
    }
    
    @IBAction func deleteTab() {
        guard let tab = tab else { return }
        self.delegate?.deleteTab(tab: tab)
    }
    
}

extension TabViewCell: Themable {
    
    func decorate(with theme: Theme) {
        border.layer.borderColor = theme.tabSwitcherCellBorderColor.cgColor
        unread.image = Self.unreadImage(for: theme)
        
        background.backgroundColor = theme.tabSwitcherCellBackgroundColor
        title.textColor = theme.tabSwitcherCellTextColor
    }
}

extension TabViewCell: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
 
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        let velocity = pan.velocity(in: self)
        return abs(velocity.y) < abs(velocity.x)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard otherGestureRecognizer == collectionReorderRecognizer else {
            return false
        }
        return true
    }
    
}
