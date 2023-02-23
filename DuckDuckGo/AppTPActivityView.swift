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
    
    private let relativeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter
    }()
    
    private let inputFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
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
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                Section {
                    AppTPToggleView()
                        .background(Color.cellBackground)
                        .cornerRadius(12)
                        .padding(.bottom)
                }
                
                ForEach(viewModel.sections, id: \.name) { section in
                    Section(content: {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(section.objects as? [AppTrackerEntity] ?? []) { tracker in
                                let showDivider = tracker != (section.objects?.last as? AppTrackerEntity)
                                AppTPTrackerCell(tracker: tracker, showDivider: showDivider)
                            }
                        }
                        .background(Color.cellBackground)
                        .cornerRadius(12)
                    }, header: {
                        Text(formattedDate(section.name))
                            .font(Font(uiFont: Const.Font.sectionHeader))
                            .foregroundColor(Color.trackerDomain)
                            .padding(.top)
                            .padding(.leading, 16)
                            .padding(.bottom, 6)
                    })
                }
            }
            .padding()
        }
        .background(Color.viewBackground)
        .navigationTitle(UserText.appTPNavTitle)
    }
}

struct AppTPTrackerCell: View {
    let tracker: AppTrackerEntity
    let showDivider: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                Image(systemName: "globe")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                
                VStack(alignment: .leading) {
                    Text(tracker.domain)
                        .font(Font(uiFont: Const.Font.trackerDomain))
                        .foregroundColor(.trackerDomain)
                    
                    Text("\(tracker.count) tracking attempts")
                        .font(Font(uiFont: Const.Font.trackerCount))
                        .foregroundColor(.trackerSize)
                }
            }
            .padding(.horizontal)
            .frame(height: Const.Size.rowHeight)
            
            if showDivider {
                Divider()
            }
        }
    }
}

private enum Const {
    enum Font {
        static let sectionHeader = UIFont.semiBoldAppFont(ofSize: 15)
        static let trackerDomain = UIFont.appFont(ofSize: 16)
        static let trackerCount = UIFont.appFont(ofSize: 13)
    }
    
    enum Size {
        static let rowHeight: CGFloat = 60
    }
}

private extension Color {
    static let trackerDomain = Color("AppTPDomainColor")
    static let trackerSize = Color("AppTPCountColor")
    static let cellBackground = Color("AppTPCellBackgroundColor")
    static let viewBackground = Color("AppTPViewBackgroundColor")
}
