//
//  BrowsingMenuButton.swift
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

extension BrowsingMenuButton: NibLoading {}

class BrowsingMenuButton: UIView {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    private var action: () -> Void = {}
    
    static func loadFromXib() -> BrowsingMenuButton {
        return BrowsingMenuButton.load(nibName: "BrowsingMenuButton")
    }
    
    func configure(with icon: UIImage, label: String, action: @escaping () -> Void) {
        image.image = icon
        self.label.setAttributedTextString(label)
        self.action = action
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        backgroundColor = .red
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        if !bounds.contains(location) {
            backgroundColor = .clear
        } else {
            backgroundColor = .red
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        if bounds.contains(location) {
            action()
        }
        
        backgroundColor = .clear
    }
    
}
