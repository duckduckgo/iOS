//
//  AboutViewController.swift
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

class AboutViewController: UIViewController {

    @IBOutlet weak var headerText: UILabel!
    // These are duplicated, as UILabel that is set up with sizing classes
    // does not apply changes to attributed string
    @IBOutlet weak var descriptionTextLight: UILabel!
    @IBOutlet weak var descriptionTextDark: UILabel!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var moreButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyTheme(ThemeManager.shared.currentTheme)
    }

    @IBAction func onPrivacyLinkTapped(_ sender: UIButton) {
        dismiss(animated: true) {
            UIApplication.shared.open(AppDeepLinks.aboutLink, options: [:])
        }
    }
}

extension AboutViewController: Themable {
    
    func decorate(with theme: Theme) {
        view.backgroundColor = theme.backgroundColor
        
        switch theme.currentImageSet {
        case .light:
            logoImage?.image = UIImage(named: "LogoDarkText")
            descriptionTextLight.isHidden = true
            descriptionTextDark.isHidden = false
        case .dark:
            logoImage?.image = UIImage(named: "LogoLightText")
            descriptionTextLight.isHidden = false
            descriptionTextDark.isHidden = true
        }
        
        headerText.textColor = theme.aboutScreenTextColor
        moreButton.setTitleColor(theme.aboutScreenButtonColor, for: .normal)
    }
}
