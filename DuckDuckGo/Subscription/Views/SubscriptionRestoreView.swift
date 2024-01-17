//
//  SubscriptionRestoreView.swift
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
import DesignResourcesKit

#if SUBSCRIPTION
@available(iOS 15.0, *)
struct SubscriptionRestoreView: View {
    
    @ObservedObject var viewModel: SubscriptionRestoreViewModel
    @State private var expandedItemId: Int = 0
    
    private enum Constants {
        static let heroImage = "SyncTurnOnSyncHero"
        static let appleIDIcon = "Platform-Apple-16"
        static let emailIcon = "Email-16"
        static let headerLineSpacing = 10.0
        static let openIndicator = "chevron.up"
        static let closedIndicator = "chevron.down"
        static let buttonCornerRadius = 8.0
        static let buttonInsets = EdgeInsets(top: 10.0, leading: 16.0, bottom: 10.0, trailing: 16.0)
        static let cellLineSpacing = 12.0
        static let cellPadding = 4.0
        static let headerPadding = EdgeInsets(top: 16.0, leading: 16.0, bottom: 0, trailing: 16.0)
    }
    
    private var listItems: [ListItem] {
        [
            .init(id: 0,
                  content: getCellTitle(icon: Constants.appleIDIcon,
                                        text: "Apple ID"),
                  expandedContent: getCellContent(description: "Restore your purchase to activate your subscription on this device.",
                                                  buttonText: "Restore",
                                                  buttonAction: {})),
            .init(id: 1,
                  content: getCellTitle(icon: Constants.emailIcon,
                                        text: "Email"),
                  expandedContent: getCellContent(description: "Use your email to activate your subscription on this device.",
                                                  buttonText: "Enter Email",
                                                  buttonAction: {})),
            
        ]
    }
    
    private func getCellTitle(icon: String, text: String) -> AnyView {
        AnyView(
            HStack {
                Image(icon)
                Text(text)
                    .daxBodyRegular()
                    .foregroundColor(Color(designSystemColor: .textPrimary))
            }
        )
    }
    
    private func getCellContent(description: String, buttonText: String, buttonAction: @escaping () -> Void) -> AnyView {
        AnyView(
            VStack(alignment: .leading) {
                Text(description)
                    .daxSubheadRegular()
                    .foregroundColor(Color(designSystemColor: .textSecondary))
                getCellButton(buttonText: buttonText, action: buttonAction)
            }
        )
    }
    
    private func getCellButton(buttonText: String, action: @escaping () -> Void) -> AnyView {
        AnyView(
            Button(action: action, label: {
                Text(buttonText)
                    .daxButton()
                    .padding(Constants.buttonInsets)
                    .foregroundColor(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: Constants.buttonCornerRadius)
                            .stroke(Color.clear, lineWidth: 1)
                    )
            })
            .background(Color(designSystemColor: .accent))
            .cornerRadius(Constants.buttonCornerRadius)
            .padding(.top, Constants.cellPadding)
        )
    }
                                            
    
    struct ListItem {
        let id: Int
        let content: AnyView
        let expandedContent: AnyView
    }
    
    var body: some View {
        VStack {
            VStack(spacing: Constants.headerLineSpacing) {
                Image(Constants.heroImage)
                Text("Activate your subscription on this device")
                    .daxHeadline()
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(designSystemColor: .textPrimary))
                Text("Access your Privacy Pro subscription on this device via Apple ID or an email address.")
                    .daxFootnoteRegular()
                    .foregroundColor(Color(designSystemColor: .textSecondary))
                    .multilineTextAlignment(.center)
            }
            .padding(Constants.headerPadding)
            List {
                Section {
                    ForEach(Array(zip(listItems.indices, listItems)), id: \.1.id) { _, item in
                        VStack(alignment: .leading, spacing: Constants.cellLineSpacing) {
                            HStack {
                                item.content
                                Spacer()
                                Image(systemName: expandedItemId == item.id ? Constants.openIndicator : Constants.closedIndicator)
                                    .foregroundColor(Color(designSystemColor: .textPrimary))
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                expandedItemId = expandedItemId == item.id ? 0 : item.id
                            }
                            if expandedItemId == item.id {
                                item.expandedContent
                            }
                        }.padding(Constants.cellPadding)
                    }
                }
            }
        }.background(Color(designSystemColor: .container))
    }
}

@available(iOS 15.0, *)
struct SubscriptionRestoreView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionRestoreView(viewModel: SubscriptionRestoreViewModel())
    }
}
#endif
