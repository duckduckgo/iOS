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
         
    private var position: Int = 0
    private var chars = [Character]()
    
    private func atEnd(_ position: Int) -> Bool {
        return position >= chars.count
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        print(".", terminator: "")
        guard let message = message else { return }
        label.attributedText = attributedString(from: String(Array(message)[0 ..< position]))
    }
    
    private func attributedString(from string: String) -> NSAttributedString {
        return string.attributedStringFromMarkdown(fontSize: isSmall ? 16 : 18)
    }
     
}

extension NSAttributedString {
    
    func requiredTextHeight(forWidth width: CGFloat) -> CGFloat {
        let framesetter = CTFramesetterCreateWithAttributedString(self)
        let emptyRange = CFRange(location: 0, length: 0)
        
        if #available(iOS 11.0, *) {
            let constraints = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
            let height = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, emptyRange, nil, constraints, nil).height
            return height
        } else {
            let path = CGPath(rect: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude), transform: nil)
            let frame = CTFramesetterCreateFrame(framesetter, emptyRange, path, nil)
            let lines = CTFrameGetLines(frame)
            let numberOfLines = CFArrayGetCount(lines)
            var height: CGFloat = 0
            for index in 0..<numberOfLines {
                let line: CTLine = unsafeBitCast(CFArrayGetValueAtIndex(lines, index), to: CTLine.self)
                let rect = CTLineGetBoundsWithOptions(line,
                                                      [ .includeLanguageExtents, .useOpticalBounds, .useHangingPunctuation, .useGlyphPathBounds ])
                height += rect.height
                let numberOfGlyphs = CTLineGetGlyphCount(line)
                if numberOfGlyphs > 0 {
                    height += 5
                }
            }
            return height
        }
    }
    
 }
