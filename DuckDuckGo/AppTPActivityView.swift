//
//  AppTPActivityView.swift
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
import Core

struct AppTPActivityView: View {
    @ObservedObject var viewModel: AppTrackingProtectionListModel
    
    @State var vpnOn: Bool = false
    
    let imageCache = AppTrackerImageCache()
    
    private let relativeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd"
        return formatter
    }()
    
    private let inputFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    func formattedDate(_ sectionName: String) -> String {
        guard let date = inputFormatter.date(from: sectionName) else {
            return "Invalid Date"
        }
        
        let relativeDate = relativeFormatter.string(from: date)
        if relativeDate.rangeOfCharacter(from: .decimalDigits) != nil {
            return dateFormatter.string(from: date)
        }
        
        return relativeDate
    }
    
    func imageForState() -> Image {
        return vpnOn ? Image("AppTPEmptyEnabled") : Image("AppTPEmptyDisabled")
    }
    
    func textForState() -> String {
        return vpnOn ? UserText.appTPEmptyEnabledInfo : UserText.appTPEmptyDisabledInfo
    }
    
    var emptyState: some View {
        VStack {
            imageForState()
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 128, height: 96)
                .padding(.bottom)
            
            Text(textForState())
                .multilineTextAlignment(.center)
                .font(Font(uiFont: Const.Font.info))
                .foregroundColor(.infoText)
        }
        .padding()
        .padding(.top)
    }
    
    var listState: some View {
        ForEach(viewModel.sections, id: \.name) { section in
            Section(content: {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(section.objects as? [AppTrackerEntity] ?? []) { tracker in
                        let showDivider = tracker != (section.objects?.last as? AppTrackerEntity)
                        AppTPTrackerCell(tracker: tracker,
                                         imageCache: imageCache,
                                         showDivider: showDivider)
                    }
                }
                .background(Color.cellBackground)
                .cornerRadius(Const.Size.cornerRadius)
            }, header: {
                HStack {
                    Text(formattedDate(section.name))
                        .font(Font(uiFont: Const.Font.sectionHeader))
                        .foregroundColor(.infoText)
                        .padding(.top)
                        .padding(.leading, Const.Size.sectionIndentation)
                        .padding(.bottom, Const.Size.sectionHeaderBottom)
                    
                    Spacer()
                }
            })
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .center, spacing: 0) {
                Section {
                    AppTPToggleView(vpnOn: $vpnOn)
                        .background(Color.cellBackground)
                        .cornerRadius(Const.Size.cornerRadius)
                        .padding(.bottom)
                }
                
                if viewModel.sections.count > 0 {
                    listState
                } else {
                    emptyState
                }
            }
            .padding()
        }
        .background(Color.viewBackground)
        .navigationTitle(UserText.appTPNavTitle)
    }
}

private enum Const {
    enum Font {
        static let sectionHeader = UIFont.semiBoldAppFont(ofSize: 15)
        static let info = UIFont.appFont(ofSize: 16)
    }
    
    enum Size {
        static let cornerRadius: CGFloat = 12
        static let sectionIndentation: CGFloat = 16
        static let sectionHeaderBottom: CGFloat = 6
    }
}

private extension Color {
    static let infoText = Color("AppTPDomainColor")
    static let cellBackground = Color("AppTPCellBackgroundColor")
    static let viewBackground = Color("AppTPViewBackgroundColor")
}
