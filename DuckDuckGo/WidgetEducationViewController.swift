//
//  WidgetEducationViewController.swift
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

final class WidgetEducationViewController: UIViewController {
    
    private let host = UIHostingController(rootView: WidgetEducationView())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(host)
        view.addSubview(host.view)
        setupConstraints()
    }
    
    private func setupConstraints() {
        host.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            host.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            host.view.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
}
