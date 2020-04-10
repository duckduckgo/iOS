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
import os.log

extension OmniBar: NibLoading {}

class OmniBar: UIView {

    @IBOutlet weak var searchLoupe: UIView!
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var searchStackContainer: UIStackView!
    @IBOutlet weak var siteRatingView: SiteRatingView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var trackersStackView: TrackersStackView!
    @IBOutlet weak var editingBackground: RoundedRectangleView!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var bookmarksButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!

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
        
        self.trackersStackView.alpha = 0
        trackersStackView.isHidden = true
        refreshState(state)
    }
    
    private func configureTextField() {
        let theme = ThemeManager.shared.currentTheme
        textField.attributedPlaceholder = NSAttributedString(string: UserText.searchDuckDuckGo,
                                                             attributes: [.foregroundColor: theme.searchBarTextPlaceholderColor])
        textField.delegate = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textDidChange),
                                               name: UITextField.textDidChangeNotification,
                                               object: textField)
        
        if #available(iOS 11.0, *) {
            textField.textDragInteraction?.isEnabled = false
        }
    }
    
    private func configureSeparator() {
        separatorHeightConstraint.constant = 1.0 / UIScreen.main.scale
    }

    private func configureEditingMenu() {
        let title = UserText.actionPasteAndGo
        UIMenuController.shared.menuItems = [UIMenuItem(title: title, action: #selector(pasteAndGo))]
    }
    
    var textFieldBottomSpacing: CGFloat {
        return (bounds.size.height - (searchContainer.frame.origin.y + searchContainer.frame.size.height)) / 2.0
    }
    
    @objc func textDidChange() {
        let newQuery = textField.text ?? ""
        omniDelegate?.onOmniQueryUpdated(newQuery)
        if newQuery.isEmpty {
            refreshState(state.onTextClearedState)
        } else {
            refreshState(state.onTextEnteredState)
        }
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

    @IBAction func textFieldTapped() {
        textField.becomeFirstResponder()
    }
    
    public func showTrackers() {
        UIView.animate(withDuration: 0.2, animations: {
            self.trackersStackView.isHidden = false
            self.trackersStackView.alpha = 1
            self.textField.alpha = 0
            self.siteRatingView.alpha = 0
        }, completion: { _ in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.trackersStackView.animateTrackers()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.4) {
                self.hideTrackers()
            }
        })
    }
    
    public func hideTrackers() {
        UIView.animate(withDuration: 0.2, animations: {
            self.trackersStackView.alpha = 0
            self.textField.alpha = 1
            self.siteRatingView.alpha = 1
        }, completion: { _ in
            self.trackersStackView.isHidden = true
            self.trackersStackView.resetTrackers()
        })
    }

    fileprivate func refreshState(_ newState: OmniBarState) {
        if state.name != newState.name {
            os_log("OmniBar entering %s from %s", log: generalLog, type: .debug, newState.name, state.name)
            if newState.clearTextOnStart {
                clear()
            }
            state = newState
        }

        setVisibility(searchLoupe, hidden: !state.showSearchLoupe)
        setVisibility(siteRatingView, hidden: !state.showSiteRating)
        setVisibility(clearButton, hidden: !state.showClear)
        setVisibility(menuButton, hidden: !state.showMenu)
        setVisibility(settingsButton, hidden: !state.showSettings)
        setVisibility(cancelButton, hidden: !state.showCancel)
        setVisibility(refreshButton, hidden: !state.showRefresh)

        updateSearchBarBorder()
    }

    private func updateSearchBarBorder() {
        let theme = ThemeManager.shared.currentTheme
        if state.showBackground {
            editingBackground?.backgroundColor = theme.searchBarBackgroundColor
            editingBackground?.borderColor = theme.searchBarBackgroundColor
        } else {
            editingBackground.borderWidth = 1.5
            editingBackground.borderColor = theme.searchBarBorderColor
            editingBackground.backgroundColor = UIColor.clear
        }
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

    func updateSiteRating(_ siteRating: SiteRating?, with storageCache: StorageCache?) {
        siteRatingView.update(siteRating: siteRating, with: storageCache)
    }

    private func clear() {
        textField.text = nil
        omniDelegate?.onOmniQueryUpdated("")
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
    
    @IBAction func onRefreshPressed(_ sender: Any) {
        omniDelegate?.onRefreshPressed()
    }
}

extension OmniBar: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        omniDelegate?.onTextFieldWillBeginEditing(self)
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.async {
            self.omniDelegate?.onTextFieldDidBeginEditing(self)
            self.refreshState(self.state.onEditingStartedState)
            self.textField.selectAll(nil)
        }
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
        tintColor = theme.barTintColor
        
        configureTextField()

        editingBackground?.backgroundColor = theme.searchBarBackgroundColor
        editingBackground?.borderColor = theme.searchBarBackgroundColor

        siteRatingView.circleIndicator.tintColor = theme.barTintColor
        searchStackContainer?.tintColor = theme.barTintColor
        
        trackersStackView.tintColor = theme.searchBarTextColor
        trackersStackView.crossOutBackgroundColor = theme.searchBarBackgroundColor
        
        if let url = textField.text?.punycodedUrl {
            textField.attributedText = OmniBar.demphasisePath(forUrl: url)
        }
        textField.textColor = theme.searchBarTextColor
        textField.tintColor = theme.searchBarTextColor
        textField.keyboardAppearance = theme.keyboardAppearance
        clearButton.tintColor = theme.searchBarClearTextIconColor

        searchLoupe.tintColor = theme.barTintColor
        cancelButton.setTitleColor(theme.barTintColor, for: .normal)
        
        updateSearchBarBorder()
    }
}

extension OmniBar: UIGestureRecognizerDelegate {
 
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return !textField.isFirstResponder
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
