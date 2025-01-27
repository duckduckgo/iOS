//
//  DuckPlayerView.swift
//  DuckDuckGo
//
//  Copyright 2025 DuckDuckGo. All rights reserved.
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
import Foundation
import DesignResourcesKit
import WebKit

struct DuckPlayerView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: DuckPlayerViewModel
    
    enum Constants {
        static let headerHeight: CGFloat = 56
        static let iconSize: CGFloat = 32
        static let cornerRadius: CGFloat = 12
        static let horizontalPadding: CGFloat = 16
        static let videoAspectRatio: CGFloat = 9/16 // 16:9 in portrait
        static let daxLogoSize: CGFloat = 24.0
        static let daxLogo = "Home"
    }
    
    
    var body: some View {
        ZStack {
            // Background
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header
                header
                    .frame(height: Constants.headerHeight)
                
                // Video Container
                GeometryReader { geometry in
                    ZStack {
                        RoundedRectangle(cornerRadius: Constants.cornerRadius)
                            .fill(Color.black)
                            .overlay(
                                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                                    .stroke(Color(designSystemColor: .background).opacity(0.1), lineWidth: 1)
                            )
                        
                        // WebView
                        WebView(url: URL(string: "https://www.youtube-nocookie.com/embed/\(viewModel.videoID)?playsinline=1&autoplay=1&rel=0&modestbranding=1&rel=0")!)
                            .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
                    }
                    .frame(
                        width: geometry.size.width - (Constants.horizontalPadding * 2),
                        height: (geometry.size.width - (Constants.horizontalPadding * 2)) * Constants.videoAspectRatio
                    )
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height / 2
                    )
                }
                
                Spacer()
            }
        }
        .onFirstAppear {
            viewModel.onFirstAppear()
        }
    }
    
    private var header: some View {
        HStack(spacing: Constants.horizontalPadding) {
            
            HStack {
                Image(Constants.daxLogo)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Constants.daxLogoSize, height: Constants.daxLogoSize)
                
                Text("Duck Player")
                    .foregroundColor(.white)
                    .font(.headline)
                
                Spacer()
            }
            
            // Close Button
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .medium))
                    .frame(width: 44, height: 44) // Larger touch target
            }
        }
        .padding(.horizontal, Constants.horizontalPadding)
        .background(Color.black)
    }
}

// WebView wrapper for WKWebView
struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.backgroundColor = .black
        webView.isOpaque = false
        webView.scrollView.backgroundColor = .black
        webView.scrollView.bounces = false
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
