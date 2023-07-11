//
//  AppTPLinkButton.swift
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

struct AppTPLinkButton: View {
    
    let buttonText: String
    
    var body: some View {
        HStack {
            Text(buttonText)
                .daxBodyRegular()
                .foregroundColor(Color(designSystemColor: .accent))
                
            Spacer()
        }
        .padding(.horizontal)
        .frame(height: Const.Size.standardCellHeight)
    }
}

private enum Const {
    enum Size {
        static let standardCellHeight: CGFloat = 44
    }
}

struct AppTPLinkButton_Previews: PreviewProvider {
    static var previews: some View {
        AppTPLinkButton(buttonText: UserText.appTPManageTrackers)
    }
}

#endif
