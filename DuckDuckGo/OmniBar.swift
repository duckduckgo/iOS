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
import BrowserServicesKit

extension OmniBar: NibLoading {}

// swiftlint:disable file_length
// swiftlint:disable type_body_length
class OmniBar: UIView {

    public static let didLayoutNotification = Notification.Name("com.duckduckgo.app.OmniBarDidLayout")
    
    @IBOutlet weak var searchLoupe: UIView!
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var searchStackContainer: UIStackView!
    @IBOutlet weak var searchFieldContainer: SearchFieldContainerView!
    @IBOutlet weak var siteRatingContainer: SiteRatingContainerView!
    @IBOutlet weak var textField: TextFieldWithInsets!
    @IBOutlet weak var editingBackground: RoundedRectangleView!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var voiceSearchButton: UIButton!
    
    @IBOutlet weak var bookmarksButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    private(set) var menuButtonContent = MenuButton()

    // Don't use weak because adding/removing them causes them to go away
    @IBOutlet var separatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet var leftButtonsSpacingConstraint: NSLayoutConstraint!
    @IBOutlet var rightButtonsSpacingConstraint: NSLayoutConstraint!
    @IBOutlet var searchContainerCenterConstraint: NSLayoutConstraint!
    @IBOutlet var searchContainerMaxWidthConstraint: NSLayoutConstraint!
    @IBOutlet var omniBarLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var omniBarTrailingConstraint: NSLayoutConstraint!

    weak var omniDelegate: OmniBarDelegate?
    fileprivate var state: OmniBarState = SmallOmniBarState.HomeNonEditingState()
    private lazy var appUrls: AppUrls = AppUrls()
    private var safeAreaInsetsObservation: NSKeyValueObservation?
    
    private(set) var trackersAnimator = TrackersAnimator()
    
    static func loadFromXib() -> OmniBar {
        return OmniBar.load(nibName: "OmniBar")
    }
    
    var siteRatingView: SiteRatingView {
        return siteRatingContainer.siteRatingView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        configureMenuButton()
        configureTextField()
        registerNotifications()
        
        configureSeparator()
        configureEditingMenu()
        refreshState(state)
        enableInteractionsWithPointer()
        observeSafeAreaInsets()
    }
    
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textDidChange),
                                               name: UITextField.textDidChangeNotification,
                                               object: textField)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadSpeechRecognizerAvailability),
                                               name: .speechRecognizerDidChangeAvailability,
                                               object: nil)
    }
    
    private func observeSafeAreaInsets() {
        safeAreaInsetsObservation = self.observe(\.safeAreaInsets, options: .new) { [weak self] (_, _) in
            self?.updateOmniBarPadding()
        }
    }
    
    private func enableInteractionsWithPointer() {
        guard #available(iOS 13.4, *) else { return }
        backButton.isPointerInteractionEnabled = true
        forwardButton.isPointerInteractionEnabled = true
        settingsButton.isPointerInteractionEnabled = true
        cancelButton.isPointerInteractionEnabled = true
        bookmarksButton.isPointerInteractionEnabled = true
        shareButton.isPointerInteractionEnabled = true
        menuButton.isPointerInteractionEnabled = true

        refreshButton.isPointerInteractionEnabled = true
        refreshButton.pointerStyleProvider = { button, effect, _ -> UIPointerStyle? in
            return .init(effect: .lift(.init(view: button)))
        }
    }
    
    private func configureMenuButton() {
        menuButton.addSubview(menuButtonContent)
        menuButton.isAccessibilityElement = true
        menuButton.accessibilityTraits = .button
    }
    
    private func configureTextField() {
        let theme = ThemeManager.shared.currentTheme
        textField.attributedPlaceholder = NSAttributedString(string: UserText.searchDuckDuckGo,
                                                             attributes: [.foregroundColor: theme.searchBarTextPlaceholderColor])
        textField.delegate = self
        
        textField.textDragInteraction?.isEnabled = false
        
        textField.onCopyAction = { field in
            guard let range = field.selectedTextRange else { return }
            UIPasteboard.general.string = field.text(in: range)
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
    
    @objc private func reloadSpeechRecognizerAvailability() {
        assert(Thread.isMainThread)
        state = state.onReloadState
        refreshState(state)
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
    
    func removeTextSelection() {
        textField.selectedTextRange = nil
    }
    
    public func startLoadingAnimation(for url: URL?) {
        trackersAnimator.startLoadingAnimation(in: self, for: url)
    }
    
    public func startTrackersAnimation(_ trackers: [DetectedTracker], collapsing: Bool) {
        guard trackersAnimator.configure(self, toDisplay: trackers, shouldCollapse: collapsing), state.allowsTrackersAnimation else {
            trackersAnimator.cancelAnimations(in: self)
            return
        }
        
        trackersAnimator.startAnimating(in: self)
    }
    
    public func cancelAllAnimations() {
        trackersAnimator.cancelAnimations(in: self)
    }
    
    public func completeAnimations() {
        trackersAnimator.completeAnimations(in: self)
    }

    fileprivate func refreshState(_ newState: OmniBarState) {
        if state.name != newState.name {
            os_log("OmniBar entering %s from %s", log: generalLog, type: .debug, newState.name, state.name)
            if newState.clearTextOnStart {
                clear()
            }
            state = newState
            trackersAnimator.cancelAnimations(in: self)
        }
        
        if state.showSiteRating {
            searchFieldContainer.revealSiteRatingView()
        } else {
            searchFieldContainer.hideSiteRatingView(state)
        }

        setVisibility(searchLoupe, hidden: !state.showSearchLoupe)
        setVisibility(clearButton, hidden: !state.showClear)
        setVisibility(menuButton, hidden: !state.showMenu)
        setVisibility(settingsButton, hidden: !state.showSettings)
        setVisibility(cancelButton, hidden: !state.showCancel)
        setVisibility(refreshButton, hidden: !state.showRefresh)
        setVisibility(voiceSearchButton, hidden: !state.showVoiceSearch)

        setVisibility(backButton, hidden: !state.showBackButton)
        setVisibility(forwardButton, hidden: !state.showForwardButton)
        setVisibility(bookmarksButton, hidden: !state.showBookmarksButton)
        setVisibility(shareButton, hidden: !state.showShareButton)
        
        searchContainerCenterConstraint.isActive = state.hasLargeWidth
        searchContainerMaxWidthConstraint.isActive = state.hasLargeWidth
        leftButtonsSpacingConstraint.constant = state.hasLargeWidth ? 24 : 0
        rightButtonsSpacingConstraint.constant = state.hasLargeWidth ? 24 : 14

        if state.showVoiceSearch && state.showClear {
            searchStackContainer.setCustomSpacing(8, after: voiceSearchButton)
        }
        
        updateOmniBarPadding()
        updateSearchBarBorder()
    }

    private func updateOmniBarPadding() {
        omniBarLeadingConstraint.constant = (state.hasLargeWidth ? 24 : 8) + safeAreaInsets.left
        omniBarTrailingConstraint.constant = (state.hasLargeWidth ? 24 : 14) + safeAreaInsets.right
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

    func updateSiteRating(_ siteRating: SiteRating?, with config: PrivacyConfiguration?) {
        siteRatingView.update(siteRating: siteRating, with: config)
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
        if let suggestion = omniDelegate?.selectedSuggestion() {
            omniDelegate?.onOmniSuggestionSelected(suggestion)
        } else {
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
    }

    @IBAction func onVoiceSearchButtonPressed(_ sender: UIButton) {
        omniDelegate?.onVoiceSearchPressed()
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

    @IBAction func onTrackersViewPressed(_ sender: Any) {
        trackersAnimator.cancelAnimations(in: self)
        textField.becomeFirstResponder()
    }

    @IBAction func onSettingsButtonPressed(_ sender: Any) {
        omniDelegate?.onSettingsPressed()
    }
    
    @IBAction func onCancelPressed(_ sender: Any) {
        omniDelegate?.onCancelPressed()
    }
    
    @IBAction func onRefreshPressed(_ sender: Any) {
        Pixel.fire(pixel: .refreshPressed)
        trackersAnimator.cancelAnimations(in: self)
        omniDelegate?.onRefreshPressed()
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        omniDelegate?.onBackPressed()
    }
    
    @IBAction func onForwardPressed(_ sender: Any) {
        omniDelegate?.onForwardPressed()
    }
    
    @IBAction func onBookmarksPressed(_ sender: Any) {
        Pixel.fire(pixel: .bookmarksButtonPressed,
                   withAdditionalParameters: [PixelParameters.originatedFromMenu: "0"])
        omniDelegate?.onBookmarksPressed()
    }
    
    @IBAction func onSharePressed(_ sender: Any) {
        omniDelegate?.onSharePressed()
    }
    
    func enterPhoneState() {
        refreshState(state.onEnterPhoneState)
    }
    
    func enterPadState() {
        refreshState(state.onEnterPadState)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        NotificationCenter.default.post(name: OmniBar.didLayoutNotification, object: self)
    }
    
}
// swiftlint:enable type_body_length

extension OmniBar: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.refreshState(self.state.onEditingStartedState)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        omniDelegate?.onTextFieldWillBeginEditing(self)
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.async {
            let highlightText = self.omniDelegate?.onTextFieldDidBeginEditing(self) ?? true
            self.refreshState(self.state.onEditingStartedState)
            
            if highlightText {
                // Allow the cursor to move to the end before selecting all the text
                // to avoid text not being selected properly
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self.textField.selectAll(nil)
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        omniDelegate?.onEnterPressed()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        omniDelegate?.onDismissed()
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
        siteRatingContainer.tintColor = theme.barTintColor
        siteRatingContainer.crossOutBackgroundColor = theme.searchBarBackgroundColor
        
        searchStackContainer?.tintColor = theme.barTintColor
        
        if let url = textField.text?.punycodedUrl {
            textField.attributedText = OmniBar.demphasisePath(forUrl: url)
        }
        textField.textColor = theme.searchBarTextColor
        textField.tintColor = theme.searchBarTextColor
        textField.keyboardAppearance = theme.keyboardAppearance
        clearButton.tintColor = theme.searchBarClearTextIconColor
        voiceSearchButton.tintColor = theme.searchBarVoiceSearchIconColor
        
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
// swiftlint:enable file_length
