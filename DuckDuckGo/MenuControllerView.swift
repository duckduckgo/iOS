//
//  MenuControllerView.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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

import SwiftUI
import UIKit

extension View {

    func menuController(_ title: String, secondaryTitle: String? = "", action: @escaping () -> Void, secondaryAction: (() -> Void)? = nil, onOpen: (() -> Void)? = nil, onClose: (() -> Void)? = nil) -> some View {
        MenuControllerView(content: self,
                           title: title,
                           secondaryTitle: secondaryTitle,
                           action: action,
                           secondaryAction: secondaryAction,
                           onOpen: onOpen,
                           onClose: onClose)
    }

}

struct MenuControllerView<Content: View>: UIViewControllerRepresentable {

    let content: Content
    let title: String
    let secondaryTitle: String?
    let action: () -> Void
    let secondaryAction: (() -> Void)?
    let onOpen: (() -> Void)?
    let onClose: (() -> Void)?

    func makeCoordinator() -> Coordinator<Content> {
        Coordinator(title: title, secondaryTitle: secondaryTitle, action: action, secondaryAction: secondaryAction, onOpen: onOpen, onClose: onClose)
    }
    
    func makeUIViewController(context: Context) -> UIHostingController<Content> {
        let coordinator = context.coordinator
        
        let hostingController = HostingController(rootView: content, action: action, secondaryAction: secondaryAction)
        coordinator.responder = hostingController
        
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tap))
        hostingController.view.addGestureRecognizer(tap)
        
        return hostingController
    }
    
    func updateUIViewController(_ uiViewController: UIHostingController<Content>, context: Context) {
        context.coordinator.title = title
        context.coordinator.secondaryTitle = secondaryTitle
        context.coordinator.action = action
        context.coordinator.secondaryAction = secondaryAction
        context.coordinator.onOpen = onOpen
        context.coordinator.onClose = onClose
    }
    
    class Coordinator<CoordinatorContent: View>: NSObject {
        var responder: UIResponder?
        var observer: Any?
        var title: String
        var secondaryTitle: String?
        var action: () -> Void
        var secondaryAction: (() -> Void)?
        var onOpen: (() -> Void)?
        var onClose: (() -> Void)?
        
        init(title: String, secondaryTitle: String?, action: @escaping () -> Void, secondaryAction: (() -> Void)?, onOpen: (() -> Void)?, onClose: (() -> Void)?) {
            self.title = title
            self.secondaryTitle = secondaryTitle
            self.action = action
            self.secondaryAction = secondaryAction
            self.onOpen = onOpen
            self.onClose = onClose
        }
   
        @objc func tap(_ gestureRecognizer: UIGestureRecognizer) {
            let menu = UIMenuController.shared

            guard gestureRecognizer.state == .ended, let view = gestureRecognizer.view, !menu.isMenuVisible else {
                return
            }
            
            responder?.becomeFirstResponder()

            menu.menuItems = [
                UIMenuItem(title: self.title, action: #selector(HostingController<CoordinatorContent>.menuItemAction(_:)))
            ]

            if let secondaryTitle = secondaryTitle, !secondaryTitle.isEmpty, secondaryAction != nil {
                menu.menuItems?.append(UIMenuItem(title: secondaryTitle,
                                                  action: #selector(HostingController<CoordinatorContent>.menuItemSecondaryAction(_:))))
            }

            menu.showMenu(from: view, rect: view.bounds)

            observer = NotificationCenter.default.addObserver(forName: UIMenuController.willHideMenuNotification,
                                                              object: nil,
                                                              queue: nil) { [weak self] _ in
                if let observer = self?.observer {
                    NotificationCenter.default.removeObserver(observer)
                }
                self?.responder?.resignFirstResponder()
                self?.onClose?()
            }
            onOpen?()
        }

        deinit {
            if let observer = observer {
                NotificationCenter.default.removeObserver(observer)
            }
        }
    }
    
    class HostingController<HostedContent: View>: UIHostingController<HostedContent> {
        private var action: (() -> Void)?
        private var secondaryAction: (() -> Void)?

        convenience init(rootView: HostedContent, action: @escaping () -> Void, secondaryAction: (() -> Void)?) {
            self.init(rootView: rootView)

            self.action = action
            self.secondaryAction = secondaryAction

            preferredContentSize = view.intrinsicContentSize
            view.backgroundColor = .clear
            
            disableSafeArea()
        }
        
        override var canBecomeFirstResponder: Bool {
            true
        }
        
        @objc func menuItemAction(_ sender: Any) {
            self.action?()
        }

        @objc func menuItemSecondaryAction(_ sender: Any) {
            self.secondaryAction?()
        }
    }

}
