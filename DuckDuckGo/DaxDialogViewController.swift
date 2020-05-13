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
                button.setTitle(title, for: .normal)
            } else {
                button.isHidden = true
            }
        }
    }
    
    var onTapCta: (() -> Void)?
    
    private var position: Int = 0
    private var chars = [Character]()
    
    private lazy var paragraphStyle: NSParagraphStyle = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.17
        return paragraphStyle
    }()
    
    private var atEnd: Bool {
        return position >= chars.count
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyPointerRotation()
        textArea.displayDropShadow()
        button.displayDropShadow()
    }
    
    func applyPointerRotation() {
        let rads = CGFloat(45 * Double.pi / 180)
        pointer.layer.transform = CATransform3DMakeRotation(rads, 0.0, 0.0, 1.0)
    }
    
    func start() {
        position = 0
        showNextChar()
    }
    
    @IBAction func onTapText() {
        position = chars.count
        updateMessage()
    }
    
    @IBAction func onButtonTap() {
        onTapCta?()
    }
    
    private func showNextChar() {
        guard !atEnd else { return }
        
        position += 1
        while !atEnd && self.chars[position].isWhitespace {
            position += 1
        }
        updateMessage()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            self.showNextChar()
        }
    }

    private func updateMessage() {
        let message = String(chars[0 ..< position])
        label.attributedText = NSMutableAttributedString(string: message, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
    }
    
}
