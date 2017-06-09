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
    
    struct Measurement {
        static let barHeight: CGFloat = 52
        static let leftMargin: CGFloat = 8
        static let rightMargin: CGFloat = 8
        static let topMargin: CGFloat = 4
        static let height: CGFloat = 40
        static var width: CGFloat {
            return InterfaceMeasurement.screenWidth - leftMargin - rightMargin
        }
    }
    
    public static let menuButtonTag = 100
    
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var menuButton: UIButton!
    
    weak var omniDelegate: OmniBarDelegate?
    
    static func loadFromXib() -> OmniBar {
        let omnibar = OmniBar.load(nibName: "OmniBar")
        omnibar.frame = CGRect(x: Measurement.leftMargin, y: Measurement.topMargin, width: Measurement.width, height: Measurement.height)
        return omnibar
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        menuButton.tag = OmniBar.menuButtonTag
        configureTextField()
    }
    
    private func configureTextField() {
        textField.placeholder = UserText.searchDuckDuckGo
        textField.delegate = self
    }
    
    @discardableResult override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    @discardableResult override func resignFirstResponder() -> Bool {
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
    
    func showDismissButton(_ show: Bool) {
        dismissButton.isHidden = !show
    }
    
    func showMenuButton(_ show: Bool) {
        menuButton.isHidden = !show
    }
    
    @IBAction func onDismissButtonPressed() {
        resignFirstResponder()
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
    
    @IBAction func onMenuButtonPressed(_ sender: UIButton) {
        omniDelegate?.onMenuPressed()
    }
}

extension OmniBar: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        showDismissButton(true)
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
        showDismissButton(false)
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

