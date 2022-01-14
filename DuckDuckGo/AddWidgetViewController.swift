//
//  AddWidgetViewController.swift
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

import Foundation
import UIKit
import SwiftUI

@available(iOS 14.0, *)
final class AddWidgetViewController: UIViewController {
    
    private let hostingController = UIHostingController(rootView: AddWidgetView())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        setupConstraints()
    }
    
    private func setupConstraints() {
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        hostingController.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        hostingController.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
}
