//
//  BookmarksEmptyView.swift
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

import SwiftUI
import DesignResourcesKit
import DuckUI

struct BookmarksEmptyView: View {

    var importViaSafariButtonAction: (() -> Void)?
    var importDocumentButtonAction: (() -> Void)?

    var body: some View {
            VStack(spacing: 0) {
                Image(.bookmarksImport96)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 96, height: 96)

                Text(UserText.emptyBookmarks)
                    .daxTitle3()
                    .foregroundColor(Color(designSystemColor: .textPrimary))
                    .padding(.top, 16)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)

                Text(UserText.emptyBookmarksSubtitle)
                    .daxBodyRegular()
                    .foregroundColor(Color.init(designSystemColor: .textSecondary))
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                    .lineLimit(nil)

                if #available(iOS 18.2, *) {
                    Button {
                        importViaSafariButtonAction?()
                    } label: {
                        Text(UserText.importBookmarksActionTitle)
                            .frame(width: maxButtonWidth())
                    }
                    .buttonStyle(PrimaryButtonStyle(fullWidth: false))
                    .padding(.top, 24)
                } else {
                    Button {
                        importDocumentButtonAction?()
                    } label: {
                        Text(UserText.importBookmarksActionHtmlTitle)
                    }
                    .buttonStyle(PrimaryButtonStyle(fullWidth: false))
                    .padding(.top, 24)
                }
            }
            .frame(maxWidth: 300.0)
            .padding(.top, 16)
    }

    private func maxButtonWidth() -> CGFloat {
        let maxWidth = AutofillViews.maxWidthFor(title1: UserText.autofillEmptyViewImportButtonTitle, title2: UserText.autofillEmptyViewImportViaSyncButtonTitle, font: UIFont.boldAppFont(ofSize: 15))
        return min(maxWidth, 300)
    }
}

#Preview {
    BookmarksEmptyView()
}
