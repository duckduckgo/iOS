//
//  TabBarCell.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 27/07/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

// (WIP) spacer between tabs
// (WIP) increase to 8 above address bar
// (WIP) align tab bar icons vertically with close button
// (WIP) highlight tabs for pointer
// (WIP) use width > 375 then use ipad view
// (WIP) new tab + keyboard, home screen non-responsive

class TabsBarCell: UICollectionViewCell {
    
    static let appUrls = AppUrls()
    
    @IBOutlet weak var label: FadeOutLabel!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var faviconImage: UIImageView!
    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var bottomBackgroundView: UIView!
    @IBOutlet var labelRemoveButtonConstraint: NSLayoutConstraint!
    
    var isPressed = false {
        didSet {
            setNeedsLayout()
        }
    }
    
    var onRemove: (() -> Void)?

    private var model: Tab?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if #available(iOS 13.4, *) {
            removeButton.isPointerInteractionEnabled = true
            removeButton.pointerStyleProvider = { button, effect, shape -> UIPointerStyle? in
                return .init(effect: .lift(.init(view: button)))
            }
        }
        
    }
    
    @IBAction func onRemovePressed() {
        onRemove?()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bottomBackgroundView.isHidden = isPressed
        contentView.layer.cornerRadius = isPressed ? 8 : 0
        contentView.layer.borderColor = isPressed ? ThemeManager.shared.currentTheme.barTintColor.cgColor : UIColor.clear.cgColor
        contentView.layer.borderWidth = isPressed ? 1 : 0
        
    }

    func update(model: Tab, isCurrent: Bool, withTheme theme: Theme) {
        accessibilityElements = [label as Any, removeButton as Any]
        
        self.model?.removeObserver(self)
        self.model = model
        model.addObserver(self)

        label.primaryColor = theme.barTintColor
        if isCurrent {
            topBackgroundView.backgroundColor = theme.barBackgroundColor
            bottomBackgroundView.backgroundColor = theme.barBackgroundColor
        } else {
            topBackgroundView.backgroundColor = .clear
            bottomBackgroundView.backgroundColor = .clear
        }

        labelRemoveButtonConstraint.isActive = isCurrent
        removeButton.isHidden = !isCurrent
        
        applyModel(model)
    }
    
    private func applyModel(_ model: Tab) {
        
        if model.link == nil {
            label.text = UserText.homeTabTitle
            faviconImage.loadFavicon(forDomain: Self.appUrls.base.host, usingCache: .tabs)
            label.accessibilityLabel = UserText.openHomeTab
            removeButton.accessibilityLabel = UserText.closeHomeTab
        } else {
            label.text = model.link?.displayTitle ?? model.link?.url.host?.dropPrefix(prefix: "www.")
            faviconImage.loadFavicon(forDomain: model.link?.url.host, usingCache: .tabs)
            label.accessibilityLabel = UserText.openTab(withTitle: model.link?.displayTitle ?? "", atAddress: model.link?.url.host ?? "")
            removeButton.accessibilityLabel = UserText.closeTab(withTitle: model.link?.displayTitle ?? "", atAddress: model.link?.url.host ?? "")
        }

    }
    
}

extension TabsBarCell: TabObserver {
    func didChange(tab: Tab) {
        applyModel(tab)
    }
}

// Based on https://stackoverflow.com/a/53847223/73479
class FadeOutLabel: UILabel {
    
    var primaryColor: UIColor = .black
        
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
                                        locations: [0.5, 1]) else { return nil }

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
