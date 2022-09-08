//
//  ActionMessageView.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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

extension ActionMessageView: NibLoading {}

class ActionMessageView: UIView {

    enum PresentationLocation {
        case withBottomBar
        case withoutBottomBar
    }

    private static var presentedMessages = [ActionMessageView]()

    private enum Constants {
        static var maxWidth: CGFloat = 346
        static var minimumHorizontalPadding: CGFloat = 20
        static var cornerRadius: CGFloat = 10

        static var animationDuration: TimeInterval = 0.2
        static var duration: TimeInterval = 3.0

        static let paddingFromToolbar: CGFloat = 30
    }

    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var actionButton: UIButton!

    @IBOutlet var labelToButton: NSLayoutConstraint!
    @IBOutlet var labelToTrailing: NSLayoutConstraint!

    private var action: () -> Void = {}
    private var onDidDismiss: () -> Void = {}

    private var observers = [NSKeyValueObservation]()
    private var bottomLayoutConstraint: NSLayoutConstraint!
    private var dismissWorkItem: DispatchWorkItem?
    
    static func loadFromXib() -> ActionMessageView {
        return ActionMessageView.load(nibName: "ActionMessageView")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = Constants.cornerRadius
    }
    
    static func present(message: NSAttributedString,
                        numberOfLines: Int = 0,
                        actionTitle: String? = nil,
                        presentationLocation: PresentationLocation = .withBottomBar,
                        onAction: @escaping () -> Void = {},
                        onDidDismiss: @escaping () -> Void = {}) {
        let messageView = loadFromXib()
        messageView.message.attributedText = message
        messageView.message.numberOfLines = numberOfLines
        ActionMessageView.present(messageView: messageView,
                                  message: message.string,
                                  actionTitle: actionTitle,
                                  presentationLocation: presentationLocation,
                                  onAction: onAction,
                                  onDidDismiss: onDidDismiss)
    }
    
    static func present(message: String,
                        actionTitle: String? = nil,
                        presentationLocation: PresentationLocation = .withBottomBar,
                        onAction: @escaping () -> Void = {},
                        onDidDismiss: @escaping () -> Void = {}) {
        let messageView = loadFromXib()
        messageView.message.setAttributedTextString(message)
        ActionMessageView.present(messageView: messageView,
                                  message: message,
                                  actionTitle: actionTitle,
                                  presentationLocation: presentationLocation,
                                  onAction: onAction,
                                  onDidDismiss: onDidDismiss)
    }
    
    private static func present(messageView: ActionMessageView,
                                message: String,
                                actionTitle: String? = nil,
                                presentationLocation: PresentationLocation = .withBottomBar,
                                onAction: @escaping () -> Void = {},
                                onDidDismiss: @escaping () -> Void = {}) {
        guard let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first else { return }
        
        dismissAllMessages()
                
        if let actionTitle = actionTitle, let title = messageView.actionButton.attributedTitle(for: .normal) {
            messageView.actionButton.setAttributedTitle(title.withText(actionTitle.uppercased()), for: .normal)
            messageView.action = onAction
        } else {
            messageView.labelToButton.isActive = false
            messageView.labelToTrailing.isActive = true
            messageView.actionButton.isHidden = true
        }
        messageView.onDidDismiss = onDidDismiss

        window.addSubview(messageView)

        messageView.bottomLayoutConstraint = window.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: messageView.bottomAnchor)
        messageView.observers.append(MainViewController.sharedInstance.toolbarBottom
            .observe(\.constant, options: [.initial]) { [weak messageView] _, _ in
                messageView?.updateBottomLayoutConstraint(animated: false)
            })
        messageView.observers.append(MainViewController.sharedInstance.view
            .observe(\.safeAreaInsets) { [weak messageView] _, _ in
                messageView?.updateBottomLayoutConstraint(animated: true)
            })
        messageView.bottomLayoutConstraint.isActive = true

        let messageViewWidth = window.frame.width <= Constants.maxWidth ? window.frame.width - Constants.minimumHorizontalPadding : Constants.maxWidth
        messageView.widthAnchor.constraint(equalToConstant: messageViewWidth).isActive = true
        messageView.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
        
        window.layoutIfNeeded()
        
        messageView.alpha = 0
        UIView.animate(withDuration: Constants.animationDuration) {
            messageView.alpha = 1
        } completion: { _ in
            UIAccessibility.post(notification: .announcement, argument: message)
        }
        
        let workItem = DispatchWorkItem { [weak messageView] in
            messageView?.dismissAndFadeOut()
        }
        messageView.dismissWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.duration, execute: workItem)
        presentedMessages.append(messageView)
    }

    static func dismissAllMessages() {
        presentedMessages.forEach { $0.dismissAndFadeOut() }
    }

    private func updateBottomLayoutConstraint(animated: Bool) {
        guard let superview = superview else { return }
        if animated {
            self.superview?.bringSubviewToFront(self)
            // animation will break if view order changes (in case presentedViewController is shown)
            DispatchQueue.main.async {
                UIView.animate(withDuration: Constants.animationDuration, delay: 0, options: .beginFromCurrentState) {
                    self.updateBottomLayoutConstraint(animated: false)
                }
            }
            return
        }

        let mainViewController = MainViewController.sharedInstance
        let toolbarHeight: CGFloat

        // if displaying modal with toolbar
        if let presentedViewController = mainViewController.presentedViewController as? UINavigationController,
           let toolbar = presentedViewController.toolbar,
           !presentedViewController.isBeingDismissed {

            // display over toolbar if modal view controller has a toolbar
            toolbarHeight = superview.bounds.height - superview.convert(toolbar.frame, from: toolbar.superview).minY - superview.safeAreaInsets.bottom

        // if not displaying modal
        } else if mainViewController.presentedViewController?.isBeingDismissed ?? true,
                  case .phone = UIDevice.current.userInterfaceIdiom {
            // display over Browser Toolbar respecting its position
            toolbarHeight = mainViewController.toolbarHeight - mainViewController.toolbarBottom.constant

        // iPad or modal view controller without toolbar
        } else {
            toolbarHeight = 0
        }

        bottomLayoutConstraint.constant = toolbarHeight + Constants.paddingFromToolbar
        superview.layoutIfNeeded()
    }

    private func dismissAndFadeOut() {
        dismissWorkItem?.cancel()
        dismissWorkItem = nil
        
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.alpha = 0
        }, completion: {  _ in
            self.observers.removeAll()
            self.removeFromSuperview()
            if let position = Self.presentedMessages.firstIndex(of: self) {
                Self.presentedMessages.remove(at: position)
            }
            self.onDidDismiss()
        })
    }
    
    @IBAction func onButtonTap() {
        action()
        dismissAndFadeOut()
    }
}
