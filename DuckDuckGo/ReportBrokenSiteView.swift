//
//  ReportBrokenSiteView.swift
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
import DuckUI
import DesignResourcesKit

struct ReportBrokenSiteView: View {
    
    let categories: [BrokenSite.Category]
    let submitReport: (BrokenSite.Category?, String) -> Void
    let toggleProtection: (Bool) -> Void
    @State private var selectedCategory: BrokenSite.Category?
    
    @State private var description: String = ""
    @State private var placeholderText: String = UserText.brokenSiteCommentPlaceholder
    
    @State var isProtected: Bool
    
    func submitForm() {
        submitReport(selectedCategory, description)
    }
    
    var form: some View {
        Form {
            
            Section {
                HStack {
                    let protectionStatusString = isProtected ? "ON" : "OFF"
                    let label = UserText.brokenSiteProtectionSwitchLabel.replacingOccurrences(of: "%@", with: protectionStatusString)
                    
                    Text(label)
                        .lineLimit(1)
                        .daxBodyRegular()
                        .foregroundColor(Color(designSystemColor: .textPrimary))
                    
                    Spacer()
                    
                    Toggle("", isOn: $isProtected)
                    .labelsHidden()
                    .onChange(of: isProtected) { value in
                        toggleProtection(value)
                    }
                }
                .listRowBackground(Color(designSystemColor: .container))
//                .frame(maxWidth: .infinity)
                
                if isProtected {
                    let baseColor = UIColor(Color(designSystemColor: .accent)).withAlphaComponent(0.18)
                    let sectionBgColor = Color(baseColor)
                    Text(UserText.brokenSiteProtectionBanner)
                        .lineLimit(1)
                        .daxBodyRegular()
                        .foregroundColor(Color(designSystemColor: .textPrimary))
                        .listRowBackground(sectionBgColor)
                }
            }
            
//            Section {
                VStack {
                    Image("Breakage-128")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Const.Size.imageSize, height: Const.Size.imageSize)
                    
                    Text(UserText.reportBrokenSiteHeader)
                        .textCase(nil)
                        .multilineTextAlignment(.center)
                        .daxBodyRegular()
                        .foregroundColor(Color(designSystemColor: .textPrimary))
                }
                .frame(maxWidth: .infinity)
//            }
//            .listRowBackground(Color.clear)
            
            // TODO: delete (header: Text(UserText.brokenSiteCategoryTitle))
            Section {
                Picker("", selection: $selectedCategory) {
                    Text("Select the type of issue")
                        .tag(nil as BrokenSite.Category?)
                    
                    ForEach(categories) { cat in
                        Text(cat.categoryText)
                        .tag(Optional(cat))
                    }
                }
                .frame(maxWidth: .infinity)
                .labelsHidden()
//                                .padding(.leading, Const.Size.pickerPadding)
                
                // As of July 2023 SwiftUI STILL does not support placeholders for `TextEditor`
                // Until that time we have to use this hack to show a placeholder
                // https://stackoverflow.com/a/65406506
                ZStack {
                    if self.description.isEmpty {
                        TextEditor(text: $placeholderText)
                            .daxSubheadRegular()
                            .foregroundColor(Color(UIColor.placeholderText))
                            .disabled(true)
                    }
                    
                    TextEditor(text: $description)
                        .daxSubheadRegular()
                }
                .padding(.leading, Const.Size.commentFieldPadding)
                .frame(minHeight: Const.Size.minCommentHeight)
            }
            .frame(maxWidth: .infinity)
            .listRowBackground(Color(designSystemColor: .container))
            
            // TODO: delete (header: Text(UserText.brokenSiteSectionTitle))
//            Section {
//                // As of July 2023 SwiftUI STILL does not support placeholders for `TextEditor`
//                // Until that time we have to use this hack to show a placeholder
//                // https://stackoverflow.com/a/65406506
//                ZStack {
//                    if self.description.isEmpty {
//                        TextEditor(text: $placeholderText)
//                            .daxSubheadRegular()
//                            .foregroundColor(Color(UIColor.placeholderText))
//                            .disabled(true)
//                    }
//                    
//                    TextEditor(text: $description)
//                        .daxSubheadRegular()
//                }
//                .padding(.leading, Const.Size.commentFieldPadding)
//                .frame(minHeight: Const.Size.minCommentHeight)
//            }
//            .listRowBackground(Color(designSystemColor: .container))
            
            Section {
                Button(action: {
                    submitForm()
                }, label: {
                    Text(UserText.appTPReportSubmit)
                })
                .buttonStyle(PrimaryButtonStyle())
                .listRowBackground(Color.clear)
            }
            .listRowInsets(EdgeInsets())
            
            Section {
                Text("Reports sent to DuckDuckGo only include info required to help us address your feedback.")
                    .multilineTextAlignment(.center)
                    .daxSubheadRegular()
                    .foregroundColor(Color(designSystemColor: .textPrimary))
            }
            .frame(maxWidth: .infinity)
            .listRowInsets(EdgeInsets())
        }
    }
    
    @ViewBuilder
    var formWithBackground: some View {
        if #available(iOS 16, *) {
            form
                .scrollContentBackground(.hidden)
                .background(Color(designSystemColor: .surface))
        } else {
            form
                .background(Color(designSystemColor: .background))
        }
    }
    
    var body: some View {
        formWithBackground
    }
}

private enum Const {
    enum Size {
        static let imageSize: CGFloat = 128
        static let minCommentHeight: CGFloat = 80
        static let commentFieldPadding: CGFloat = -4
        static let pickerPadding: CGFloat = -12
        static let buttonHeight: CGFloat = 30
    }
}

struct ReportBrokenSiteView_Previews: PreviewProvider {
    static var previews: some View {
        ReportBrokenSiteView(categories: BrokenSite.Category.allCases, submitReport: { _, _ in }, toggleProtection: { _ in }, isProtected: true)
    }
}
