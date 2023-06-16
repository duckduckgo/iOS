//
//  PasswordGenerationPromptViewModel.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

protocol PasswordGenerationPromptViewModelDelegate: AnyObject {
    func passwordGenerationPromptViewModelDidSelect(_ viewModel: PasswordGenerationPromptViewModel)
    func passwordGenerationPromptViewModelDidCancel(_ viewModel: PasswordGenerationPromptViewModel)
    func passwordGenerationPromptViewModelDidResizeContent(_ viewModel: PasswordGenerationPromptViewModel, contentHeight: CGFloat)
}

class PasswordGenerationPromptViewModel: ObservableObject {

    weak var delegate: PasswordGenerationPromptViewModelDelegate?

    var contentHeight: CGFloat = AutofillViews.passwordGenerationMinHeight {
        didSet {
            guard contentHeight != oldValue else {
                return
            }
            delegate?.passwordGenerationPromptViewModelDidResizeContent(self,
                                                                        contentHeight: max(contentHeight, AutofillViews.passwordGenerationMinHeight))
        }
    }

    let generatedPassword: String

    internal init(generatedPassword: String) {
        self.generatedPassword = generatedPassword
    }

    func useGeneratedPasswordPressed() {
        delegate?.passwordGenerationPromptViewModelDidSelect(self)
    }

    func cancelButtonPressed() {
        delegate?.passwordGenerationPromptViewModelDidCancel(self)
    }
}
