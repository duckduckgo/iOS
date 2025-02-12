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
import DuckPlayer
import os.log
import BrowserServicesKit

extension OmniBar: NibLoading {}

public enum OmniBarIcon: String {
    case duckPlayer = "DuckPlayerURLIcon"
    case specialError = "Globe-24"
}

class OmniBar: UIView {

    enum AccessoryType {
         case share
         case chat
     }

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
    @IBOutlet weak var abortButton: UIButton!

    @IBOutlet weak var bookmarksButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var accessoryButton: UIButton!

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

    @IBOutlet weak var dismissButton: UIButton!

    /// A container view designed to maintain visual consistency among various items within this space.
    /// Additionally, it facilitates smooth animations for the elements it contains.
    @IBOutlet weak var leftIconContainerView: UIView!

    weak var omniDelegate: OmniBarDelegate?
    fileprivate var state: OmniBarState!
    private(set) var accessoryType: AccessoryType = .share {
        didSet {
            switch accessoryType {
            case .chat:
                accessoryButton.setImage(UIImage(named: "AIChat-24"), for: .normal)
            case .share:
                accessoryButton.setImage(UIImage(named: "Share-24"), for: .normal)
            }
        }
    }

    private var privacyIconAndTrackersAnimator = PrivacyIconAndTrackersAnimator()
    private var notificationAnimator = OmniBarNotificationAnimator()
    private let privacyIconContextualOnboardingAnimator = PrivacyIconContextualOnboardingAnimator()
    private var dismissButtonAnimator: UIViewPropertyAnimator?

    // Set up a view to add a custom icon to the Omnibar
    private var customIconView: UIImageView = UIImageView(frame: CGRect(x: 4, y: 8, width: 26, height: 26))

    static func loadFromXib(dependencies: OmnibarDependencyProvider) -> OmniBar {
        let omniBar = OmniBar.load(nibName: "OmniBar")
        omniBar.state = SmallOmniBarState.HomeNonEditingState(dependencies: dependencies, isLoading: false)
        omniBar.refreshState(omniBar.state)
        return omniBar
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // Tests require this
    init(dependencies: OmnibarDependencyProvider, frame: CGRect) {
        self.state = SmallOmniBarState.HomeNonEditingState(dependencies: dependencies, isLoading: false)
        super.init(frame: frame)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        configureMenuButton()
        configureTextField()
        configureSettingsLongPressButton()
        configureShareLongPressButton()
        registerNotifications()

        configureSeparator()
        configureEditingMenu()
        enableInteractionsWithPointer()
        
        privacyInfoContainer.isHidden = true

        decorate()
    }

    private func configureSettingsLongPressButton() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleSettingsLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.7
        settingsButton.addGestureRecognizer(longPressGesture)
    }

    private func configureShareLongPressButton() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleShareLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.7
        accessoryButton.addGestureRecognizer(longPressGesture)
    }

    @objc private func handleSettingsLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            omniDelegate?.onSettingsLongPressed()
        }
    }

    @objc private func handleShareLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            omniDelegate?.onAccessoryLongPressed(accessoryType: accessoryType)
        }
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
        
    private func enableInteractionsWithPointer() {
        backButton.isPointerInteractionEnabled = true
        forwardButton.isPointerInteractionEnabled = true
        settingsButton.isPointerInteractionEnabled = true
        cancelButton.isPointerInteractionEnabled = true
        bookmarksButton.isPointerInteractionEnabled = true
        accessoryButton.isPointerInteractionEnabled = true
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
    
    var textFieldTapped = true

    private func configureSeparator() {
        separatorHeightConstraint.constant = 1.0 / UIScreen.main.scale
    }

    private func configureEditingMenu() {
        let title = UserText.actionPasteAndGo
        UIMenuController.shared.menuItems = [UIMenuItem(title: title, action: #selector(self.pasteURLAndGo))]
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

    @objc func pasteURLAndGo(sender: UIMenuItem) {
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

    func cancel() {
        refreshState(state.onEditingStoppedState)
    }

    func startBrowsing() {
        refreshState(state.onBrowsingStartedState)
    }

    func stopBrowsing() {
        refreshState(state.onBrowsingStoppedState)
    }

    func startLoading() {
        refreshState(state.withLoading())
    }

    func stopLoading() {
        refreshState(state.withoutLoading())
    }

    func removeTextSelection() {
        textField.selectedTextRange = nil
    }

    func updateAccessoryType(_ type: AccessoryType) {
        DispatchQueue.main.async { self.accessoryType = type }
    }

    public func hidePrivacyIcon() {
        privacyInfoContainer.privacyIcon.isHidden = true
    }

    public func resetPrivacyIcon(for url: URL?) {
        cancelAllAnimations()
        privacyInfoContainer.privacyIcon.isHidden = false
        
        let icon = PrivacyIconLogic.privacyIcon(for: url)
        privacyInfoContainer.privacyIcon.updateIcon(icon)
        customIconView.isHidden = true
    }
    
    public func updatePrivacyIcon(for privacyInfo: PrivacyInfo?) {
        guard let privacyInfo = privacyInfo,
              !privacyInfoContainer.isAnimationPlaying,
              !privacyIconAndTrackersAnimator.isAnimatingForDaxDialog
        else { return }
        
        if privacyInfo.url.isDuckPlayer {
            showCustomIcon(icon: .duckPlayer)
            return
        }

        if privacyInfo.isSpecialErrorPageVisible {
            showCustomIcon(icon: .specialError)
            return
        }

        let icon = PrivacyIconLogic.privacyIcon(for: privacyInfo)
        privacyInfoContainer.privacyIcon.updateIcon(icon)
        privacyInfoContainer.privacyIcon.isHidden = false
        customIconView.isHidden = true
    }
    
    // Support static custom icons, for things like internal pages, for example
    func showCustomIcon(icon: OmniBarIcon) {
        privacyInfoContainer.privacyIcon.isHidden = true
        customIconView.image = UIImage(named: icon.rawValue)
        privacyInfoContainer.addSubview(customIconView)
        customIconView.isHidden = false
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
        privacyIconContextualOnboardingAnimator.dismissPrivacyIconAnimation(privacyInfoContainer.privacyIcon)

        dismissButtonAnimator?.stopAnimation(true)
    }

    public func completeAnimationForDaxDialog() {
        privacyIconAndTrackersAnimator.completeAnimationForDaxDialog(in: self)
    }

    func showOrScheduleCookiesManagedNotification(isCosmetic: Bool) {
        let type: OmniBarNotificationType = isCosmetic ? .cookiePopupHidden : .cookiePopupManaged
        
        enqueueAnimationIfNeeded { [weak self] in
            guard let self else { return }
            self.notificationAnimator.showNotification(type, in: self)
        }
    }

    func showOrScheduleOnboardingPrivacyIconAnimation() {
        enqueueAnimationIfNeeded { [weak self] in
            guard let self else { return }
            self.privacyIconContextualOnboardingAnimator.showPrivacyIconAnimation(in: self)
        }
    }

    func dismissOnboardingPrivacyIconAnimation() {
        privacyIconContextualOnboardingAnimator.dismissPrivacyIconAnimation(privacyInfoContainer.privacyIcon)
    }

    private func enqueueAnimationIfNeeded(_ block: @escaping () -> Void) {
        if privacyIconAndTrackersAnimator.state == .completed {
            block()
        } else {
            privacyIconAndTrackersAnimator.onAnimationCompletion(block)
        }
    }

    func selectTextToEnd(_ offset: Int) {
        guard let fromPosition = textField.position(from: textField.beginningOfDocument, offset: offset) else { return }
        textField.selectedTextRange = textField.textRange(from: fromPosition, to: textField.endOfDocument)
    }

    fileprivate func refreshState(_ newState: any OmniBarState) {
        let oldState: OmniBarState = self.state
        if state.requiresUpdate(transitioningInto: newState) {
            Logger.general.debug("OmniBar entering \(newState.description) from \(self.state.description)")

            if state.isDifferentState(than: newState) {
                if newState.clearTextOnStart {
                    clear()
                }
                cancelAllAnimations()
            }
            state = newState
        }

        searchFieldContainer.adjustTextFieldOffset(for: state)

        updateLeftIconContainerState(oldState: oldState, newState: state)

        setVisibility(privacyInfoContainer, hidden: !state.showPrivacyIcon)
        setVisibility(clearButton, hidden: !state.showClear)
        setVisibility(menuButton, hidden: !state.showMenu)
        setVisibility(settingsButton, hidden: !state.showSettings)
        setVisibility(cancelButton, hidden: !state.showCancel)
        setVisibility(refreshButton, hidden: !state.showRefresh)
        setVisibility(voiceSearchButton, hidden: !state.showVoiceSearch)
        setVisibility(abortButton, hidden: !state.showAbort)

        setVisibility(backButton, hidden: !state.showBackButton)
        setVisibility(forwardButton, hidden: !state.showForwardButton)
        setVisibility(bookmarksButton, hidden: !state.showBookmarksButton)
        setVisibility(accessoryButton, hidden: !state.showAccessoryButton)

        searchContainerCenterConstraint.isActive = state.hasLargeWidth
        searchContainerMaxWidthConstraint.isActive = state.hasLargeWidth
        leftButtonsSpacingConstraint.constant = state.hasLargeWidth ? 24 : 0
        rightButtonsSpacingConstraint.constant = state.hasLargeWidth ? 24 : trailingConstraintValueForSmallWidth

        if state.showVoiceSearch && state.showClear {
            searchStackContainer.setCustomSpacing(13, after: voiceSearchButton)
        }

        if oldState.showAccessoryButton != state.showAccessoryButton {
            refreshOmnibarPaddingConstraintsForAccessoryButton()
        }

        UIView.animate(withDuration: 0.0) { [weak self] in
            self?.layoutIfNeeded()
        }
    }

    func updateOmniBarPadding(left: CGFloat, right: CGFloat) {
        omniBarLeadingConstraint.constant = (state.hasLargeWidth ? 24 : 8) + left
        omniBarTrailingConstraint.constant = (state.hasLargeWidth ? 24 : trailingConstraintValueForSmallWidth) + right
    }

    /// When a setting that affects the accessory button is modified, `refreshState` is called.
    /// This requires updating the padding to ensure consistent layout.
    func refreshOmnibarPaddingConstraintsForAccessoryButton() {
        omniBarTrailingConstraint.constant = (state.hasLargeWidth ? 24 : trailingConstraintValueForSmallWidth) + (UIApplication.shared.firstKeyWindow?.safeAreaInsets.right ?? 0)
    }

    private var trailingConstraintValueForSmallWidth: CGFloat {
        if state.showAccessoryButton || state.showSettings {
            return 14
        } else {
            return 4
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
        textFieldTapped = false
        defer {
            textFieldTapped = true
        }
        return textField.becomeFirstResponder()
    }

    @discardableResult override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }

    private func clear() {
        textField.text = nil
        omniDelegate?.onOmniQueryUpdated("")
    }

    func refreshText(forUrl url: URL?, forceFullURL: Bool = false) {
        guard !textField.isEditing else { return }
        guard let url = url else {
            textField.text = nil
            return
        }

        if let query = url.searchQuery {
            textField.text = query
        } else {
            textField.attributedText = AddressDisplayHelper.addressForDisplay(url: url, showsFullURL: textField.isEditing || forceFullURL)
        }
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

    @IBAction func onAbortButtonPressed(_ sender: Any) {
        omniDelegate?.onAbortPressed()
    }

    @IBAction func onClearButtonPressed(_ sender: Any) {
        omniDelegate?.onClearPressed()
        refreshState(state.onTextClearedState)
    }

    @IBAction func onPrivacyIconPressed(_ sender: Any) {
        let isPrivacyIconHighlighted = privacyIconContextualOnboardingAnimator.isPrivacyIconHighlighted(privacyInfoContainer.privacyIcon)
        omniDelegate?.onPrivacyIconPressed(isHighlighted: isPrivacyIconHighlighted)
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
        refreshState(state.onEditingStoppedState)
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

    @IBAction func onAccessoryPressed(_ sender: Any) {
        omniDelegate?.onAccessoryPressed(accessoryType: accessoryType)
    }

    @IBAction func onDismissPressed(_ sender: Any) {
        omniDelegate?.onCancelPressed()
        refreshState(state.onEditingStoppedState)
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

extension OmniBar: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.refreshState(self.state.onEditingStartedState)
        return true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        omniDelegate?.onTextFieldWillBeginEditing(self, tapped: textFieldTapped)
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.async {
            let highlightText = self.omniDelegate?.onTextFieldDidBeginEditing(self) ?? true
            self.refreshState(self.state.onEditingStartedState)
            
            if highlightText {
                self.textField.selectAll(nil)
            }
            self.omniDelegate?.onDidBeginEditing()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        omniDelegate?.onEnterPressed()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        switch omniDelegate?.onEditingEnd() {
        case .dismissed, .none:
            refreshState(state.onEditingStoppedState)
        case .suspended:
            refreshState(state.onEditingSuspendedState)
        }
        self.omniDelegate?.onDidEndEditing()
    }
}

extension OmniBar {
    
    private func decorate() {
        let theme = ThemeManager.shared.currentTheme
        backgroundColor = theme.omniBarBackgroundColor
        tintColor = theme.barTintColor
        
        configureTextField()

        editingBackground?.backgroundColor = theme.searchBarBackgroundColor
        editingBackground?.borderColor = theme.searchBarBackgroundColor
        
        privacyIconAndTrackersAnimator.resetImageProvider()
        
        searchStackContainer?.tintColor = theme.barTintColor
        
        if let url = textField.text.flatMap({ URL(trimmedAddressBarString: $0.trimmingWhitespace()) }) {
            textField.attributedText = AddressDisplayHelper.addressForDisplay(url: url, showsFullURL: textField.isEditing)
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

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            privacyIconAndTrackersAnimator.resetImageProvider()
        }
    }
}

extension OmniBar {

    private func updateLeftIconContainerState(oldState: any OmniBarState, newState: any OmniBarState) {
        if state.dependencies.featureFlagger.isFeatureOn(.aiChatNewTabPage) {
            if oldState.showSearchLoupe && newState.showDismiss {
                animateTransition(from: searchLoupe, to: dismissButton)
            } else if oldState.showDismiss && newState.showSearchLoupe {
                animateTransition(from: dismissButton, to: searchLoupe)
            } else if dismissButtonAnimator == nil || dismissButtonAnimator?.isRunning == false {
                updateLeftContainerVisibility(state: newState)
            }

        } else {
            updateLeftContainerVisibility(state: newState)
        }

        if !state.showDismiss && !newState.showSearchLoupe {
            leftIconContainerView.isHidden = true
        } else {
            leftIconContainerView.isHidden = false
        }
    }

    private func updateLeftContainerVisibility(state: any OmniBarState) {
        setVisibility(searchLoupe, hidden: !state.showSearchLoupe)
        setVisibility(dismissButton, hidden: !state.showDismiss)
        dismissButton.alpha = state.showDismiss ? 1 : 0
        searchLoupe.alpha = state.showSearchLoupe ? 0.5 : 0
    }

    private func animateTransition(from oldView: UIView, to newView: UIView) {
        dismissButtonAnimator?.stopAnimation(true)
        let animationOffset: CGFloat = 20
        let animationDuration: CGFloat = 0.7
        let animationDampingRatio: CGFloat = 0.6

        newView.alpha = 0
        newView.transform = CGAffineTransform(translationX: -animationOffset, y: 0)
        newView.isHidden = false
        oldView.isHidden = false

        let targetAlpha: CGFloat = (newView == searchLoupe) ? 0.5 : 1.0

        dismissButtonAnimator = UIViewPropertyAnimator(duration: animationDuration, dampingRatio: animationDampingRatio) {
            oldView.alpha = 0
            oldView.transform = CGAffineTransform(translationX: -animationOffset, y: 0)
            newView.alpha = targetAlpha
            newView.transform = .identity
        }

        dismissButtonAnimator?.isInterruptible = true

        dismissButtonAnimator?.addCompletion { position in
            if position == .end {
                oldView.isHidden = true
                oldView.transform = .identity
            }
        }

        dismissButtonAnimator?.startAnimation()
    }
}
