//
//  SubscriptionGoogleView.swift
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

import Foundation
import SwiftUI

struct SubscriptionGoogleView: View {
        
    enum Constants {
        static let padding: CGFloat = 20.0
    }
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(designSystemColor: .background)
                           .edgesIgnoringSafeArea(.all)
            VStack(alignment: .center) {
                Image("google-play").padding(.top, Constants.padding)
                
                Text(UserText.subscriptionManageBillingGoogleText)
                    .daxSubheadRegular()
                    .foregroundColor(Color(designSystemColor: .textSecondary))
                    .multilineTextAlignment(.center)
                    .padding(Constants.padding)
                Spacer()
            }
        }
        .navigationBarTitle(UserText.subscriptionManageBillingGoogleTitle, displayMode: .inline)
        .applyInsetGroupedListStyle()
    }
        
}


#if DEBUG
struct SubscriptionGoogleView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SubscriptionGoogleView().navigationBarTitleDisplayMode(.inline)
        }
    }
}
#endif
