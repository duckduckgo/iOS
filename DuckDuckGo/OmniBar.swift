//
//  OmniBar.swift
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

extension OmniBar: NibLoading {}

class OmniBar: UIView {

    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var siteRatingView: SiteRatingView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var bookmarksButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!

    weak var omniDelegate: OmniBarDelegate?
    fileprivate var state: OmniBarState = HomeEmptyEditingState()    
    private lazy var appUrls: AppUrls = AppUrls()
    
    static func loadFromXib() -> OmniBar {
        return OmniBar.load(nibName: "OmniBar")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureTextField()
        configureEditingMenu()
        configureSiteRating()
        refreshState(state)
    }
    
    private func configureTextField() {
        textField.attributedPlaceholder = NSAttributedString(string: UserText.searchDuckDuckGo, attributes: [NSAttributedStringKey.foregroundColor: UIColor.coolGray])
        textField.delegate = self
    }
    
    private func configureEditingMenu() {
        let title = UserText.actionPasteAndGo
        UIMenuController.shared.menuItems = [UIMenuItem(title: title, action: #selector(pasteAndGo))]
    }
    
    private func configureSiteRating() {
        siteRatingView.refresh()
    }
    
    @objc func pasteAndGo(sender: UIMenuItem) {
        guard let pastedText = UIPasteboard.general.string else { return }
        textField.text = pastedText
        onQuerySubmitted()
    }
    
    func startBrowsing() {
        refreshState(state.onBrowsingStartedState)
    }
    
    func stopBrowsing() {
        refreshState(state.onBrowsingStoppedState)
    }
    
    fileprivate func refreshState(_ newState: OmniBarState) {
        if type(of: state) != type(of: newState)  {
            Logger.log(text: "OmniBar entering \(Type.name(newState))")
            state = newState
        }
        setVisibility(dismissButton, hidden: !state.showDismiss)
        setVisibility(siteRatingView, hidden: !state.showSiteRating)
        setVisibility(clearButton, hidden: !state.showClear)
        setVisibility(menuButton, hidden: !state.showMenu)
        setVisibility(bookmarksButton, hidden: !state.showBookmarks)
    }
    
    /*
     Superfluous check to overcome apple bug in stack view where setting value more than
     once causes issues, related to http://www.openradar.me/22819594
     Kill this method when radar is fixed - burn it with fire ;-)
     */
    private func setVisibility(_ view: UIView, hidden: Bool) {
        if view.isHidden != hidden {
            view.isHidden = hidden
        }
    }
    
    @discardableResult override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    @discardableResult override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
    
    func updateSiteRating(_ siteRating: SiteRating?) {
        siteRatingView.update(siteRating: siteRating)
    }
    
    func clear() {
        textField.text = nil
    }
    
    func refreshText(forUrl url: URL?) {
        
        if textField.isEditing {
            return
        }
        
        guard let url = url else {
            textField.text = nil
            return
        }
        
        textField.text = url.absoluteString
    }
    
    
    @IBAction func onDismissButtonPressed() {
        resignFirstResponder()
        omniDelegate?.onDismissed()
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
    
    @IBAction func onClearButtonPressed(_ sender: Any) {
        clear()
        refreshState(state.onTextClearedState)
    }
    
    @IBAction func onSiteRatingPressed(_ sender: Any) {
        omniDelegate?.onSiteRatingPressed()
    }
    
    @IBAction func onMenuButtonPressed(_ sender: UIButton) {
        omniDelegate?.onMenuPressed()
    }
    
    @IBAction func onBookmarksButtonPressed(_ sender: Any) {
        omniDelegate?.onBookmarksPressed()
    }
}

extension OmniBar: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        refreshState(state.onEditingStartedState)
        DispatchQueue.main.async {
            self.textField.selectAll(nil)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let oldQuery = textField.text else { return true }
        guard let queryRange = oldQuery.range(from: range) else { return true }
        let newQuery = oldQuery.replacingCharacters(in: queryRange, with: string)
        omniDelegate?.onOmniQueryUpdated(newQuery)
        if newQuery.isEmpty {
            refreshState(state.onTextClearedState)
        } else {
            refreshState(state.onTextEnteredState)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text, text.isEmpty {
            omniDelegate?.onDismissed()
        }
        refreshState(state.onEditingStoppedState)
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

