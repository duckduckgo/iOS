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

class TabViewCell: UICollectionViewCell {
    
    struct Constants {

        static let selectedBorderWidth: CGFloat = 2.0
        static let unselectedBorderWidth: CGFloat = 0.0
        
        static let swipeToDeleteAlpha: CGFloat = 0.5
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

    override func awakeFromNib() {
        super.awakeFromNib()
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handleSwipe(recognizer:)))
        recognizer.delegate = self
        addGestureRecognizer(recognizer)
        
        setupSubviews()
    }
    
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

    func update(withTab tab: Tab,
                isSelectionModeEnabled: Bool,
                preview: UIImage?) {}
    
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
