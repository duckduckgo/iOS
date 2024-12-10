//
//  FaviconHelper.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

import Foundation
import Common
import Core
import UIKit

struct FaviconHelper {

    static func loadImageFromCache(forDomain domain: String?, preferredFakeFaviconLetters: String) -> UIImage? {
        guard let domain = domain,
              let cacheUrl = FaviconsCacheType.fireproof.cacheLocation() else { return nil }

        let key = FaviconHasher.createHash(ofDomain: domain)

        // Slight leap here to avoid loading Kingfisher as a library for the widgets.
        // Once dependency management is fixed, link it and use Favicons directly.
        let imageUrl = cacheUrl.appendingPathComponent("com.onevcat.Kingfisher.ImageCache.fireproof").appendingPathComponent(key)

        guard let data = (try? Data(contentsOf: imageUrl)) else {
            let image = Self.createFakeFavicon(forDomain: domain, size: 32, backgroundColor: UIColor.forDomain(domain), preferredFakeFaviconLetters: preferredFakeFaviconLetters)
            return image
        }

        return UIImage(data: data)?.toSRGB()
    }

    private static func createFakeFavicon(forDomain domain: String,
                                          size: CGFloat = 192,
                                          backgroundColor: UIColor = UIColor.red,
                                          bold: Bool = true,
                                          preferredFakeFaviconLetters: String? = nil,
                                          letterCount: Int = 2) -> UIImage? {

        let cornerRadius = size * 0.125
        let imageRect = CGRect(x: 0, y: 0, width: size, height: size)
        let padding = size * 0.16
        let labelFrame = CGRect(x: padding, y: padding, width: imageRect.width - (2 * padding), height: imageRect.height - (2 * padding))

        let renderer = UIGraphicsImageRenderer(size: imageRect.size)
        let icon = renderer.image { imageContext in
            let context = imageContext.cgContext

            context.setFillColor(backgroundColor.cgColor)
            context.addPath(CGPath(roundedRect: imageRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil))
            context.fillPath()

            let label = UILabel(frame: labelFrame)
            label.numberOfLines = 1
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.1
            label.baselineAdjustment = .alignCenters
            label.font = bold ? UIFont.boldSystemFont(ofSize: size) : UIFont.systemFont(ofSize: size)
            label.textColor = .white
            label.textAlignment = .center

            if let preferedPrefix = preferredFakeFaviconLetters?.droppingWwwPrefix().prefix(letterCount).capitalized {
                label.text = preferedPrefix
            } else {
                label.text = preferredFakeFaviconLetters?.capitalized ?? "#"
            }

            context.translateBy(x: padding, y: padding)

            label.layer.draw(in: context)
        }

        return icon.withRenderingMode(.alwaysOriginal)
    }
}
