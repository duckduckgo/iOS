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

public struct EditMenuItem {

    public let title: String
    public let action: () -> Void
    
    public init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

}

public extension View {
    
    func editMenu(@ArrayBuilder<EditMenuItem> _ items: () -> [EditMenuItem]) -> some View {
        EditMenuView(content: self, items: items())
            .fixedSize()
    }

}

public struct EditMenuView<Content: View>: UIViewControllerRepresentable {

    public typealias Item = EditMenuItem
    
    public let content: Content
    public let items: [Item]
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(items: items)
    }
    
    public func makeUIViewController(context: Context) -> UIHostingController<Content> {
        let coordinator = context.coordinator
        
        // `handler` dispatches calls to each item's action
        let hostVC = HostingController(rootView: content) { [weak coordinator] index in
            guard let items = coordinator?.items else { return }
            
            if !items.indices.contains(index) {
                assertionFailure()
                return
            }

            items[index].action()
        }
        
        coordinator.responder = hostVC
        
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tap))
        hostVC.view.addGestureRecognizer(tap)
        
        return hostVC
    }
    
    public func updateUIViewController(_ uiViewController: UIHostingController<Content>, context: Context) { }
    
    public class Coordinator: NSObject {
        let items: [Item]
        var responder: UIResponder?
        
        init(items: [Item]) {
            self.items = items
        }
        
        @objc func tap(_ gesture: UILongPressGestureRecognizer) {
            let menu = UIMenuController.shared

            guard gesture.state == .ended, let view = gesture.view, !menu.isMenuVisible else {
                return
            }
            
            responder?.becomeFirstResponder()
            
            menu.menuItems = items.enumerated().map { index, item in
                UIMenuItem(title: item.title, action: IndexedCallable.selector(for: index))
            }
            
            menu.showMenu(from: view, rect: view.bounds)
        }
    }
    
    /// Subclass of `UIHostingController` to handle responder actions
    class HostingController<Content: View>: UIHostingController<Content> {
        private var callable: IndexedCallable?
        
        convenience init(rootView: Content, handler: @escaping (Int) -> Void) {
            self.init(rootView: rootView)

            // make sure this VC is sized to its content
            preferredContentSize = view.intrinsicContentSize
            view.backgroundColor = .clear
            
            callable = IndexedCallable(handler: handler)
        }
        
        override var canBecomeFirstResponder: Bool {
            true
        }
        
        override func responds(to aSelector: Selector!) -> Bool {
            return super.responds(to: aSelector) || IndexedCallable.willRespond(to: aSelector)
        }
        
        // forward valid selectors to `callable`
        override func forwardingTarget(for aSelector: Selector!) -> Any? {
            guard IndexedCallable.willRespond(to: aSelector) else {
                return super.forwardingTarget(for: aSelector)
            }
            
            return callable
        }
    }

}
