//
//  AIChatDebugView.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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
import Combine
import AIChat

struct AIChatDebugView: View {
    @StateObject private var viewModel = AIChatDebugViewModel()

    var body: some View {
        List {
            Section(footer: Text("Stored Hostname: \(viewModel.enteredHostname)")) {
                NavigationLink(destination: AIChatDebugHostnameEntryView(viewModel: viewModel)) {
                    Text("Message policy hostname")
                }
            }
        }
        .navigationTitle("AI Chat")
    }
}

private final class AIChatDebugViewModel: ObservableObject {
    private var debugSettings = AIChatDebugSettings()

    @Published var enteredHostname: String {
        didSet {
            debugSettings.messagePolicyHostname = enteredHostname
        }
    }

    init() {
        self.enteredHostname = debugSettings.messagePolicyHostname ?? ""
    }

    func resetHostname() {
        enteredHostname = ""
    }
}

private struct AIChatDebugHostnameEntryView: View {
    @ObservedObject var viewModel: AIChatDebugViewModel
    @State private var policyHostname: String = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            Section {
                TextField("Hostname", text: $policyHostname)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
            }
            Button {
                viewModel.enteredHostname = policyHostname
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Confirm")
            }

            Button {
                viewModel.resetHostname()
                policyHostname = ""
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Reset")
            }
        }
        .navigationTitle("Edit Hostname")
        .onAppear {
            policyHostname = viewModel.enteredHostname
        }
    }
}

#Preview {
    AIChatDebugView()
}
