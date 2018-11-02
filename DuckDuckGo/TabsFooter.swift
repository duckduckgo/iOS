//
//  TabsFooter.swift
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
import Core
import WebKit

class TabsFooter: UICollectionReusableView, Themable {

    static let reuseIdentifier = "Footer"
    
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var fireImage: UIImageView!
    @IBOutlet weak var lastLabel: UILabel!

    func decorate(with theme: Theme) {
        firstLabel.textColor = theme.tintOnBlurColor
        lastLabel.textColor = theme.tintOnBlurColor
        fireImage.tintColor = theme.tintOnBlurColor
    }
}
