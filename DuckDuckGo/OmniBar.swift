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
    
    var style: Style!
    
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton?
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    
    weak var omniDelegate: OmniBarDelegate?
    
    static func loadFromXib(withStyle style: Style) -> OmniBar {
        let omniBar = OmniBar.load(nibName: style.rawValue)
        omniBar.style = style
        return omniBar
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        hideDismissButton()
        textField.placeholder = UserText.searchDuckDuckGo
        textField.delegate = self
    }
    
    @discardableResult override func becomeFirstResponder() -> Bool {
        showDismissButton()
        return textField.becomeFirstResponder()
    }
    
    @discardableResult override func resignFirstResponder() -> Bool {
        hideDismissButton()
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
    
    func showDismissButton() {
        // TODO
    }
    
    func hideDismissButton() {
        // TODO
    }
    
    @IBAction func onActionButtonPressed() {
        omniDelegate?.onActionButtonPressed()
    }
    
    @IBAction func onRefreshButtonPressed() {
        omniDelegate?.onRefreshButtonPressed()
    }
    
    @IBAction func onDismissButtonPressed() {
        omniDelegate?.onDismissButtonPressed()
    }
    
    @IBAction func onTextEntered(_ sender: Any) {
        onQuerySubmitted()
    }
    
    func onQuerySubmitted() {
        guard let query = textField.text?.trimWhitespace(), !query.isEmpty else {
            return
        }
        resignFirstResponder()
        if let omniDelegate = omniDelegate {
            omniDelegate.onOmniQuerySubmitted(query)
        }
    }
}

extension OmniBar: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        refreshButton?.isHidden = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let oldQuery = textField.text,
              let queryRange = oldQuery.range(from: range) else {
            return true
        }
        let newQuery = oldQuery.replacingCharacters(in: queryRange, with: string)
        omniDelegate?.onOmniQueryUpdated(newQuery)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        refreshButton?.isHidden = false
    }
}

extension String {
    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = from16.samePosition(in: self),
            let to = to16.samePosition(in: self)
            else { return nil }
        return from ..< to
    }
}
