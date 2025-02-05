//
//  ZipContentSelectionViewController.swift
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

import UIKit
import SwiftUI
import BrowserServicesKit
import Core

final class ZipContentSelectionViewController: UIViewController {

    typealias ZipContentSelectionViewControllerCompletion = (_ dataTypes: [DataImport.DataType]) -> Void
    let completion: ZipContentSelectionViewControllerCompletion
    
    private var viewModel: ZipContentSelectionViewModel?
    private let importPreview: [DataImportPreview]

    init(_ importPreview: [DataImportPreview], completion: @escaping ZipContentSelectionViewControllerCompletion) {
        self.importPreview = importPreview
        self.completion = completion
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(designSystemColor: .surface)
        setupView()
    }

    // MARK: - Private

    private func setupView() {
        let viewModel = ZipContentSelectionViewModel(importPreview: importPreview)
        viewModel.delegate = self
        
        let view = ZipContentSelectionView(viewModel: viewModel)
        let controller = UIHostingController(rootView: view)
        controller.view.backgroundColor = .clear
        presentationController?.delegate = self
        installChildViewController(controller)
    }
    
}

// MARK: - UISheetPresentationControllerDelegate

extension ZipContentSelectionViewController: UISheetPresentationControllerDelegate {

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        // TODO - pixel?
    }

}

// MARK: - ZipContentSelectionViewModelDelegate

extension ZipContentSelectionViewController: ZipContentSelectionViewModelDelegate {

    func zipContentSelectionViewModelDidSelectOptions(_ viewModel: ZipContentSelectionViewModel, selectedTypes: [DataImport.DataType]) {
        completion(selectedTypes)
        self.dismiss(animated: true)
    }
    
    func zipContentSelectionViewModelDidSelectCancel(_ viewModel: ZipContentSelectionViewModel) {
        self.dismiss(animated: true)
    }
    
    func zipContentSelectionViewModelDidResizeContent(_ viewModel: ZipContentSelectionViewModel, contentHeight: CGFloat) {
        if #available(iOS 16.0, *) {
            if let sheetPresentationController = self.presentationController as? UISheetPresentationController {
                sheetPresentationController.animateChanges {
                    sheetPresentationController.detents = [.custom(resolver: { _ in contentHeight })]
                }
            }
        }
    }

}
