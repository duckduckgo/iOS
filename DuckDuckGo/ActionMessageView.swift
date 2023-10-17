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
        case withBottomBar(andAddressBarBottom: Bool)
        case withoutBottomBar
    }
    
    private static var presentedMessages = [ActionMessageView]()
    
    private enum Constants {
        static var maxWidth: CGFloat = 346
        static var minimumHorizontalPadding: CGFloat = 20
        static var cornerRadius: CGFloat = 10
        
        static var animationDuration: TimeInterval = 0.2
        static var duration: TimeInterval = 3.0
        
        static var windowBottomPaddingWithBottomBar: CGFloat {
            if UIDevice.current.userInterfaceIdiom == .phone && !isPortrait {
                return 40
            }
            
            return 70
        }

        static var windowBottomPaddingWithAddressBar: CGFloat {
            return windowBottomPaddingWithBottomBar + 52
        }

        static var windowBottomPaddingWithoutBottomBar: CGFloat {
            return 0
        }
        
    }
    
    private static func bottomPadding(for location: PresentationLocation) -> CGFloat {
        switch location {
        case .withBottomBar(let isAddressBarBottom):
            return isAddressBarBottom ? Constants.windowBottomPaddingWithAddressBar : Constants.windowBottomPaddingWithBottomBar
        case .withoutBottomBar:
            return Constants.windowBottomPaddingWithoutBottomBar
        }
    }
    
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    @IBOutlet var labelToButton: NSLayoutConstraint!
    @IBOutlet var labelToTrailing: NSLayoutConstraint!
    
    private var action: () -> Void = {}
    private var onDidDismiss: () -> Void = {}
    
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
                        presentationLocation: PresentationLocation = .withBottomBar(andAddressBarBottom: false),
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
                        presentationLocation: PresentationLocation = .withBottomBar(andAddressBarBottom: false),
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
                                presentationLocation: PresentationLocation = .withBottomBar(andAddressBarBottom: false),
                                onAction: @escaping () -> Void = {},
                                onDidDismiss: @escaping () -> Void = {}) {
        guard let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first else { return }
        
        dismissAllMessages()
                
        if let actionTitle = actionTitle, let title = messageView.actionButton.attributedTitle(for: .normal) {
            messageView.actionButton.setAttributedTitle(title.withText(actionTitle), for: .normal)
            messageView.action = onAction
        } else {
            messageView.labelToButton.isActive = false
            messageView.labelToTrailing.isActive = true
            messageView.actionButton.isHidden = true
        }
        messageView.onDidDismiss = onDidDismiss
        
        window.addSubview(messageView)
        window.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: messageView.bottomAnchor,
                                                           constant: bottomPadding(for: presentationLocation)).isActive = true
        
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
    
    func dismissAndFadeOut() {
        dismissWorkItem?.cancel()
        dismissWorkItem = nil
        
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.alpha = 0
        }, completion: {  _ in
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
