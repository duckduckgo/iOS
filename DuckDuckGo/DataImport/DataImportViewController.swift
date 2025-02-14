//
//  DataImportViewController.swift
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
import UniformTypeIdentifiers
import BrowserServicesKit
import Core
import Persistence
import Bookmarks
import DDGSync

protocol DataImportViewControllerDelegate: AnyObject {
    func dataImportViewControllerDidFinish(_ controller: DataImportViewController)
}

final class DataImportViewController: UIViewController {

    weak var delegate: DataImportViewControllerDelegate?

    private let viewModel: DataImportViewModel
    private let syncService: DDGSyncing

    init(importManager: DataImportManager, importScreen: DataImportViewModel.ImportScreen, syncService: DDGSyncing) {
        self.viewModel = DataImportViewModel(importScreen: importScreen, importManager: importManager)
        self.syncService = syncService

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    // MARK: - Private

    private func setupView() {
        viewModel.delegate = self
        let controller = UIHostingController(rootView: DataImportView(viewModel: viewModel))
        controller.view.backgroundColor = .clear
        installChildViewController(controller)
    }

    private func presentDocumentPicker() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: viewModel.state.importScreen.documentTypes, asCopy: true)
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = false
            present(documentPicker, animated: true)
        }
    }

    private func presentDataTypePicker(for contents: ImportArchiveContents) {
        let dataTypes = viewModel.importDataTypes(for: contents)

        let zipContentSelectionViewController = ZipContentSelectionViewController(dataTypes) { [weak self] dataTypes in
            self?.viewModel.importZipArchive(from: contents, for: dataTypes)
        }

        if let presentationController = zipContentSelectionViewController.presentationController as? UISheetPresentationController {
            if #available(iOS 16.0, *) {
                presentationController.detents = [.custom(resolver: { _ in
                    360.0
                })]
            } else {
                presentationController.detents = [.medium()]
            }
        }

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            self.viewModel.isLoading = false
            self.present(zipContentSelectionViewController, animated: true)
        }
    }

    private func presentSummary(for summary: DataImportSummary) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            self.navigationController?.present(DataImportSummaryViewController(summary: summary, syncService: syncService), animated: true) { [weak self] in
                guard let self = self else { return }

                self.navigationController?.popViewController(animated: false)
                delegate?.dataImportViewControllerDidFinish(self)
            }
        }
    }

}

// MARK: - DataImportViewModelDelegate

extension DataImportViewController: DataImportViewModelDelegate {

    func dataImportViewModelDidRequestImportFile(_ viewModel: DataImportViewModel) {
        viewModel.isLoading = true
        presentDocumentPicker()
    }

    func dataImportViewModelDidRequestPresentDataPicker(_ viewModel: DataImportViewModel, contents: Core.ImportArchiveContents) {
        presentDataTypePicker(for: contents)
    }

    func dataImportViewModelDidRequestPresentSummary(_ viewModel: DataImportViewModel, summary: BrowserServicesKit.DataImportSummary) {
        DispatchQueue.main.async { [weak self] in
            self?.viewModel.isLoading = false
            self?.presentSummary(for: summary)
        }
    }

}


// MARK: - UIDocumentPickerDelegate

extension DataImportViewController: UIDocumentPickerDelegate {

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        var validDocumentSelected = false

        defer {
            if !validDocumentSelected {
                viewModel.isLoading = false
            }
        }

        guard let selectedFileURL = urls.first else {
            return
        }

        do {
            let resourceValues = try selectedFileURL.resourceValues(forKeys: [.typeIdentifierKey])

            guard let typeIdentifier = resourceValues.typeIdentifier,
                  let fileType = DataImportFileType(typeIdentifier: typeIdentifier) else {
                ActionMessageView.present(message: UserText.dataImportFailedUnsupportedFileErrorMessage)
                return
            }

            validDocumentSelected = true
            viewModel.handleFileSelection(selectedFileURL, type: fileType)

        } catch {
            Logger.autofill.debug("Failed to determine the file type: \(error)")
            ActionMessageView.present(message: UserText.dataImportFailedUnsupportedFileErrorMessage)
        }
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        viewModel.isLoading = false
    }
}
