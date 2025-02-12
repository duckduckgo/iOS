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

        if #available(iOS 16.0, *) {
            let menu = UIEditMenuInteraction(delegate: coordinator)
            hostingController.view.addInteraction(menu)
            context.coordinator.menu = menu
        }

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

    class Coordinator<CoordinatorContent: View>: NSObject, UIEditMenuInteractionDelegate {
        var responder: UIResponder?
        var observer: Any?
        var title: String
        var secondaryTitle: String?
        var action: () -> Void
        var secondaryAction: (() -> Void)?
        var onOpen: (() -> Void)?
        var onClose: (() -> Void)?

        // Define me as UIEditMenuInteraction when iOS 15 is dropped
        var menu: NSObject?

        init(title: String, secondaryTitle: String?, action: @escaping () -> Void, secondaryAction: (() -> Void)?, onOpen: (() -> Void)?, onClose: (() -> Void)?) {
            self.title = title
            self.secondaryTitle = secondaryTitle
            self.action = action
            self.secondaryAction = secondaryAction
            self.onOpen = onOpen
            self.onClose = onClose
            super.init()
        }
   
        @objc func tap(_ gestureRecognizer: UIGestureRecognizer) {
            if #available(iOS 16.0, *) {
                handleiOS16Tap(gestureRecognizer)
            } else {
                handleiOS15Tap(gestureRecognizer)
            }
            onOpen?()
        }

        // MARK: Private

        private func handleiOS15Tap(_ gestureRecognizer: UIGestureRecognizer) {
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
                self?.handleClose()
            }
        }

        private func handleClose() {
            if let observer {
                NotificationCenter.default.removeObserver(observer)
            }
            responder?.resignFirstResponder()
            onClose?()
        }

        @available(iOS 16.0, *)
        private func handleiOS16Tap(_ gestureRecognizer: UIGestureRecognizer) {
            guard let menuInteraction = menu as? UIEditMenuInteraction else {
                return
            }

            guard gestureRecognizer.state == .ended, let view = gestureRecognizer.view else {
                return
            }

            let menuConfig = UIEditMenuConfiguration.init(identifier: nil, sourcePoint: view.center)

            menuInteraction.presentEditMenu(with: menuConfig)
        }

        // MARK: UIEditMenuInteractionDelegate

        @available(iOS 16.0, *)
        func editMenuInteraction(_ interaction: UIEditMenuInteraction, menuFor configuration: UIEditMenuConfiguration, suggestedActions: [UIMenuElement]) -> UIMenu? {
            var actions: [UIAction] = [.init(title: title) { [weak self] _ in
                self?.action()
            }]

            if let secondaryTitle, let secondaryAction {
                actions.append(.init(title: secondaryTitle) { _ in
                    secondaryAction()
                })
            }

            let uiMenu: UIMenu = .init(title: "menu",
                                        children: actions)

            return uiMenu
        }

        @available(iOS 16.0, *)
        func editMenuInteraction(_ interaction: UIEditMenuInteraction, willDismissMenuFor configuration: UIEditMenuConfiguration, animator: any UIEditMenuInteractionAnimating) {
            handleClose()
        }

        // Delete me when iOS 15 is dropped
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

        // Delete me when iOS 15 is dropped
        @objc func menuItemAction(_ sender: Any) {
            self.action?()
        }

        // Delete me when iOS 15 is dropped
        @objc func menuItemSecondaryAction(_ sender: Any) {
            self.secondaryAction?()
        }
    }

}
