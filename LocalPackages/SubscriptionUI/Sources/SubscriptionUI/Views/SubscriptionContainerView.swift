//
//  SubscriptionContainerView.swift
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
import WebKit

// MARK: - WebView
struct InfoWebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Update the view if required.
    }
}

// MARK: - ContentView
struct ContainerView: View {
    var body: some View {
        NavigationView {
            VStack {
                // WebView Container
                InfoWebView(url: URL(string: "https://www.example.com")!)
                    .edgesIgnoringSafeArea(.all)
                
                // Footer
                HStack {
                    Button(action: {
                        // Action for monthly subscription
                    }) {
                        Text("$9.99 / month")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        // Action for yearly subscription
                    }) {
                        Text("$99.99 / year")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationBarTitle("Privacy Pro", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                // Action for closing the view
            }) {
                Image(systemName: "xmark")
            })
        }
    }
}

// MARK: - Preview
struct ContainerView_Previews: PreviewProvider {
    static var previews: some View {
        ContainerView()
    }
}
