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

import Common
import UIKit
import Core
import PrivacyDashboard
import DesignResourcesKit

extension OmniBar: NibLoading {}

// swiftlint:disable file_length
// swiftlint:disable type_body_length
class OmniBar: UIView {

    public static let didLayoutNotification = Notification.Name("com.duckduckgo.app.OmniBarDidLayout")
    
    @IBOutlet weak var searchLoupe: UIView!
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var searchStackContainer: UIStackView!
    @IBOutlet weak var searchFieldContainer: SearchFieldContainerView!
    @IBOutlet weak var privacyInfoContainer: PrivacyInfoContainerView!
    @IBOutlet weak var notificationContainer: OmniBarNotificationContainerView!
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
    @IBOutlet var separatorToBottom: NSLayoutConstraint!

    weak var omniDelegate: OmniBarDelegate?
    fileprivate var state: OmniBarState = SmallOmniBarState.HomeNonEditingState()
    private var safeAreaInsetsObservation: NSKeyValueObservation?
    
    private var privacyIconAndTrackersAnimator = PrivacyIconAndTrackersAnimator()
    private var notificationAnimator = OmniBarNotificationAnimator()

    static func loadFromXib() -> OmniBar {
        return OmniBar.load(nibName: "OmniBar")
    }

    private let appSettings: AppSettings

    required init?(coder: NSCoder) {
        appSettings = AppDependencyProvider.shared.appSettings
        super.init(coder: coder)
    }

    // Tests require this
    override init(frame: CGRect) {
        appSettings = AppDependencyProvider.shared.appSettings
        super.init(frame: frame)
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
        
        privacyInfoContainer.isHidden = true
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
        backButton.isPointerInteractionEnabled = true
        forwardButton.isPointerInteractionEnabled = true
        settingsButton.isPointerInteractionEnabled = true
        cancelButton.isPointerInteractionEnabled = true
        bookmarksButton.isPointerInteractionEnabled = true
        shareButton.isPointerInteractionEnabled = true
        menuButton.isPointerInteractionEnabled = true

        refreshButton.isPointerInteractionEnabled = true
        refreshButton.pointerStyleProvider = { button, _, _ -> UIPointerStyle? in
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

    func moveSeparatorToTop() {
        separatorToBottom.constant = frame.height
    }

    func moveSeparatorToBottom() {
        separatorToBottom.constant = 0
    }

    func startBrowsing() {
        refreshState(state.onBrowsingStartedState)
    }

    func stopBrowsing() {
        refreshState(state.onBrowsingStoppedState)
    }

    func removeTextSelection() {
        textField.selectedTextRange = nil
    }
    
    public func hidePrivacyIcon() {
        privacyInfoContainer.privacyIcon.isHidden = true
    }
    
    public func resetPrivacyIcon(for url: URL?) {
        cancelAllAnimations()
        privacyInfoContainer.privacyIcon.isHidden = false
        
        let icon = PrivacyIconLogic.privacyIcon(for: url)
        privacyInfoContainer.privacyIcon.updateIcon(icon)
    }
    
    public func updatePrivacyIcon(for privacyInfo: PrivacyInfo?) {
        guard let privacyInfo = privacyInfo,
              !privacyInfoContainer.isAnimationPlaying,
              !privacyIconAndTrackersAnimator.isAnimatingForDaxDialog
        else { return }
        
        privacyInfoContainer.privacyIcon.isHidden = false
        
        let icon = PrivacyIconLogic.privacyIcon(for: privacyInfo)
        privacyInfoContainer.privacyIcon.updateIcon(icon)
    }
    
    public func startTrackersAnimation(_ privacyInfo: PrivacyInfo, forDaxDialog: Bool) {
        guard state.allowsTrackersAnimation, !privacyInfoContainer.isAnimationPlaying else { return }
        
        privacyIconAndTrackersAnimator.configure(privacyInfoContainer, with: privacyInfo)

        if TrackerAnimationLogic.shouldAnimateTrackers(for: privacyInfo.trackerInfo) {
            if forDaxDialog {
                privacyIconAndTrackersAnimator.startAnimationForDaxDialog(in: self, with: privacyInfo)
            } else {
                privacyIconAndTrackersAnimator.startAnimating(in: self, with: privacyInfo)
            }
        } else {
            privacyIconAndTrackersAnimator.completeForNoAnimation()
        }
    }
    
    public func cancelAllAnimations() {
        privacyIconAndTrackersAnimator.cancelAnimations(in: self)
        notificationAnimator.cancelAnimations(in: self)
    }
    
    public func completeAnimationForDaxDialog() {
        privacyIconAndTrackersAnimator.completeAnimationForDaxDialog(in: self)
    }

    func showOrScheduleCookiesManagedNotification(isCosmetic: Bool) {
        let type: OmniBarNotificationType = isCosmetic ? .cookiePopupHidden : .cookiePopupManaged
        
        if privacyIconAndTrackersAnimator.state == .completed {
            notificationAnimator.showNotification(type, in: self)
        } else {
            privacyIconAndTrackersAnimator.onAnimationCompletion = { [weak self] in
                guard let self = self else { return }
                self.notificationAnimator.showNotification(type, in: self)
            }
        }
    }

    func selectTextToEnd(_ offset: Int) {
        guard let fromPosition = textField.position(from: textField.beginningOfDocument, offset: offset) else { return }
        textField.selectedTextRange = textField.textRange(from: fromPosition, to: textField.endOfDocument)
    }

    fileprivate func refreshState(_ newState: OmniBarState) {
        if state.name != newState.name {
            os_log("OmniBar entering %s from %s", log: .generalLog, type: .debug, newState.name, state.name)
            if newState.clearTextOnStart {
                clear()
            }
            state = newState
            cancelAllAnimations()
        }
        
        searchFieldContainer.adjustTextFieldOffset(for: state)
        
        setVisibility(privacyInfoContainer, hidden: !state.showPrivacyIcon)
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
            searchStackContainer.setCustomSpacing(13, after: voiceSearchButton)
        }
        
        updateOmniBarPadding()

        UIView.animate(withDuration: 0.0) {
            self.layoutIfNeeded()
        }
        
    }

    private func updateOmniBarPadding() {
        omniBarLeadingConstraint.constant = (state.hasLargeWidth ? 24 : 8) + safeAreaInsets.left
        omniBarTrailingConstraint.constant = (state.hasLargeWidth ? 24 : 14) + safeAreaInsets.right
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

        if let query = url.searchQuery {
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
            guard let query = textField.text?.trimmingWhitespace(), !query.isEmpty else {
                return
            }
            resignFirstResponder()

            if let url = URL(trimmedAddressBarString: query), url.isValid {
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

    @IBAction func onPrivacyIconPressed(_ sender: Any) {
        omniDelegate?.onPrivacyIconPressed()
    }

    @IBAction func onMenuButtonPressed(_ sender: UIButton) {
        omniDelegate?.onMenuPressed()
    }

    @IBAction func onTrackersViewPressed(_ sender: Any) {
        cancelAllAnimations()
        textField.becomeFirstResponder()
    }

    @IBAction func onSettingsButtonPressed(_ sender: Any) {
        Pixel.fire(pixel: .addressBarSettings)
        omniDelegate?.onSettingsPressed()
    }
    
    @IBAction func onCancelPressed(_ sender: Any) {
        omniDelegate?.onCancelPressed()
    }
    
    @IBAction func onRefreshPressed(_ sender: Any) {
        Pixel.fire(pixel: .refreshPressed)
        cancelAllAnimations()
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
        Pixel.fire(pixel: .addressBarShare)
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
                self.textField.selectAll(nil)
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
        backgroundColor = theme.omniBarBackgroundColor
        tintColor = theme.barTintColor
        
        configureTextField()

        editingBackground?.backgroundColor = theme.searchBarBackgroundColor
        editingBackground?.borderColor = theme.searchBarBackgroundColor
        
        privacyInfoContainer.decorate(with: theme)
        privacyIconAndTrackersAnimator.resetImageProvider()
        
        searchStackContainer?.tintColor = theme.barTintColor
        
        if let url = textField.text.flatMap({ URL(trimmedAddressBarString: $0.trimmingWhitespace()) }) {
            textField.attributedText = OmniBar.demphasisePath(forUrl: url)
        }
        textField.textColor = theme.searchBarTextColor
        textField.tintColor = UIColor(designSystemColor: .accent)
        textField.keyboardAppearance = theme.keyboardAppearance
        clearButton.tintColor = UIColor(designSystemColor: .icons)
        voiceSearchButton.tintColor = UIColor(designSystemColor: .icons)
        
        searchLoupe.tintColor = UIColor(designSystemColor: .icons)
        searchLoupe.alpha = 0.5
        cancelButton.setTitleColor(theme.barTintColor, for: .normal)
    }
}
// swiftlint:enable file_length
