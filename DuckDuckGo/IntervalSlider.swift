//
//  IntervalSlider.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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

class IntervalSlider: UISlider {
    
    private enum Constants {
        static var minAllowedSteps: Int = 2
        static var markWidth: CGFloat = 3.0
        static var markHeight: CGFloat = 9.0
        static var markCornerRadius: CGFloat = 5.0
    }
    
    var steps: Int = Constants.minAllowedSteps {
        didSet {
            if steps < Constants.minAllowedSteps { steps = Constants.minAllowedSteps }
            setNeedsDisplay()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let trackRect = trackRect(forBounds: rect)
        
        let thumbRect = thumbRect(forBounds: rect, trackRect: trackRect, value: 1.0)
        let thumbOffset = Darwin.round(thumbRect.width/2) - 3
        
        let newTrackRect = trackRect.inset(by: UIEdgeInsets(top: 0.0, left: thumbOffset, bottom: 0.0, right: thumbOffset))
                        
        let color: UIColor = UIColor.cornflowerBlue
        let bpath: UIBezierPath = UIBezierPath(rect: newTrackRect)

        color.set()
        bpath.fill()
        
        for i in 0...steps {
            let x = newTrackRect.minX + newTrackRect.width/CGFloat(steps) * CGFloat(i) - Constants.markWidth/2
            let xRounded = Darwin.round(x / 0.5) * 0.5
            
            let markRect = CGRect(x: xRounded, y: newTrackRect.midY - Constants.markHeight/2,
                                  width: Constants.markWidth, height: Constants.markHeight)
            
            let markPath: UIBezierPath = UIBezierPath(roundedRect: markRect, cornerRadius: Constants.markCornerRadius)
            color.set()
        
            markPath.fill()
        }
    }
}
