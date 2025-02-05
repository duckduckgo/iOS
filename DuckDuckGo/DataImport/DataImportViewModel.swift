//
//  DataImportViewModel.swift
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
import SwiftUI
import UniformTypeIdentifiers
import Core
import BrowserServicesKit

protocol DataImportViewModelDelegate: AnyObject {
    func dataImportViewModelDidRequestImportFile(_ viewModel: DataImportViewModel)
    func dataImportViewModelDidRequestPresentDataPicker(_ viewModel: DataImportViewModel, contents: ImportArchiveContents)
    func dataImportViewModelDidRequestPresentSummary(_ viewModel: DataImportViewModel, summary: DataImportSummary)
}

final class DataImportViewModel: ObservableObject {

    enum Layout {
        case safariOnly
        case safariAndChrome
    }

    enum ImportScreen {
        case passwords
        case bookmarks

        var documentTypes: [UTType] {
            switch self {
            case .passwords: return [.zip, .commaSeparatedText]
            case .bookmarks: return [.zip, .html]
            }
        }

        var layout: Layout {
            switch self {
            case .passwords:
                return .safariAndChrome
            case .bookmarks:
                return .safariOnly
            }
        }
    }

    enum BrowserInstructions: String, CaseIterable, Identifiable {
        case safari
        case chrome

        var id: String { rawValue }

        var icon: Image {
            switch self {
            case .safari:
                return Image(.safariMulticolor)
            case .chrome:
                return Image(.chromeMulticolor)
            }
        }

        var displayName: String {
            switch self {
            case .safari:
                return UserText.dataImportPasswordsInstructionSafari
            case .chrome:
                return UserText.dataImportPasswordsInstructionChrome
            }
        }

        enum InstructionStep: Int, CaseIterable {
            case step1 = 1
            case step2

            private var deviceType: String {
                switch UIDevice.current.userInterfaceIdiom {
                case .phone:
                    return UserText.deviceTypeiPhone
                case .pad:
                    return UserText.deviceTypeiPad
                default:
                    return UserText.deviceTypeDefault
                }
            }

            func attributedInstructions(for browser: BrowserInstructions) -> AttributedString {
                switch browser {
                case .safari:
                    return attributedInstructionsForSafari()
                case .chrome:
                    return attributedInstructionsForChrome()
                }
            }

            private func attributedInstructionsForSafari() -> AttributedString {
                switch self {
                case .step1:
                    var attributedString = AttributedString(
                        String(
                            format: UserText.dataImportPasswordsInstructionsSafariStep1,
                            UserText.deviceTypeiPhone,
                            UserText.dataImportPasswordsInstructionsSafariStep1SystemSettings
                        )
                    )
                    attributedString.applyBoldStyle(to: UserText.dataImportPasswordsInstructionsSafariStep1SystemSettings)
                    return attributedString
                case .step2:
                    var attributedString = AttributedString(
                        String(
                            format: UserText.dataImportPasswordsInstructionsSafariStep2,
                            UserText.dataImportPasswordsInstructionsSafariStep2History,
                            UserText.dataImportPasswordsInstructionsSafariStep2Export,
                            UserText.dataImportPasswordsInstructionsSafariStep2Passwords
                        )
                    )
                    attributedString.applyBoldStyle(to: UserText.dataImportPasswordsInstructionsSafariStep2History)
                    attributedString.applyBoldStyle(to: UserText.dataImportPasswordsInstructionsSafariStep2Export)
                    attributedString.applyBoldStyle(to: UserText.dataImportPasswordsInstructionsSafariStep2Passwords)
                    return attributedString
                }
            }

            private func attributedInstructionsForChrome() -> AttributedString {
                switch self {
                case .step1:
                    var attributedString = AttributedString(
                        String(
                            format: UserText.dataImportPasswordsInstructionsChromeStep1,
                            UserText.dataImportPasswordsInstructionsChromeStep1PasswordManager,
                            UserText.dataImportPasswordsInstructionsChromeStep1Settings
                        )
                    )
                    attributedString.applyBoldStyle(to: UserText.dataImportPasswordsInstructionsChromeStep1PasswordManager)
                    attributedString.applyBoldStyle(to: UserText.dataImportPasswordsInstructionsChromeStep1Settings)
                    return attributedString
                case .step2:
                    var attributedString = AttributedString(
                        String(
                            format: UserText.dataImportPasswordsInstructionsChromeStep2,
                            UserText.dataImportPasswordsInstructionsStep2ChromeHistory,
                            UserText.dataImportPasswordsInstructionsStep2ChromeExport
                        )
                    )
                    attributedString.applyBoldStyle(to: UserText.dataImportPasswordsInstructionsStep2ChromeHistory)
                    attributedString.applyBoldStyle(to: UserText.dataImportPasswordsInstructionsStep2ChromeExport)
                    return attributedString
                }
            }
        }
    }

    @Published var selectedBrowser: BrowserInstructions = .safari
    weak var delegate: DataImportViewModelDelegate?
    var importScreen: ImportScreen
    private let importManager: DataImportManaging

    init(importScreen: ImportScreen, importManager: DataImportManaging) {
        self.importScreen = importScreen
        self.importManager = importManager
    }

    func selectFile() {
        delegate?.dataImportViewModelDidRequestImportFile(self)
    }

    func handleFileSelection(_ url: URL, type: DataImportFileType) {
        switch type {
        case .zip:
            do {
               let contents = try ImportArchiveReader().readContents(from: url)

                switch contents.type {
                case .both:
                    delegate?.dataImportViewModelDidRequestPresentDataPicker(self, contents: contents)
                case .passwordsOnly:
                    importZipArchive(from: contents, for: [.passwords])
                case .bookmarksOnly:
                    importZipArchive(from: contents, for: [.bookmarks])
                case .none:
                    DispatchQueue.main.async {
                        ActionMessageView.present(message: UserText.dataImportFailedNoDataInZipErrorMessage)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    ActionMessageView.present(message: UserText.dataImportFailedReadZipErrorMessage)
                }
            }
        default:
            importFile(at: url, for: type)
        }
    }

    func importZipArchive(from contents: ImportArchiveContents,
                                  for dataTypes: [DataImport.DataType]) {
        Task {
            let summary = await importManager.importZipArchive(from: contents, for: dataTypes)
            Logger.autofill.debug("Imported \(summary.description)")

            delegate?.dataImportViewModelDidRequestPresentSummary(self, summary: summary)
        }
    }

    // MARK: - Private

    private func importFile(at url: URL, for fileType: DataImportFileType) {
        Task {
            do {
                guard let summary = try await importManager.importFile(at: url, for: fileType) else {
                    Logger.autofill.debug("Failed to import data")
                    DispatchQueue.main.async {
                        ActionMessageView.present(message: UserText.dataImportFailedErrorMessage)
                    }
                    return
                }

                Logger.autofill.debug("Imported \(summary.description)")
                delegate?.dataImportViewModelDidRequestPresentSummary(self, summary: summary)
            } catch {
                Logger.autofill.debug("Failed to import data: \(error)")
                DispatchQueue.main.async {
                    ActionMessageView.present(message: UserText.dataImportFailedErrorMessage)
                }
            }
        }
    }

}

// MARK: - AttributedString

private extension AttributedString {

    mutating func applyBoldStyle(to substring: String) {
        if let range = self.range(of: substring) {
            self[range].font = Font.body.bold()
        }
    }

}
