//
//  EmailAddressPromptViewModel.swift
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
import BrowserServicesKit

protocol EmailAddressPromptViewModelDelegate: AnyObject {
    func emailAddressPromptViewModelDidSelectUserEmail(_ viewModel: EmailAddressPromptViewModel)
    func emailAddressPromptViewModelDidSelectGeneratedEmail(_ viewModel: EmailAddressPromptViewModel)
    func emailAddressPromptViewModelDidClose(_ viewModel: EmailAddressPromptViewModel)
    func emailAddressPromptViewModelDidResizeContent(_ viewModel: EmailAddressPromptViewModel, contentHeight: CGFloat)
}

class EmailAddressPromptViewModel: ObservableObject {

    weak var delegate: EmailAddressPromptViewModelDelegate?
    
    var contentHeight: CGFloat = AutofillViews.passwordGenerationMinHeight {
        didSet {
            guard contentHeight != oldValue else { return }
            delegate?.emailAddressPromptViewModelDidResizeContent(self,
                                                                  contentHeight: max(contentHeight, AutofillViews.emailSignupPromptMinHeight))
        }
    }

    let userEmail: String?

    init(userEmail: String?) {
        self.userEmail = userEmail
    }

    func selectUserEmailPressed() {
        delegate?.emailAddressPromptViewModelDidSelectUserEmail(self)
    }

    func selectGeneratedEmailPressed() {
        delegate?.emailAddressPromptViewModelDidSelectGeneratedEmail(self)
    }

    func closeButtonPressed() {
        delegate?.emailAddressPromptViewModelDidClose(self)
    }
}
