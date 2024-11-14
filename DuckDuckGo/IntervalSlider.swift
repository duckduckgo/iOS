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
import SwiftUI

class IntervalSlider: UISlider {
    
    private enum Constants {
        static var markWidth: CGFloat = 3.0
        static var markHeight: CGFloat = 9.0
        static var markCornerRadius: CGFloat = 5.0
    }
    
    var steps: [Int] = [] {
        didSet {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let trackRect = trackRect(forBounds: rect)
        
        let thumbRect = thumbRect(forBounds: rect, trackRect: trackRect, value: 1.0)
        let thumbOffset = Darwin.round(thumbRect.width/2) - 3

        let newTrackRect = trackRect.inset(by: UIEdgeInsets(top: 0.0, left: thumbOffset, bottom: 0.0, right: thumbOffset))

        guard steps.count > 1 else { return }
        for i in 0...steps.count-1 {
            let x = newTrackRect.minX + newTrackRect.width/CGFloat(steps.count-1) * CGFloat(i) - Constants.markWidth/2
            let xRounded = Darwin.round(x / 0.5) * 0.5
            
            let markRect = CGRect(x: xRounded, y: newTrackRect.midY - Constants.markHeight/2,
                                  width: Constants.markWidth, height: Constants.markHeight)
            
            let markPath: UIBezierPath = UIBezierPath(roundedRect: markRect, cornerRadius: Constants.markCornerRadius)

            if Int(self.value) >= i {
                minimumTrackTintColor?.set()
            } else {
                maximumTrackTintColor?.set()
            }

            markPath.fill()
        }
    }

    override var accessibilityValue: String? {
        get {
            let index = Int(self.value)
            guard steps.indices.contains(index) else { return "" }
            return "\(steps[index])%"
        }
        set {}
    }

}

struct IntervalSliderRepresentable: UIViewRepresentable {

    @Binding var value: Int

    let steps: [Int]

    func makeUIView(context: Context) -> IntervalSlider {
        let slider = IntervalSlider(frame: .zero)
        slider.minimumTrackTintColor = UIColor(designSystemColor: .accent)
        slider.maximumTrackTintColor = UIColor.systemGray3
        slider.steps = steps
        slider.minimumValue = Float(0)
        slider.maximumValue = Float(steps.count - 1)
        slider.addTarget(context.coordinator, action: #selector(Coordinator.valueChanged(_:)), for: .valueChanged)
        return slider
    }

    func updateUIView(_ uiView: IntervalSlider, context: Context) {
        uiView.value = Float(value)
        uiView.setNeedsDisplay()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: IntervalSliderRepresentable

        init(_ parent: IntervalSliderRepresentable) {
            self.parent = parent
        }

        @objc func valueChanged(_ sender: IntervalSlider) {
            let roundedValue = round(sender.value)
            sender.value = roundedValue
            if Int(roundedValue) != parent.value {
                parent.value = Int(roundedValue)
                sender.setNeedsDisplay()
            }
        }
    }
}
