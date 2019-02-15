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

    @IBOutlet weak var searchLoupe: UIView!
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var searchStackContainer: UIStackView!
    @IBOutlet weak var siteRatingView: SiteRatingView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var editingBackground: RoundedRectangleView!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var bookmarksButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var cancelButton: UIButton!

    @IBOutlet weak var separatorHeightConstraint: NSLayoutConstraint!

    weak var omniDelegate: OmniBarDelegate?
    fileprivate var state: OmniBarState = HomeNonEditingState()
    private lazy var appUrls: AppUrls = AppUrls()

    static func loadFromXib() -> OmniBar {
        return OmniBar.load(nibName: "OmniBar")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        configureTextField()
        configureSeparator()
        configureEditingMenu()
        refreshState(state)
    }
    
    public func useCancellableState() {
        refreshState(state.supportingCancelButtonState)
    }
    
    private func configureTextField() {
        textField.attributedPlaceholder = NSAttributedString(string: UserText.searchDuckDuckGo,
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.greyish])
        textField.delegate = self
    }
    
    private func configureSeparator() {
        separatorHeightConstraint.constant = 1.0 / UIScreen.main.scale
    }

    private func configureEditingMenu() {
        let title = UserText.actionPasteAndGo
        UIMenuController.shared.menuItems = [UIMenuItem(title: title, action: #selector(pasteAndGo))]
    }

    @objc func pasteAndGo(sender: UIMenuItem) {
        guard let pastedText = UIPasteboard.general.string else { return }
        textField.text = pastedText
        onQuerySubmitted()
    }
    
    func showSeparator() {
        separatorView.isHidden = false
    }
    
    func hideSeparator() {
        separatorView.isHidden = true
    }

    func startBrowsing() {
        refreshState(state.onBrowsingStartedState)
    }

    func stopBrowsing() {
        refreshState(state.onBrowsingStoppedState)
    }

    fileprivate func refreshState(_ newState: OmniBarState) {
        if state.name != newState.name {
            Logger.log(text: "OmniBar entering \(newState.name) from \(state.name)")
            if newState.clearTextOnStart {
                clear()
            }
            state = newState
        }

        setVisibility(searchLoupe, hidden: !state.showSearchLoupe)
        setVisibility(siteRatingView, hidden: !state.showSiteRating)
        setVisibility(editingBackground, hidden: !state.showBackground)
        setVisibility(clearButton, hidden: !state.showClear)
        setVisibility(menuButton, hidden: !state.showMenu)
        setVisibility(bookmarksButton, hidden: !state.showBookmarks)
        setVisibility(settingsButton, hidden: !state.showSettings)
        setVisibility(cancelButton, hidden: !state.showCancel)
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

    private func clear() {
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

        if let query = appUrls.searchQuery(fromUrl: url) {
            textField.text = query
        } else {
            textField.attributedText = OmniBar.demphasisePath(forUrl: url)
        }
    }

    public class func demphasisePath(forUrl url: URL) -> NSAttributedString? {
        
        let s = url.absoluteString
        let attributedString = NSMutableAttributedString(string: s)
        guard let c = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return attributedString
        }
        
        let theme = ThemeManager.shared.currentTheme
        
        if let pathStart = c.rangeOfPath?.lowerBound {
            let urlEnd = s.endIndex
            
            let pathRange = NSRange(pathStart ..< urlEnd, in: s)
            attributedString.addAttribute(.foregroundColor, value: theme.searchBarTextDeemphasisColor, range: pathRange)
            
            let domainRange = NSRange(s.startIndex ..< pathStart, in: s)
            attributedString.addAttribute(.foregroundColor, value: theme.searchBarTextColor, range: domainRange)
            
        } else {
            let range = NSRange(s.startIndex ..< s.endIndex, in: s)
            attributedString.addAttribute(.foregroundColor, value: theme.searchBarTextColor, range: range)
        }
        
        return attributedString
    }
    
    @IBAction func onTextEntered(_ sender: Any) {
        onQuerySubmitted()
    }

    func onQuerySubmitted() {
        guard let query = textField.text?.trimWhitespace(), !query.isEmpty else {
            return
        }
        resignFirstResponder()
        
        if let url = query.punycodedUrl {
            omniDelegate?.onOmniQuerySubmitted(url.absoluteString)
        } else {
            omniDelegate?.onOmniQuerySubmitted(query)
        }
        
    }

    @IBAction func onClearButtonPressed(_ sender: Any) {
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

    @IBAction func onSettingsButtonPressed(_ sender: Any) {
        omniDelegate?.onSettingsPressed()
    }
    
    @IBAction func onCancelPressed(_ sender: Any) {
        omniDelegate?.onCancelPressed()
    }
}

extension OmniBar: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        omniDelegate?.onTextFieldDidBeginEditing(self)
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

extension OmniBar: Themable {
    
    public func decorate(with theme: Theme) {
        backgroundColor = theme.barBackgroundColor
        editingBackground?.backgroundColor = theme.searchBarBackgroundColor
        
        tintColor = theme.barTintColor
        siteRatingView.circleIndicator.tintColor = theme.barTintColor
        searchStackContainer?.tintColor = theme.barTintColor
        
        editingBackground?.borderColor = theme.searchBarBackgroundColor
        textField.textColor = theme.searchBarTextColor
        
        if let url = textField.text?.punycodedUrl {
            textField.attributedText = OmniBar.demphasisePath(forUrl: url)
        }
        
        textField.tintColor = theme.searchBarTextColor
        
        textField.keyboardAppearance = theme.keyboardAppearance
        
        searchLoupe.tintColor = theme.barTintColor
        
        cancelButton.setTitleColor(theme.barTintColor, for: .normal)
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
