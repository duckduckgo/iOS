//
//  CookiesManagedViewController.swift
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

import UIKit
import SwiftUI

class CookiesManagedViewController: UIViewController {
    
//    private let hostingController = UIHostingController(rootView: BadgeAnimationView(animationModel: BadgeNotificationAnimationModel(),
//                                                                                     iconView: AnyView(Image(systemName: "trash")),
//                                                                                     text: "Cookies Managed!"))
    
    private let hostingController = UIHostingController(rootView: OmniBarNotification(model: OmniBarModel()), ignoreSafeArea: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        setupConstraints()
    }
    
    private func setupConstraints() {
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            hostingController.view.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    
}

extension CookiesManagedViewController: OmniBarNotificationAnimated {

    func startAnimation(_ completion: @escaping () -> Void) {
//        hostingController.rootView.model.isOpen = true
        
        hostingController.rootView.model.show()
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
//            self.hostingController.rootView.model.isOpen = false
//        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.6) {
            completion()
        }
    }
    
}
