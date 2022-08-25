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
import DuckUI

struct AutofillLoginDetailsHeaderView: View {
    @ObservedObject var viewModel: AutofillLoginDetailsHeaderViewModel
    
    var body: some View {
        HStack(spacing: Constants.horizontalStackSpacing) {
            FaviconView(viewModel: FaviconViewModel(domain: viewModel.domain))
                .scaledToFit()
                .frame(width: Constants.imageSize, height: Constants.imageSize)
                .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: Constants.verticalStackSpacing) {
                Text(viewModel.title)
                    .font(Font.system(size: Constants.titleFontSize))
                    .foregroundColor(Color(.label))
                
                Text(viewModel.subtitle)
                    .font(Font.system(size: Constants.subtitleFontSize))
                    .foregroundColor(.gray50)
            }
            
            Spacer()
        }
        .frame(height: Constants.viewHeight)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
    }
}

extension AutofillLoginDetailsHeaderView {
    private struct Constants {
        static let imageSize: CGFloat = 32
        static let titleFontSize: CGFloat = 16
        static let subtitleFontSize: CGFloat = 13
        static let horizontalStackSpacing: CGFloat = 10
        static let verticalStackSpacing: CGFloat = 3
        static let viewHeight: CGFloat = 60
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
