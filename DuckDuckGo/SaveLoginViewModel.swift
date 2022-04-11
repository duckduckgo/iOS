//
//  SaveLoginViewModel.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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

protocol SaveLoginViewModelDelegate: AnyObject {
    func saveLoginViewModelDidSave(_ viewModel: SaveLoginViewModel)
    func saveLoginViewModelDidCancel(_ viewModel: SaveLoginViewModel)
}

class SaveLoginViewModel {
    weak var delegate: SaveLoginViewModelDelegate?
    let title: String
    let subtitle: String?
    let username: String?
    let password: String?
    let confirmButtonLabel: String
    let cancelButtonLabel: String
    
    internal init(title: String, subtitle: String? = nil, username: String? = nil, password: String? = nil, confirmButtonLabel: String, cancelButtonLabel: String) {
        self.title = title
        self.subtitle = subtitle
        self.username = username
        self.password = password
        self.confirmButtonLabel = confirmButtonLabel
        self.cancelButtonLabel = cancelButtonLabel
    }
    
    func cancel() {
        delegate?.saveLoginViewModelDidCancel(self)
    }
    
    func save() {
        delegate?.saveLoginViewModelDidSave(self)
    }
    
}
