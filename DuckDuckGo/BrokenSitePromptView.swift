//
//  BrokenSitePromptView.swift
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

import SwiftUI
import DuckUI
import DesignResourcesKit

struct BrokenSitePromptView: View {

    let viewModel: BrokenSitePromptViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text(UserText.siteNotWorkingTitle).bold()
            Text(UserText.siteNotWorkingSubtitle)
            HStack {
                Spacer()
                Button(UserText.siteNotWorkingDismiss, action: viewModel.onDidDismiss)
                    .buttonStyle(GhostButtonStyle())
                    .fixedSize()
                Button(UserText.siteNotWorkingWebsiteIsBroken, action: viewModel.onDidSubmit)
                    .buttonStyle(PrimaryButtonStyle())
                    .fixedSize()
            }
        }
        .background(Color(designSystemColor: .background))
        .padding()
    }

}

#Preview {

    let viewModel = BrokenSitePromptViewModel(onDidDismiss: {},
                                              onDidSubmit: {})
    return BrokenSitePromptView(viewModel: viewModel)

}
