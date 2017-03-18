//
//  TabIconMaker.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 22/02/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit


class TabIconMaker {
    
    func icon(forTabs count: Int) -> UIImage {
        
        let image = #imageLiteral(resourceName: "Tabs")
        let text = count < 100 ? "\(count)" : "~"

        UIGraphicsBeginImageContextWithOptions(image.size, false, UIScreen.main.scale)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        text.draw(in: CGRect(origin: point(forText: text), size: image.size), withAttributes: attributes(forText: text))
        
        let icon = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return icon
    }
    
    private func point(forText text: String) -> CGPoint {
        if isSingleChar(text) {
            return CGPoint(x: 10.1, y: 3)
        }
        return CGPoint(x: 7.9, y: 4.5)
    }
    
    private func attributes(forText text: String) -> [String : NSObject] {
        let size = (isSingleChar(text)) ? 10 : 8
        let weight = (isSingleChar(text)) ? 5 : 3
        let font = UIFont.systemFont(ofSize: CGFloat(size), weight: CGFloat(weight))
        return [ NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.white ]
    }
    
    private func isSingleChar(_ text: String) -> Bool {
        return text.characters.count == 1
    }
}
