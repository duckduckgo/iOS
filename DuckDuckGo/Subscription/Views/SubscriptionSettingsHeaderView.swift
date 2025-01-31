//
//  SubscriptionSettingsHeaderView.swift
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

struct SubscriptionSettingsHeaderView: View {

    enum HeaderState: Equatable {
        case subscribed
        case expired(_ details: String)
        case activating
        case trial
    }

    let state: HeaderState

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            switch state {
            case .expired:
                Image("PrivacyProHeaderAlert")
            default:
                Image("PrivacyProHeader")
            }
            Text(UserText.subscriptionTitle)
                .daxTitle2()
                .foregroundColor(Color(designSystemColor: .textPrimary))

            switch state {
            case .subscribed, .trial:
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color(designSystemColor: .alertGreen))
                        .frame(width: 8, height: 8)
                    Text(state == .subscribed ? UserText.subscriptionSubscribed : UserText.trialSubscription)
                        .daxBodyRegular()
                        .foregroundColor(Color(designSystemColor: .textSecondary))
                }
            case .expired(let details):
                Text(details)
                    .daxBodyRegular()
                    .foregroundColor(Color(designSystemColor: .textSecondary))
            case .activating:
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color(designSystemColor: .alertYellow))
                        .frame(width: 8, height: 8)
                    Text(UserText.settingsPProActivating)
                        .daxBodyRegular()
                        .foregroundColor(Color(designSystemColor: .textSecondary))
                }
                Text(UserText.settingsPProActivationPendingDescription)
                    .daxBodyRegular()
                    .foregroundColor(Color(designSystemColor: .textSecondary))
                    .padding(.top, 9)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

#Preview {
    VStack(spacing: 8) {
        SubscriptionSettingsHeaderView(state: .subscribed)
        SubscriptionSettingsHeaderView(state: .expired("Your subscription expired on April 20, 2027"))
        SubscriptionSettingsHeaderView(state: .activating)
    }
}
