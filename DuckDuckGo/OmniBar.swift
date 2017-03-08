//
//  OmniBar.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 17/02/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

extension OmniBar: NibLoading {}

class OmniBar: UIView {
    
    public enum Style: String {
        case home = "OmniBarHome"
        case web = "OmniBarWeb"
    }
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    
    weak var omniDelegate: OmniBarDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    static func loadFromXib(withStyle style: Style) -> OmniBar {
       return OmniBar.load(nibName: style.rawValue)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textField.placeholder = UserText.searchDuckDuckGo
        textField.delegate = self
    }
    
    override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
    
    func clear() {
        textField.text = nil
    }
    
    func refreshText(forUrl url: URL?) {
        guard let url = url else {
            textField.text = nil
            return
        }
        
        if let query = AppUrls.searchQuery(fromUrl: url) {
            textField.text = query
            return
        }
        
        if AppUrls.isDuckDuckGo(url: url) {
            textField.text = nil
            return
        }
        
        textField.text = url.absoluteString
    }
    
    @IBAction func onLeftButtonPressed() {
        omniDelegate?.onLeftButtonPressed()
    }
 
    @IBAction func onRightButtonPressed() {
        omniDelegate?.onRightButtonPressed()
    }
    
    @IBAction func onTextEntered(_ sender: Any) {
        onQuerySubmitted()
    }
    
    func onQuerySubmitted() {
        guard let query = textField.text?.trimWhitespace(), !query.isEmpty else {
            return
        }
        _ = resignFirstResponder()
        if let omniDelegate = omniDelegate {
            omniDelegate.onOmniQuerySubmitted(query)
        }
    }
}

extension OmniBar: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        rightButton.isHidden = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        rightButton.isHidden = false
    }
}
