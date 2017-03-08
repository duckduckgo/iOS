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
        let text = "\(count)"

        UIGraphicsBeginImageContextWithOptions(image.size, false, UIScreen.main.scale)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        text.draw(in: CGRect(origin: point(forCount: count), size: image.size), withAttributes: attributes(forCount: count))
        
        let icon = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return icon
    }
    
    private func point(forCount count: Int) -> CGPoint {
        if isSingleDigit(count) {
            return CGPoint(x: 10.1, y: 3)
        }
        return CGPoint(x: 7.9, y: 4.5)
    }
    
    private func attributes(forCount count: Int) -> [String : NSObject] {
        let size = (isSingleDigit(count)) ? 10 : 8
        let weight = (isSingleDigit(count)) ? 5 : 3
        let font = UIFont.systemFont(ofSize: CGFloat(size), weight: CGFloat(weight))
        return [ NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.white ]
    }
    
    private func isSingleDigit(_ number: Int) -> Bool {
        return number < 10
    }
}
