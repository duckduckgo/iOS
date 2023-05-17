//
//  TabsBarCell.swift
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
import DesignResourcesKit

class TabsBarCell: UICollectionViewCell {

    @IBOutlet weak var label: FadeOutLabel!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var faviconImage: UIImageView!
    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var bottomBackgroundView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet var labelRemoveButtonConstraint: NSLayoutConstraint!
    
    var isPressed = false {
        didSet {
            setNeedsLayout()
        }
    }
    
    var onRemove: (() -> Void)?

    private weak var model: Tab?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        removeButton.isPointerInteractionEnabled = true
        removeButton.pointerStyleProvider = { button, _, _ -> UIPointerStyle? in
            return .init(effect: .lift(.init(view: button)))
        }
        
        contentView.addInteraction(UIPointerInteraction(delegate: self))
    }
    
    @IBAction func onRemovePressed() {
        onRemove?()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isPressed {
            layer.masksToBounds = false
            layer.shadowColor = UIColor.darkGray.cgColor
            layer.shadowOffset = CGSize(width: 0, height: 0)
            layer.shadowOpacity = 0.2
            layer.shadowRadius = 5
        } else {
            layer.masksToBounds = true
            layer.shadowColor = nil
            layer.shadowRadius = 0
        }
        
    }

    func update(model: Tab, isCurrent: Bool, isNextCurrent: Bool, withTheme theme: Theme) {
        
        accessibilityElements = [label as Any, removeButton as Any]
        
        self.model?.removeObserver(self)
        
        self.model = model
        model.addObserver(self)

        label.primaryColor = theme.barTintColor
        if isCurrent {
            topBackgroundView.backgroundColor = theme.omniBarBackgroundColor
            bottomBackgroundView.backgroundColor = theme.omniBarBackgroundColor
        } else {
            topBackgroundView.backgroundColor = .clear
            bottomBackgroundView.backgroundColor = .clear
            separatorView.backgroundColor = theme.tabsBarSeparatorColor
        }

        labelRemoveButtonConstraint.isActive = isCurrent
        separatorView.isHidden = isCurrent || isNextCurrent
        removeButton.isHidden = !isCurrent
        
        applyModel(model)
    }
    
    private func applyModel(_ model: Tab) {
        
        if model.link == nil {
            faviconImage.loadFavicon(forDomain: URL.ddg.host, usingCache: .tabs)
            label.text = UserText.homeTabTitle
            label.accessibilityLabel = UserText.openHomeTab
            removeButton.accessibilityLabel = UserText.closeHomeTab
        } else {
            faviconImage.loadFavicon(forDomain: model.link?.url.host, usingCache: .tabs)
            label.text = model.link?.displayTitle ?? model.link?.url.host?.droppingWwwPrefix()
            label.accessibilityLabel = UserText.openTab(withTitle: model.link?.displayTitle ?? "", atAddress: model.link?.url.host ?? "")
            removeButton.accessibilityLabel = UserText.closeTab(withTitle: model.link?.displayTitle ?? "", atAddress: model.link?.url.host ?? "")
        }

    }
    
}

extension TabsBarCell: TabObserver {
    func didChange(tab: Tab) {
        guard tab != self.model else { return }
        applyModel(tab)
    }
}

extension TabsBarCell: UIPointerInteractionDelegate {
    
    func pointerInteraction(_ interaction: UIPointerInteraction, styleFor region: UIPointerRegion) -> UIPointerStyle? {
        return .init(effect: .highlight(.init(view: contentView)))
    }
    
}

// Based on https://stackoverflow.com/a/53847223/73479
class FadeOutLabel: UILabel {
    
    var primaryColor: UIColor = .black {
        didSet {
            setNeedsDisplay()
        }
    }

    override func drawText(in rect: CGRect) {
        let gradientColors = [primaryColor.cgColor, UIColor.clear.cgColor]
        if let gradientColor = drawGradientColor(in: rect, colors: gradientColors) {
            self.textColor = gradientColor
        }
        super.drawText(in: rect)
    }

    private func drawGradientColor(in rect: CGRect, colors: [CGColor]) -> UIColor? {
        let currentContext = UIGraphicsGetCurrentContext()
        currentContext?.saveGState()
        defer { currentContext?.restoreGState() }

        let size = rect.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                        colors: colors as CFArray,
                                        locations: [0.8, 1]) else { return nil }

        let context = UIGraphicsGetCurrentContext()
        context?.drawLinearGradient(gradient,
                                    start: .zero,
                                    end: CGPoint(x: size.width, y: 0),
                                    options: [])
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let image = gradientImage else { return nil }
        return UIColor(patternImage: image)
    }
    
}
