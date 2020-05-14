//
//  DaxDialogViewController.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 13/05/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import UIKit

class DaxDialogViewController: UIViewController {
    
    @IBOutlet weak var icon: UIView!
    @IBOutlet weak var pointer: UIView!
    @IBOutlet weak var textArea: UIView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    
    var message: String? {
        didSet {
            label.text = nil
            chars = Array(message ?? "")
        }
    }
    
    var cta: String? {
        didSet {
            if let title = cta {
                button.isHidden = false
                button.setTitle(title, for: .normal)
            }
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
        applyPointerRotation()
        textArea.displayDropShadow()
        button.displayDropShadow()
        button.isHidden = true
    }
    
    func applyPointerRotation() {
        let rads = CGFloat(45 * Double.pi / 180)
        pointer.layer.transform = CATransform3DMakeRotation(rads, 0.0, 0.0, 1.0)
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
        guard let message = message else { return }
        label.attributedText = String(Array(message)[0 ..< position]).attributedStringFromMarkdown(fontSize: isSmall ? 15 : 16)
    }
     
}
