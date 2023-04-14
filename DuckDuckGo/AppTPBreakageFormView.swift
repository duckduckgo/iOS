//
//  AppTPBreakageFormView.swift
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

private enum BreakageCategory: String, CaseIterable, Identifiable {
    case appFreeze = "App freezes or crashes"
    case slowContent = "Content loads slowly"
    case messageDelivery = "Message delivery fails"
    case cantUploadFiles = "Can't upload or share files"
    case cantDownloadFiles = "Can't download files"
    case noConnection = "App has no connection"
    case cantConnectLocal = "Can't connect local device"
    case somethingElse = "Something else"
    
    var id: Self { self }
    
    /// Design spec says breakage categories should be shuffled but "Something else" should always be last
    static var allCases: [BreakageCategory] {
        var cases: [BreakageCategory] = [.appFreeze, .slowContent, .messageDelivery, .cantUploadFiles,
                                         .cantDownloadFiles, .noConnection, .cantConnectLocal].shuffled()
        cases.append(.somethingElse)
        return cases
    }
}

struct FontWithLineHeight: ViewModifier {
    let font: UIFont
    let lineHeight: CGFloat

    func body(content: Content) -> some View {
        content
            .font(Font(font))
            .lineSpacing(lineHeight - font.lineHeight)
            .padding(.vertical, (lineHeight - font.lineHeight) / 2)
    }
}

extension View {
    func fontWithLineHeight(font: UIFont, lineHeight: CGFloat) -> some View {
        ModifiedContent(content: self, modifier: FontWithLineHeight(font: font, lineHeight: lineHeight))
    }
}

struct AppTPBreakageFormView: View {
    @Environment(\.presentationMode) var presentation
    
    @ObservedObject var feedbackModel: AppTrackingProtectionFeedbackModel
    
    @State private var appName: String = ""
    @State private var category: BreakageCategory = .appFreeze
    @State private var description: String = ""
    @State private var placeholderText: String = "Add any more details" // TODO: Localize
    
    @State private var showError = false
    
    func sendReport() {
        if appName.isEmpty {
            showError = true
            return
        }
        
        feedbackModel.sendReport(appName: appName, category: category.rawValue, description: description)
        DispatchQueue.main.async {
            ActionMessageView.present(message: "Thank you! Feedback submitted.", // TODO: Localize
                                      presentationLocation: .withoutBottomBar)
        }
        self.presentation.wrappedValue.dismiss()
    }
    
    var body: some View {
        ZStack {
            Form {
                Section {
                    VStack {
                        AppTPBreakageFormHeaderView(text: "Which app is broken?")
                        
                        TextField("App Name", text: $appName)
                    }
                }
                
                Section {
                    VStack {
                        AppTPBreakageFormHeaderView(text: "What's happening?")
                        
                        HStack {
                            Picker("", selection: $category) {
                                ForEach(BreakageCategory.allCases) { cat in
                                    Text(cat.rawValue)
                                }
                            }
                            .labelsHidden()
                            
                            Spacer()
                        }
                        .padding(.leading, -12)
                    }
                }
                
                Section {
                    VStack {
                        AppTPBreakageFormHeaderView(text: "Comment")
                            .padding(.top, 8)
                        
                        ZStack {
                            if self.description.isEmpty {
                                TextEditor(text: $placeholderText)
                                    .font(.body)
                                    .foregroundColor(.gray)
                                    .disabled(true)
                            }
                            
                            TextEditor(text: $description)
                                .font(.body)
                                .opacity(self.description.isEmpty ? 0.25 : 1)
                        }
                        .padding(.leading, -4)
                    }
                    .frame(minHeight: 60)
                } footer: {
                    Text("""
In addition to the details entered into this form, your app issue report will contain:
- A list of trackers blocked in the last 10 minutes
- Whether App Tracking Protection is enabled
- Aggregate DuckDuckGo app diagnostics
""") // TODO: Localize
                    .fontWithLineHeight(font: Const.Font.footer, lineHeight: Const.Size.lineHeight)
                    .foregroundColor(.infoText)
                    .padding(.leading, Const.Size.sectionIndentation)
                    .padding(.top)
                }
                
                Section {
                    Button(action: {
                        sendReport()
                    }, label: {
                        Text("Submit")
                            .font(Font(uiFont: Const.Font.button))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(appName.isEmpty ? Color.disabledButtonLabel : Color.buttonLabelColor)
                    })
                    .listRowBackground(appName.isEmpty ? Color.disabledButton : Color.buttonColor)
                    .disabled(appName.isEmpty)
                }
            }
            .navigationTitle("Breakage Report")
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("Error"),
                    message: Text("Please enter which app on your device is broken."),
                    dismissButton: .default(Text("Ok"))
                )
            }
        }
    }
}

private enum Const {
    enum Font {
        static let sectionHeader = UIFont.semiBoldAppFont(ofSize: 15)
        static let button = UIFont.semiBoldAppFont(ofSize: 17)
        static let footer = UIFont.appFont(ofSize: 15)
    }
    
    enum Size {
        static let sectionIndentation: CGFloat = -6
        static let sectionHeaderBottom: CGFloat = 6
        static let lineHeight: CGFloat = 18
    }
}

private extension Color {
    static let infoText = Color("AppTPDomainColor")
    static let cellBackground = Color("AppTPCellBackgroundColor")
    static let viewBackground = Color("AppTPViewBackgroundColor")
    static let buttonColor = Color("AppTPBreakageButton")
    static let buttonLabelColor = Color("AppTPBreakageButtonLabel")
    static let disabledButton = Color("AppTPBreakageButtonDisabled")
    static let disabledButtonLabel = Color("AppTPBreakageButtonLabelDisabled")
}
