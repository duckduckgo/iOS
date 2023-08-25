//
//  AutofillLoginDetailsHeaderView.swift
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

import SwiftUI
import DesignResourcesKit

struct AutofillLoginDetailsHeaderView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var viewModel: AutofillLoginDetailsHeaderViewModel
    
    var body: some View {
        HStack(spacing: Constants.horizontalStackSpacing) {
            FaviconView(viewModel: FaviconViewModel(domain: viewModel.domain,
                                                    cacheType: .fireproof,
                                                    preferredFakeFaviconLetters: viewModel.preferredFakeFaviconLetters))
                .scaledToFit()
                .frame(width: Constants.imageSize, height: Constants.imageSize)
                .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: Constants.verticalStackSpacing) {
                Text(viewModel.title)
                    .font(.callout)
                    .foregroundColor(colorScheme == .light ? .gray90 : .white)
                    .truncationMode(.middle)
                    .lineLimit(1)

                Text(viewModel.subtitle)
                    .font(.footnote)
                    .foregroundColor(colorScheme == .light ? .gray50 : .gray20)
            }
            
            Spacer()
        }
        .frame(minHeight: Constants.viewHeight)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .listRowBackground(Color(designSystemColor: .surface))
        .listRowInsets(Constants.insets)
    }
}

extension AutofillLoginDetailsHeaderView {
    private struct Constants {
        static let imageSize: CGFloat = 32
        static let horizontalStackSpacing: CGFloat = 12
        static let verticalStackSpacing: CGFloat = 1
        static let viewHeight: CGFloat = 60
        static let insets = EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
    }
}

struct ImageTitleSubtitleListItemView_Previews: PreviewProvider {
    static var previews: some View {
        let mockModel = AutofillLoginDetailsHeaderViewModel()
        mockModel.title = "Title"
        mockModel.subtitle = "Subtitle"
        return AutofillLoginDetailsHeaderView(viewModel: mockModel)
    }
}
