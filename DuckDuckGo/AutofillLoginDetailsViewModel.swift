//
//  AutofillLoginDetailsViewModel.swift
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
import BrowserServicesKit
import SwiftUI

protocol AutofillLoginDetailsViewModelDelegate: AnyObject {
    func autofillLoginDetailsViewModelDidSave()
}


final class AutofillLoginDetailsViewModel: ObservableObject {
    enum ViewMode {
        case edit
        case view
    }
    
    enum PasteboardCopyAction {
        case username
        case password
        case address
    }
    
    weak var delegate: AutofillLoginDetailsViewModelDelegate?
    let account: SecureVaultModels.WebsiteAccount
    @Published var username = ""
    @Published var password = ""
    @Published var address = ""
    @Published var title = ""
    @Published var viewMode: ViewMode = .view
    var lastUpdatedAt = ""
    @ObservedObject var headerViewModel: AutofillLoginDetailsHeaderViewModel
    
    internal init(account: SecureVaultModels.WebsiteAccount) {
        self.account = account
        self.username = account.username
        self.address = account.domain
        self.title = account.name
        self.lastUpdatedAt = account.lastUpdated.debugDescription
        
        self.headerViewModel = AutofillLoginDetailsHeaderViewModel(title: account.name, subtitle: lastUpdatedAt, loadImage: { completion in
            FaviconsHelper.loadFaviconSync(forDomain: account.domain,
                                           usingCache: .tabs,
                                           useFakeFavicon: true) { image, _ in
                if let image = image {
                    completion(image)
                } else {
                    completion(UIImage(systemName: "globle")!)
                }
            }
        })
        
        setupPassword(with: account)
    }
    
    
    func toggleEditMode() {
        withAnimation {
            if viewMode == .edit {
                viewMode = .view
            } else {
                viewMode = .edit
            }
        }
    }
    
    func copyToPasteboard(_ action: PasteboardCopyAction) {
        switch action {
        case .username:
            UIPasteboard.general.string = username
        case .password:
            UIPasteboard.general.string = password
        case .address:
            UIPasteboard.general.string = address
        }
    }
    
    #warning("Refactor, copied from SaveLoginViewModel")
    var hiddenPassword: String {
         let maximumPasswordDisplayCount = 40

        // swiftlint:disable:next line_length
        let passwordCount = password.count > maximumPasswordDisplayCount ? maximumPasswordDisplayCount : password.count
        return String(repeating: "•", count: passwordCount)
    }
    
    
    private func setupPassword(with account: SecureVaultModels.WebsiteAccount) {
        do {
            if let accountID = account.id {
                let vault = try SecureVaultFactory.default.makeVault(errorReporter: SecureVaultErrorReporter.shared)
                                                                 
                if let credential = try
                    vault.websiteCredentialsFor(accountId: accountID) {
                    self.password = String(data: credential.password, encoding: .utf8) ?? ""
                }
            }
            
        } catch {
            print("Can't retrieve password")
        }
        
    }
    
    private func updateHeaderModel(with credential: SecureVaultModels.WebsiteCredentials) {
        self.headerViewModel.title = credential.account.name
        self.headerViewModel.subtitle = credential.account.lastUpdated.debugDescription
    }
    
    func save() {
        do {
            if let accountID = account.id {
                let vault = try SecureVaultFactory.default.makeVault(errorReporter: SecureVaultErrorReporter.shared)
                                                                 
                if var credential = try vault.websiteCredentialsFor(accountId: accountID) {
                    credential.account.username = username
                    credential.account.title = title
                    credential.account.domain = address
                    credential.password = password.data(using: .utf8)!
                    
                    try vault.storeWebsiteCredentials(credential)
                    delegate?.autofillLoginDetailsViewModelDidSave()
                    
                    //Refetch after save to get updated properties like "lastUpdated"
                    if let newCredential = try vault.websiteCredentialsFor(accountId: accountID) {
                        updateHeaderModel(with: newCredential)
                    }
                }
            }
        } catch {
            
        }
    }
}

final class AutofillLoginDetailsHeaderViewModel: ImageTitleSubtitleListItemViewModelProtocol {
    @Published var title: String
    var subtitle: String
    var loadImage: LoadImageClosure
    @Published var image = UIImage(systemName: "globe")!

    internal init(title: String, subtitle: String, loadImage: @escaping AutofillLoginDetailsHeaderViewModel.LoadImageClosure) {
        self.title = title
        self.subtitle = subtitle
        self.loadImage = loadImage
        
        self.loadImage { image in
            self.image = image
        }
    }
}
