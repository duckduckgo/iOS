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

protocol TabViewCellDelegate: AnyObject {

    func deleteTab(tab: Tab)

    func isCurrent(tab: Tab) -> Bool
    
}

final class TabViewCell: UICollectionViewCell {

    struct Constants {

        static let swipeToDeleteAlpha: CGFloat = 0.5

        static let cellCornerRadius: CGFloat = 8.0
        static let cellHeaderHeight: CGFloat = 38.0
        static let cellLogoSize: CGFloat = 68.0

        static let selectedBorderWidth: CGFloat = 2.0
        static let unselectedBorderWidth: CGFloat = 0.0
   }

    var removeThreshold: CGFloat {
        return frame.width / 3
    }

    weak var delegate: TabViewCellDelegate?
    weak var tab: Tab?

    var isCurrent = false
    var isDeleting = false
    var canDelete = false
    var isSelectionModeEnabled = false

    static let gridReuseIdentifier = "TabViewGridCell"
    static let listReuseIdentifier = "TabViewListCell"

    @IBOutlet weak var background: UIView!
    @IBOutlet weak var border: UIView!
    @IBOutlet weak var favicon: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var unread: UIImageView!
    @IBOutlet weak var selectionIndicator: UIImageView!

    // List view
    @IBOutlet weak var link: UILabel?

    // Grid view
    @IBOutlet weak var preview: UIImageView?

    weak var previewAspectRatio: NSLayoutConstraint?
    @IBOutlet var previewTopConstraint: NSLayoutConstraint?
    @IBOutlet var previewBottomConstraint: NSLayoutConstraint?
    @IBOutlet var previewTrailingConstraint: NSLayoutConstraint?

    func setupSubviews() {
        backgroundColor = .clear
        layer.cornerRadius = backgroundView?.layer.cornerRadius ?? 0.0
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 3.0
        layer.shadowOpacity = 0.15
        layer.masksToBounds = false
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale

        unread.tintColor = .cornflowerBlue
    }

    private func updatePreviewToDisplay(image: UIImage) {
        let imageAspectRatio = image.size.height / image.size.width
        let containerAspectRatio = (background.bounds.height - TabViewCell.Constants.cellHeaderHeight) / background.bounds.width

        let strechContainerVerically = containerAspectRatio < imageAspectRatio

        if let constraint = previewAspectRatio {
            preview?.removeConstraint(constraint)
        }

        previewTopConstraint?.constant = Constants.cellHeaderHeight
        previewBottomConstraint?.isActive = !strechContainerVerically
        previewTrailingConstraint?.isActive = strechContainerVerically

        if let preview {
            previewAspectRatio = preview.heightAnchor.constraint(equalTo: preview.widthAnchor, multiplier: imageAspectRatio)
            previewAspectRatio?.isActive = true
        }
    }

    private func updatePreviewToDisplayLogo() {
        if let constraint = previewAspectRatio {
            preview?.removeConstraint(constraint)
            previewAspectRatio = nil
        }

        previewTopConstraint?.constant = 0
        previewBottomConstraint?.isActive = true
        previewTrailingConstraint?.isActive = true
    }

    private static var unreadImageAsset: UIImageAsset {

        func unreadImage(for style: UIUserInterfaceStyle) -> UIImage {
            let color = ThemeManager.shared.currentTheme.tabSwitcherCellBackgroundColor.resolvedColor(with: .init(userInterfaceStyle: style))
            let image = UIImage.stackedIconImage(withIconImage: UIImage(resource: .tabUnread),
                                                 borderWidth: 6.0,
                                                 foregroundColor: .cornflowerBlue,
                                                 borderColor: color)
            return image
        }

        let asset = UIImageAsset()

        asset.register(unreadImage(for: .dark), with: .init(userInterfaceStyle: .dark))
        asset.register(unreadImage(for: .light), with: .init(userInterfaceStyle: .light))

        return asset
    }

    static let logoImage: UIImage = {
        let image = UIImage(resource: .logo)
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

    override func awakeFromNib() {
        super.awakeFromNib()
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handleSwipe(recognizer:)))
        recognizer.delegate = self
        addGestureRecognizer(recognizer)

        setupSubviews()
    }

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
        self.isDeleting = true
        Pixel.fire(pixel: .tabSwitcherSwipeCloseTab)
        self.deleteTab()
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform.identity.translatedBy(x: -self.frame.width, y: 0)
        }, completion: { _ in
            self.isHidden = true
        })
    }

    private func startCancelAnimation() {
        UIView.animate(withDuration: 0.2) {
            self.transform = .identity
        }
    }

    func toggleSelection() {
        updateSelectionIndicator(selectionIndicator)
        updateCurrentTabBorder(border)
    }

    func closeTab() {
        guard let tab = tab else { return }
        self.delegate?.deleteTab(tab: tab)
    }

    @IBAction func deleteTab() {
        Pixel.fire(pixel: .tabSwitcherClickCloseTab)
        closeTab()
    }

    func updateSelectionIndicator(_ image: UIImageView) {
        if !isSelected {
            image.image = UIImage(systemName: "circle")
        } else {
            image.image = UIImage(systemName: "checkmark.circle.fill")
            let symbolColorConfiguration = UIImage.SymbolConfiguration(paletteColors: [
                .white, // The check
                .clear, // This does nothing in this palette
                UIColor(designSystemColor: .accent), // The filled background of the circle
            ])
            image.image = UIImage(systemName: "checkmark.circle.fill")?.applyingSymbolConfiguration(symbolColorConfiguration)
        }
    }

    func updateCurrentTabBorder(_ border: UIView) {
        let showBorder = isSelectionModeEnabled ? isSelected : isCurrent
        border.layer.borderColor = UIColor(designSystemColor: isSelectionModeEnabled ? .accent : .textPrimary).cgColor
        border.layer.borderWidth = showBorder ? Constants.selectedBorderWidth : Constants.unselectedBorderWidth
    }

    func updateUIForSelectionMode(_ removeButton: UIButton, _ selectionIndicator: UIImageView) {

        if isSelectionModeEnabled {
            removeButton.isHidden = true
            selectionIndicator.isHidden = false
            updateSelectionIndicator(selectionIndicator)
        } else {
            selectionIndicator.isHidden = true
        }
    }

    func update(withTab tab: Tab,
                isSelectionModeEnabled: Bool,
                preview: UIImage?) {
        accessibilityElements = [ title as Any, removeButton as Any ]

        self.tab = tab
        self.isSelectionModeEnabled = isSelectionModeEnabled

        if !isDeleting {
            isHidden = false
        }
        isCurrent = delegate?.isCurrent(tab: tab) ?? false

        decorate()

        updateCurrentTabBorder(border)

        if let link = tab.link {
            removeButton.accessibilityLabel = UserText.closeTab(withTitle: link.displayTitle, atAddress: link.url.host ?? "")
            title.accessibilityLabel = UserText.openTab(withTitle: link.displayTitle, atAddress: link.url.host ?? "")
            title.text = tab.link?.displayTitle
        }

        unread.isHidden = tab.viewed

        if tab.link == nil {
            updatePreviewToDisplayLogo()
            self.preview?.image = Self.logoImage
            self.preview?.contentMode = .center

            link?.text = UserText.homeTabSearchAndFavorites
            title.text = UserText.homeTabTitle
            favicon.image = UIImage(named: "Logo")
            unread.isHidden = true
            self.preview?.isHidden = !tab.viewed
            title.isHidden = !tab.viewed
            favicon.isHidden = !tab.viewed
            removeButton.isHidden = !tab.viewed

        } else {
            link?.text = tab.link?.url.absoluteString ?? ""

            // Duck Player videos
            if let url = tab.link?.url, url.isDuckPlayer {
                favicon.image = UIImage(named: "DuckPlayerURLIcon")
            } else {
                favicon.loadFavicon(forDomain: tab.link?.url.host, usingCache: .tabs)
            }

            if let preview = preview {
                self.updatePreviewToDisplay(image: preview)
                self.preview?.contentMode = .scaleAspectFill
                self.preview?.image = preview
            } else {
                self.preview?.image = nil
            }

            removeButton.isHidden = false

        }

        updateUIForSelectionMode(removeButton, selectionIndicator)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            setBorderColor()
        }
    }

    private func decorate() {
        let theme = ThemeManager.shared.currentTheme
        setBorderColor()
        unread.image = Self.unreadImageAsset.image(with: .current)

        background.backgroundColor = theme.tabSwitcherCellBackgroundColor
        title.textColor = theme.tabSwitcherCellTextColor
    }

    private func setBorderColor() {
        border.layer.borderColor = ThemeManager.shared.currentTheme.tabSwitcherCellBorderColor.cgColor
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

}
