//
//  ImportPasswordsViewController.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

protocol ImportPasswordsViewControllerDelegate: AnyObject {
    func importPasswordsViewControllerDidRequestOpenSync(_ viewController: ImportPasswordsViewController)
}

final class ImportPasswordsViewController: UIViewController {

    weak var delegate: ImportPasswordsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    private func setupView() {
        let viewModel = ImportPasswordsViewModel()
        viewModel.delegate = self
        let controller = UIHostingController(rootView: ImportPasswordsView(viewModel: viewModel))
        controller.view.backgroundColor = .clear
        installChildViewController(controller)
    }

}

extension ImportPasswordsViewController: ImportPasswordsViewModelDelegate {

    func importPasswordsViewModelDidRequestOpenSync(_ viewModel: ImportPasswordsViewModel) {
        delegate?.importPasswordsViewControllerDidRequestOpenSync(self)
    }

}
