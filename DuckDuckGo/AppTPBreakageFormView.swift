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

struct AppTPBreakageFormView: View {
    @Environment(\.presentationMode) var presentation
    
    @ObservedObject var feedbackModel: AppTrackingProtectionFeedbackModel
    
    @State private var appName: String = ""
    @State private var category: BreakageCategory = .appFreeze
    @State private var description: String = ""
    
    @State private var showError = false
    
    func sendReport() {
        if appName.isEmpty {
            showError = true
            return
        }
        
        feedbackModel.sendReport(appName: appName, category: category.rawValue, description: description)
        self.presentation.wrappedValue.dismiss()
    }
    
    var body: some View {
        ZStack {
            Form {
                Section {
                    TextField("App Name", text: $appName)
                } header: {
                    Text("Which app is broken?")
                        .font(Font(uiFont: Const.Font.sectionHeader))
                        .foregroundColor(.infoText)
                }
                .textCase(nil)
                
                Section {
                    Picker("What's happening?", selection: $category) {
                        ForEach(BreakageCategory.allCases) { cat in
                            Text(cat.rawValue)
                        }
                    }
                }
                
                if category == .somethingElse {
                    Section {
                        TextEditor(text: $description)
                    } header: {
                        Text("Please describe what's happening, what you expected to happen, and steps that led to the issue.")
                            .font(Font(uiFont: Const.Font.sectionHeader))
                            .foregroundColor(.infoText)
                    }
                    .textCase(nil)
                }
                
                Section {
                    Button(action: {
                        sendReport()
                    }, label: {
                        Text("Submit")
                            .font(Font(uiFont: Const.Font.button))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(Color("AppTPToggleColor"))
                    })
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
    }
}

private extension Color {
    static let infoText = Color("AppTPDomainColor")
    static let cellBackground = Color("AppTPCellBackgroundColor")
    static let viewBackground = Color("AppTPViewBackgroundColor")
}
