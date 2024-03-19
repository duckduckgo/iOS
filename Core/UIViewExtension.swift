//
//  UIViewExtension.swift
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

extension UIView {

    public func addEqualSizeConstraints(subView: UIView) {
        addEqualWidthConstraint(subView: subView)
        addEqualHeightConstraint(subView: subView)
    }

    public func addEqualHeightConstraint(subView: UIView) {
        addConstraint(NSLayoutConstraint(
            item: subView,
            attribute: .height, relatedBy: .equal, toItem: self,
            attribute: .height, multiplier: 1, constant: 0))
    }

    public func addEqualWidthConstraint(subView: UIView) {
        addConstraint(NSLayoutConstraint(
            item: subView,
            attribute: .width, relatedBy: .equal, toItem: self,
            attribute: .width, multiplier: 1, constant: 0))
    }

    public func round(corners: UIRectCorner, radius: CGFloat) {
        let cornerRadii = CGSize(width: radius, height: radius)
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: cornerRadii)
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }

    public func blur(style: UIBlurEffect.Style) {
        let blurView = UIVisualEffectView()
        blurView.translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.clear
        insertSubview(blurView, at: 0)
        addEqualWidthConstraint(subView: blurView)
        addEqualHeightConstraint(subView: blurView)
        UIView.animate(withDuration: 0.5) {
            blurView.effect = UIBlurEffect(style: style)
        }
    }

    public func displayDropShadow() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1.5)
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 1.5
    }

    public func clearSubviews() {
        for view in subviews {
            view.removeFromSuperview()
        }
    }

    @MainActor
    public func createImageSnapshot(inBounds bounds: CGRect? = nil) -> UIImage? {
        let bounds = bounds ?? self.frame
        let size = bounds.size
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        UIGraphicsGetCurrentContext()?.translateBy(x: -bounds.origin.x, y: -bounds.origin.y)
        drawHierarchy(in: frame, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

}
