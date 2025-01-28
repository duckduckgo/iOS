//
//  ImportPasswordsViewController.swift
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

protocol ImportPasswordsViewControllerDelegate: AnyObject {
    func importPasswordsViewControllerDidFinish(_ controller: ImportPasswordsViewController)
}

final class ImportPasswordsViewController: UIViewController {
    
    private let viewModel = ImportPasswordsViewModel()
    private let importer: FileDataImportingService

    weak var delegate: ImportPasswordsViewControllerDelegate?


    init(importer: FileDataImportingService = FileDataImporter(reporter: SecureVaultReporter())) {
        self.importer = importer

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    /* TODO - still needed?
     override func viewWillDisappear(_ animated: Bool) {
     super.viewWillDisappear(animated)
     
     if isMovingFromParent && !viewModel.buttonWasPressed {
     Pixel.fire(pixel: .autofillLoginsImportNoAction)
     }
     }
     */
    
    private func setupView() {
        viewModel.delegate = self
        let controller = UIHostingController(rootView: ImportPasswordsView(viewModel: viewModel))
        controller.view.backgroundColor = .clear
        installChildViewController(controller)
    }
    
    private func presentDocumentPicker() {
        let docTypes = [UTType.zip, UTType.commaSeparatedText]
        let docPicker = UIDocumentPickerViewController(forOpeningContentTypes: docTypes, asCopy: true)
        docPicker.delegate = self
        docPicker.allowsMultipleSelection = false
        present(docPicker, animated: true)
    }

    private func handleFileSelection(_ url: URL, type: FileDataImporter.ImportType) {
        Task {
            let summary = await importer.importFile(at: url, type: type)

            navigationController?.present(ImportPasswordsCompleteViewController(summary: summary), animated: true) { [weak self] in
                guard let self = self else { return }

                self.navigationController?.popViewController(animated: false)
                delegate?.importPasswordsViewControllerDidFinish(self)
            }
        }
    }
}

extension ImportPasswordsViewController: ImportPasswordsViewModelDelegate {
    
    func importPasswordsViewModelDidRequestImportFile(_ viewModel: ImportPasswordsViewModel) {
        presentDocumentPicker()
    }
}


extension ImportPasswordsViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        guard let selectedFileURL = urls.first else { return }

        do {
            let resourceValues = try selectedFileURL.resourceValues(forKeys: [.typeIdentifierKey])
            guard let typeIdentifier = resourceValues.typeIdentifier else {
                Logger.autofill.debug("No type identifier found for file")
                return
            }

            let importType: FileDataImporter.ImportType
            switch typeIdentifier {
            case "public.zip-archive":
                Logger.autofill.debug("User imported a ZIP file.")
                importType = .zip

            case "public.comma-separated-values-text":
                Logger.autofill.debug("User imported a CSV file.")
                importType = .csv

            default:
                Logger.autofill.debug("Unsupported file type: \(typeIdentifier)")
                // TODO: Present error message
                // ActionMessageView.present(message: UserText.importFailedMessage)
                return
            }

            handleFileSelection(selectedFileURL, type: importType)

        } catch {
            Logger.autofill.debug("Failed to determine the file type: \(error)")
            // TODO: Present error message
            // ActionMessageView.present(message: UserText.importFailedMessage)
        }
    }
}
