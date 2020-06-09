//
//  DaxDialogViewController.swift
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

class DaxDialogViewController: UIViewController {
    
    @IBOutlet weak var bottomSpacing: NSLayoutConstraint!
    @IBOutlet weak var topSpacing: NSLayoutConstraint!

    @IBOutlet weak var icon: UIView!
    @IBOutlet weak var pointer: UIView!
    @IBOutlet weak var textArea: UIView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    
    var message: String? {
        didSet {
            initLabel()
        }
    }
    var cta: String? {
        didSet {
            initCTA()
        }
    }
    
    var onTapCta: (() -> Void)?
    var theme: Theme? {
        didSet {
            applyTheme(theme ?? ThemeManager.shared.currentTheme)
        }
    }
    
    private var position: Int = 0
    private var chars = [Character]()
    
    private func atEnd(_ position: Int) -> Bool {
        return position >= chars.count
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyTheme(theme ?? ThemeManager.shared.currentTheme)
        
        initLabel()
        initCTA()
        
        applyPointerRotation()
        textArea.displayDropShadow()
        button.displayDropShadow()
    }
    
    private func initLabel() {
        label?.text = nil
        chars = Array(message ?? "")
    }
    
    private func applyPointerRotation() {
        let rads = CGFloat(45 * Double.pi / 180)
        pointer.layer.transform = CATransform3DMakeRotation(rads, 0.0, 0.0, 1.0)
    }
    
    private func initCTA() {
        if let title = cta {
            button?.isHidden = false
            button?.setTitle(title, for: .normal)
        } else {
            button?.isHidden = true
        }
    }
    
    func start() {
        position = 0
        showNextChar()
    }
    
    func finish() {
        position = chars.count
        updateMessage()
    }
    
    @IBAction func onTapText() {
        finish()
    }
    
    @IBAction func onButtonTap() {
        onTapCta?()
    }
    
    func reset() {
        position = 0
        updateMessage()
    }
    
    private func showNextChar() {
        guard !atEnd(position) else { return }
        
        position += 1
        while !atEnd(position) && (chars[position].isWhitespace || chars[position].isMarkdownIndicator) {
            position += 1
        }
        updateMessage()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            self.showNextChar()
        }
    }
    
    private func updateMessage() {
        guard let message = message else { return }
        label.attributedText = attributedString(from: String(Array(message)[0 ..< position]))
    }
    
    private func attributedString(from string: String) -> NSAttributedString {
        let theme = self.theme ?? ThemeManager.shared.currentTheme
        return string.attributedStringFromMarkdown(color: theme.daxDialogTextColor, fontSize: isSmall ? 16 : 18)
    }
     
}

extension DaxDialogViewController: Themable {

    func decorate(with theme: Theme) {
        let themeToUse = self.theme ?? theme
        textArea.backgroundColor = themeToUse.daxDialogBackgroundColor
        pointer.backgroundColor = themeToUse.daxDialogBackgroundColor
        finish() // skip animation if user changes theme, this forces update
    }
    
}
