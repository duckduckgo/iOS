//
//  UseDuckDuckGoInSafariViewController.swift
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

class UseDuckDuckGoInSafariViewController: UIViewController {
    
    @IBOutlet var headerInfoLabel: UILabel!
    @IBOutlet var firstStepLabel: UILabel!
    @IBOutlet var secondStepLabel: UILabel!
    @IBOutlet var thirdStepLabel: UILabel!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationCapturesStatusBarAppearance = true
        
        view.blur(style: .dark)
        
        headerInfoLabel.setAttributedTextString(UserText.settingTutorialInfo)
        
        if let attributes = firstStepLabel.attributedText?.attributes(at: 0, effectiveRange: nil),
            let font = attributes[.font] as? UIFont,
            let color = attributes[.foregroundColor] as? UIColor,
            let style = attributes[.paragraphStyle] as? NSParagraphStyle {
            
            let firstStepText = UserText.settingTutorialOpenStep.attributedStringFromMarkdown(color: color,
                                                                                              lineHeightMultiple: style.lineHeightMultiple,
                                                                                              fontSize: font.pointSize)
            firstStepLabel.attributedText = firstStepText
            
            let secondStepText = UserText.settingTutorialNavigateStep.attributedStringFromMarkdown(color: color,
                                                                                                   lineHeightMultiple: style.lineHeightMultiple,
                                                                                                   fontSize: font.pointSize)
            secondStepLabel.attributedText = secondStepText
            
            let thirdStepText = UserText.settingTutorialSelectStep.attributedStringFromMarkdown(color: color,
                                                                                                lineHeightMultiple: style.lineHeightMultiple,
                                                                                                fontSize: font.pointSize)
            thirdStepLabel.attributedText = thirdStepText
        }
        
    }

    @IBAction func onDonePressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
