//
//  FireBarButtonItem.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

final class FireBarButtonItem: UIBarButtonItem {
    
    private(set) var button: FireButton?
    
    override var tintColor: UIColor? {
        didSet {
            button?.tintColor = tintColor
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupEmbeddedFireButton()
    }
    
    private func setupEmbeddedFireButton() {
        button = FireButton(type: .system)
        
        button?.setImage(image, for: .normal)
        button?.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        
        customView = button
    }
    
    @IBAction func onButtonPressed(_ sender: Any) {
        guard let target = target, let action = action else { return }
        
        UIApplication.shared.sendAction(action, to: target, from: nil, for: nil)
    }
    
    public func playAnimation() {
        button?.playAnimation()
    }
    
    public func stopAnimation() {
        button?.stopAnimation()
    }
}
