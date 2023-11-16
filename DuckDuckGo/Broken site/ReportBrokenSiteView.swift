////
////  ReportBrokenSiteView.swift
////  DuckDuckGo
////
////  Copyright © 2023 DuckDuckGo. All rights reserved.
////
////  Licensed under the Apache License, Version 2.0 (the "License");
////  you may not use this file except in compliance with the License.
////  You may obtain a copy of the License at
////
////  http://www.apache.org/licenses/LICENSE-2.0
////
////  Unless required by applicable law or agreed to in writing, software
////  distributed under the License is distributed on an "AS IS" BASIS,
////  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
////  See the License for the specific language governing permissions and
////  limitations under the License.
////
//
// import SwiftUI
// import DuckUI
// import DesignResourcesKit
//
// struct ReportBrokenSiteView: View {
//    
//    let categories: [BrokenSite.Category]
//    let submitReport: (BrokenSite.Category?, String) -> Void
//    
//    @State private var selectedCategory: BrokenSite.Category?
//    
//    @State private var description: String = ""
//    @State private var placeholderText: String = UserText.brokenSiteCommentPlaceholder
//    
//    func submitForm() {
//        submitReport(selectedCategory, description)
//    }
//    
//    var form: some View {
//        Form {
//            Section {
//                
//            } header: {
//                VStack {
//                    Image("Breakage-128")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: Const.Size.imageSize, height: Const.Size.imageSize)
//                    
//                    Text(UserText.reportBrokenSiteHeader)
//                        .textCase(nil)
//                        .multilineTextAlignment(.center)
//                        .daxBodyRegular()
//                        .foregroundColor(Color(designSystemColor: .textSecondary))
//                }
//                .frame(maxWidth: .infinity)
//            }
//            .listRowBackground(Color.clear)
//            
//            Section {
//                HStack {
//                    Picker("", selection: $selectedCategory) {
//                        HStack {
//                            Text(UserText.brokenSiteCategoryPlaceholder)
//                            Spacer()
//                        }
//                        .tag(nil as BrokenSite.Category?)
//                        
//                        ForEach(categories) { cat in
//                            HStack {
//                                Text(cat.categoryText)
//                                Spacer()
//                            }
//                            .tag(Optional(cat))
//                        }
//                    }
//                    .labelsHidden()
//                    
//                    Spacer()
//                }
//                .padding(.leading, Const.Size.pickerPadding)
//            } header: {
//                Text(UserText.brokenSiteCategoryTitle)
//            }
//            
//            Section {
//                // As of July 2023 SwiftUI STILL does not support placeholders for `TextEditor`
//                // Until that time we have to use this hack to show a placeholder
//                // https://stackoverflow.com/a/65406506
//                ZStack {
//                    if self.description.isEmpty {
//                        TextEditor(text: $placeholderText)
//                            .font(.body)
//                            .foregroundColor(Color(UIColor.placeholderText))
//                            .disabled(true)
//                    }
//                    
//                    TextEditor(text: $description)
//                        .font(.body)
//                }
//                .padding(.leading, Const.Size.commentFieldPadding)
//                .frame(minHeight: Const.Size.minCommentHeight)
//            } header: {
//                Text(UserText.brokenSiteSectionTitle)
//            }
//            
//            Section {
//                Button(action: {
//                    submitForm()
//                }, label: {
//                    Text(UserText.appTPReportSubmit)
//                })
//                .buttonStyle(PrimaryButtonStyle())
//                .listRowBackground(Color.clear)
//            }
//            .listRowInsets(EdgeInsets())
//        }
//    }
//    
//    @ViewBuilder
//    var formWithBackground: some View {
//        if #available(iOS 16, *) {
//            form
//                .scrollContentBackground(.hidden)
//                .background(Color(designSystemColor: .background))
//        } else {
//            form
//                .background(Color(designSystemColor: .background))
//        }
//    }
//    
//    var body: some View {
//        formWithBackground
//    }
// }
//
// private enum Const {
//    enum Size {
//        static let imageSize: CGFloat = 128
//        static let minCommentHeight: CGFloat = 60
//        static let commentFieldPadding: CGFloat = -4
//        static let pickerPadding: CGFloat = -12
//        static let buttonHeight: CGFloat = 30
//    }
// }
//
// struct ReportBrokenSiteView_Previews: PreviewProvider {
//    static var previews: some View {
//        ReportBrokenSiteView(categories: BrokenSite.Category.allCases, submitReport: { _, _ in })
//    }
// }
