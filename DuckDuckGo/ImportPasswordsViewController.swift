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
import Core
import DDGSync

protocol ImportPasswordsViewControllerDelegate: AnyObject {
    func importPasswordsViewControllerDidRequestOpenSync(_ viewController: ImportPasswordsViewController)
}

final class ImportPasswordsViewController: UIViewController {

    weak var delegate: ImportPasswordsViewControllerDelegate?

    private let viewModel = ImportPasswordsViewModel()

    init(syncService: DDGSyncing) {
        let importPasswordsStatusHandler = ImportPasswordsStatusHandler(syncService: syncService)
        importPasswordsStatusHandler.setImportViaSyncStartDateIfRequired()

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isMovingFromParent && !viewModel.buttonWasPressed {
            Pixel.fire(pixel: .autofillLoginsImportNoAction)
        }
    }

    private func setupView() {
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
