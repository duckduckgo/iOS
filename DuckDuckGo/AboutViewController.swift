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
    @IBOutlet weak var descriptionText: UILabel!
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
        case .dark:
            logoImage?.image = UIImage(named: "LogoLightText")
        }
        
        decorateDescription(with: theme)
        
        headerText.textColor = theme.aboutScreenTextColor
        moreButton.setTitleColor(theme.aboutScreenButtonColor, for: .normal)
    }
    
    private func decorateDescription(with theme: Theme) {
        if let attributedText = descriptionText.attributedText,
            var font = attributedText.attribute(NSAttributedString.Key.font, at: 0, effectiveRange: nil) as? UIFont {
            
            let attributes: [NSAttributedString.Key: Any]
            if traitCollection.horizontalSizeClass == .regular,
                traitCollection.verticalSizeClass == .regular {
                font = font.withSize(24.0)
                attributes = [.foregroundColor: theme.aboutScreenTextColor,
                              .font: font]
            } else {
                attributes = [.foregroundColor: theme.aboutScreenTextColor,
                              .font: font]
            }

            let decoratedText = NSMutableAttributedString(string: UserText.settingsAboutText)
            decoratedText.addAttributes(attributes, range: NSRange(location: 0, length: decoratedText.length))
            
            descriptionText.attributedText = decoratedText
        }
    }
}
