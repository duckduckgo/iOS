//
//  ImportPasswordsViewModel.swift
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

protocol ImportPasswordsViewModelDelegate: AnyObject {
    func importPasswordsViewModelDidRequestImportFile(_ viewModel: ImportPasswordsViewModel)
}

final class ImportPasswordsViewModel {

    weak var delegate: ImportPasswordsViewModelDelegate?

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

        func instructions() -> String {
            switch self {
            case .step1:
                return String(format: UserText.autofillImportPasswordsInstructionsStep1,
                              deviceType,
                              UserText.autofillImportPasswordsInstructionsStep1SystemSettings,
                              UserText.autofillImportPasswordsInstructionsStep1Safari)
            case .step2:
                return String(format: UserText.autofillImportPasswordsInstructionsStep2,
                              UserText.autofillImportPasswordsInstructionsStep2Export,
                              UserText.autofillImportPasswordsInstructionsStep2Passwords)
            }
        }
    }

    func instructionsForStep(_ step: InstructionStep) -> String {
        return step.instructions()
    }

    func attributedInstructionsForStep(_ step: InstructionStep) -> AttributedString {
        let semiboldFont = Font.system(.body).weight(.semibold)
        var attributedString = AttributedString(step.instructions())

        if case .step1 = step {
            attributedString.applyFontStyle(forSubstring: UserText.autofillImportPasswordsInstructionsStep1SystemSettings,
                                            withFont: semiboldFont)
            attributedString.applyFontStyle(forSubstring: UserText.autofillImportPasswordsInstructionsStep1Safari,
                                            withFont: semiboldFont)
        } else if case .step2 = step {
            attributedString.applyFontStyle(forSubstring: UserText.autofillImportPasswordsInstructionsStep2Export,
                                            withFont: semiboldFont)
            attributedString.applyFontStyle(forSubstring: UserText.autofillImportPasswordsInstructionsStep2Passwords,
                                            withFont: semiboldFont)
        }

        return attributedString
    }

    func selectFile() {
        delegate?.importPasswordsViewModelDidRequestImportFile(self)
    }

}

// TODO - create an extension for AttributedString that applies a font style to a substring
private extension AttributedString {

    mutating func applyFontStyle(forSubstring substring: String, withFont font: Font) {
        if let range = self.range(of: substring) {
            self[range].font = font
        }
    }

}
