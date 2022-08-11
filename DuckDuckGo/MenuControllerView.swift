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

    func menuController(_ title: String, action: @escaping () -> Void, onOpen: (() -> Void)? = nil, onClose: (() -> Void)? = nil) -> some View {
        MenuControllerView(content: self, title: title, action: action, onOpen: onOpen, onClose: onClose)
    }

}

struct MenuControllerView<Content: View>: UIViewControllerRepresentable {

    let content: Content
    let title: String
    let action: () -> Void
    let onOpen: (() -> Void)?
    let onClose: (() -> Void)?

    func makeCoordinator() -> Coordinator<Content> {
        Coordinator(title: title, action: action, onOpen: onOpen, onClose: onClose)
    }
    
    func makeUIViewController(context: Context) -> UIHostingController<Content> {
        let coordinator = context.coordinator
        
        let hostingController = HostingController(rootView: content, action: action)
        coordinator.responder = hostingController
        
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tap))
        hostingController.view.addGestureRecognizer(tap)
        
        return hostingController
    }
    
    func updateUIViewController(_ uiViewController: UIHostingController<Content>, context: Context) { }
    
    class Coordinator<Content: View>: NSObject {
        var responder: UIResponder?
        var observer: Any?
        private let title: String
        private let action: () -> Void
        private let onOpen: (() -> Void)?
        private let onClose: (() -> Void)?
        
        init(title: String, action: @escaping () -> Void, onOpen: (() -> Void)?, onClose: (() -> Void)?) {
            self.title = title
            self.action = action
            self.onOpen = onOpen
            self.onClose = onClose
        }
   
        @objc func tap(_ gestureRecognizer: UILongPressGestureRecognizer) {
            let menu = UIMenuController.shared

            guard gestureRecognizer.state == .ended, let view = gestureRecognizer.view, !menu.isMenuVisible else {
                return
            }
            
            responder?.becomeFirstResponder()

            menu.menuItems = [
                UIMenuItem(title: self.title, action: #selector(HostingController<Content>.menuItemAction(_:)))
            ]

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
    
    class HostingController<Content: View>: UIHostingController<Content> {
        private var action: (() -> Void)?

        convenience init(rootView: Content, action: @escaping () -> Void) {
            self.init(rootView: rootView)

            self.action = action
            
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
        
        // Work around an issue with Safe Areas inside UIHostingController: https://defagos.github.io/swiftui_collection_part3/
        func disableSafeArea() {
            guard let viewClass = object_getClass(view) else { return }
            
            let viewSubclassName = String(cString: class_getName(viewClass)).appending("_IgnoreSafeArea")
            if let viewSubclass = NSClassFromString(viewSubclassName) {
                object_setClass(view, viewSubclass)
            } else {
                guard let viewClassNameUtf8 = (viewSubclassName as NSString).utf8String else { return }
                guard let viewSubclass = objc_allocateClassPair(viewClass, viewClassNameUtf8, 0) else { return }
                
                if let method = class_getInstanceMethod(UIView.self, #selector(getter: UIView.safeAreaInsets)) {
                    let safeAreaInsets: @convention(block) (AnyObject) -> UIEdgeInsets = { _ in
                        return .zero
                    }

                    class_addMethod(viewSubclass,
                                    #selector(getter: UIView.safeAreaInsets),
                                    imp_implementationWithBlock(safeAreaInsets),
                                    method_getTypeEncoding(method))
                }
                
                objc_registerClassPair(viewSubclass)
                object_setClass(view, viewSubclass)
            }
        }
    }

}
