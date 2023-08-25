//
//  EmailSignupPromptViewModel.swift
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

protocol EmailSignupPromptViewModelDelegate: AnyObject {
    func emailSignupPromptViewModelDidSelect(_ viewModel: EmailSignupPromptViewModel)
    func emailSignupPromptViewModelDidReject(_ viewModel: EmailSignupPromptViewModel)
    func emailSignupPromptViewModelDidClose(_ viewModel: EmailSignupPromptViewModel)
    func emailSignupPromptViewModelDidResizeContent(_ viewModel: EmailSignupPromptViewModel, contentHeight: CGFloat)
}

class EmailSignupPromptViewModel: ObservableObject {

    weak var delegate: EmailSignupPromptViewModelDelegate?

    var contentHeight: CGFloat = AutofillViews.passwordGenerationMinHeight {
        didSet {
            guard contentHeight != oldValue else {
                return
            }
            delegate?.emailSignupPromptViewModelDidResizeContent(self,
                                                                 contentHeight: max(contentHeight, AutofillViews.emailSignupPromptMinHeight))
        }
    }

    func continueSignupPressed() {
        delegate?.emailSignupPromptViewModelDidSelect(self)
    }

    func rejectSignupPressed() {
        delegate?.emailSignupPromptViewModelDidReject(self)
    }

    func closeButtonPressed() {
        delegate?.emailSignupPromptViewModelDidClose(self)
    }
}
