//
//  ImportPasswordsCompleteViewController.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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
import BrowserServicesKit

final class ImportPasswordsCompleteViewController: UIViewController {

    private var viewModel: ImportPasswordsCompleteViewModel

    init(summary: DataImportSummary) {
        self.viewModel = ImportPasswordsCompleteViewModel(summary: summary)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    private func setupView() {
        viewModel.delegate = self
        let controller = UIHostingController(rootView: ImportPasswordsCompleteView(viewModel: viewModel))
        controller.view.backgroundColor = .clear
        installChildViewController(controller)
    }

}

extension ImportPasswordsCompleteViewController: ImportPasswordsCompleteViewModelDelegate {

    func importPasswordsCompleteViewModelComplete(_ viewModel: ImportPasswordsCompleteViewModel) {
        dismiss(animated: true)
    }

    // TODO - also need to capture the drag down to dismiss screen action
}
