//
//  ImportPasswordsViewModel.swift
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

import Foundation
import SwiftUI
import Core

protocol ImportPasswordsViewModelDelegate: AnyObject {
    func importPasswordsViewModelDidRequestOpenSync(_ viewModel: ImportPasswordsViewModel)
}

final class ImportPasswordsViewModel {

    enum ButtonType: String {
        case getBrowser
        case sync

        var title: String {
            switch self {
            case .getBrowser:
                return UserText.autofillImportPasswordsGetBrowserButton
            case .sync:
                return UserText.autofillImportPasswordsSyncButton
            }
        }
    }

    enum InstructionStep: Int, CaseIterable {
        case step1 = 1
        case step2
        case step3
        case step4

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
                return UserText.autofillImportPasswordsInstructionsStep1
            case .step2:
                return String(format: UserText.autofillImportPasswordsInstructionsStep2,
                              UserText.autofillImportPasswordsInstructionsStep2Settings,
                              UserText.autofillImportPasswordsInstructionsStep2Autofill)
            case .step3:
                return String(format: UserText.autofillImportPasswordsInstructionsStep3,
                              UserText.autofillImportPasswordsInstructionsStep3Import)
            case .step4:
                return String(format: UserText.autofillImportPasswordsInstructionsStep4, deviceType)
            }
        }
    }

    weak var delegate: ImportPasswordsViewModelDelegate?

    /// Keeping track on whether or not either button was pressed on this screen
    /// so that a pixel can be fired if the user navigates away without taking any action
    private(set) var buttonWasPressed: Bool = false

    func maxButtonWidth() -> CGFloat {
        let maxWidth = maxWidthFor(title1: ButtonType.getBrowser.title, title2: ButtonType.sync.title)
        return min(maxWidth, 300)
    }

    func buttonPressed(_ type: ButtonType) {
        buttonWasPressed = true

        switch type {
        case .getBrowser:
            Pixel.fire(pixel: .autofillLoginsImportGetDesktop)
        case .sync:
            openSync()
            Pixel.fire(pixel: .autofillLoginsImportSync)
        }
    }

    func instructionsForStep(_ step: InstructionStep) -> String {
        return step.instructions()
    }

    func attributedInstructionsForStep(_ step: InstructionStep) -> AttributedString {
        let semiboldFont = Font.system(.body).weight(.semibold)
        var attributedString = AttributedString(step.instructions())

        if case .step2 = step {
            attributedString.applyFontStyle(forSubstring: UserText.autofillImportPasswordsInstructionsStep2Settings,
                                            withFont: semiboldFont)
            attributedString.applyFontStyle(forSubstring: UserText.autofillImportPasswordsInstructionsStep2Autofill,
                                            withFont: semiboldFont)
        } else if case .step3 = step {
            attributedString.applyFontStyle(forSubstring: UserText.autofillImportPasswordsInstructionsStep3Import,
                                            withFont: semiboldFont)
        }

        return attributedString
    }

    private func openSync() {
        delegate?.importPasswordsViewModelDidRequestOpenSync(self)
    }

    private func maxWidthFor(title1: String, title2: String) -> CGFloat {
        return max(title1.width(), title2.width())
    }

}

private extension String {

    func width() -> CGFloat {
        let font = UIFont.boldAppFont(ofSize: 16)
        let attributes = [NSAttributedString.Key.font: font]
        let size = (self as NSString).size(withAttributes: attributes)
        return size.width
    }

}

private extension AttributedString {

    mutating func applyFontStyle(forSubstring substring: String, withFont font: Font) {
        if let range = self.range(of: substring) {
            self[range].font = font
        }
    }

}
