//
//  AppTPAboutView.swift
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

import SwiftUI
import DesignResourcesKit

#if APP_TRACKING_PROTECTION

struct AppTPAboutView: View {
    var aboutBody: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Const.Size.stackSpacing) {
                Text(UserText.appTPAboutTitle)
                    .daxTitle3()
                
                Group {
                    Text(UserText.appTPAboutContent1)
                    + Text(UserText.appTPAboutContent2)
                        .fontWeight(.bold)
                    + Text(UserText.appTPAboutContent3)
                }
                .daxBodyRegular()
            }
            .frame(maxWidth: .infinity)
            .padding(Const.Size.stackPadding)
        }
        .navigationTitle(Text(UserText.appTPAboutNavTitle))
    }
    
    var body: some View {
        if #available(iOS 16, *) {
            aboutBody
                .scrollContentBackground(.hidden)
                .background(Color(designSystemColor: .background))
        } else {
            aboutBody
                .background(Color(designSystemColor: .background))
        }
    }
}

private enum Const {
    enum Size {
        static let stackSpacing: CGFloat = 10
        static let stackPadding: CGFloat = 24
    }
}

struct AppTPAboutView_Previews: PreviewProvider {
    static var previews: some View {
        AppTPAboutView()
    }
}

#endif
