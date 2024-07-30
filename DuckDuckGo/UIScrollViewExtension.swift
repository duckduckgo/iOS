//
//  UIScrollViewExtension.swift
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

extension UIScrollView {
    
    struct Constants {
        static let scrollToMargin: CGFloat = 15
    }
    
    /// Calculates rect to scroll to based on what is most useful area for a user and size/position of the keyboard.
    func desiredVisibleRect(forInteractionArea interactionArea: CGRect,
                            coveredBy keyboardRect: CGRect) -> CGRect? {
        guard let window = UIApplication.shared.firstKeyWindow else { return nil }
        
        let viewInWindow = convert(bounds, to: window)
        let obscuredScrollViewArea = viewInWindow.intersection(keyboardRect)
        
        guard obscuredScrollViewArea.size.height > 0 else { return nil }
        
        let visibleScrollViewAreaHeight = bounds.height - obscuredScrollViewArea.size.height
        
        let offset: CGFloat
        if interactionArea.height + Constants.scrollToMargin > visibleScrollViewAreaHeight {
            offset = interactionArea.origin.y - Constants.scrollToMargin
        } else {
            offset = interactionArea.origin.y + Constants.scrollToMargin - (visibleScrollViewAreaHeight - interactionArea.size.height)
        }
        
        guard offset > 0 else { return nil }
        
        return CGRect(x: interactionArea.origin.x,
                      y: offset,
                      width: interactionArea.size.width,
                      height: visibleScrollViewAreaHeight)
    }
}
