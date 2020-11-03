//
//  StepSlider.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

class StepSlider: UISlider {
    @IBInspectable
    var interval: Int = 1
    var callback: ((Float) -> Void)!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpSlider()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpSlider()
    }

    private func setUpSlider() {
        addTarget(self, action: #selector(handleValueChange(sender:)), for: .valueChanged)
    }

    @objc func handleValueChange(sender: UISlider) {
        let newValue =  (sender.value / Float(interval)).rounded() * Float(interval)
        setValue(Float(newValue), animated: false)
        callback(Float(newValue))
    }
}
