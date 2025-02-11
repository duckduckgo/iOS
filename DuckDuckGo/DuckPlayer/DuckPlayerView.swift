//
//  DuckPlayerView.swift
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
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import SwiftUI
import Foundation
import DesignResourcesKit

struct DuckPlayerView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: DuckPlayerViewModel
    var webView: DuckPlayerWebView
    @Binding var isLargeDetent: Bool
    
    init(viewModel: DuckPlayerViewModel, webView: DuckPlayerWebView, isLargeDetent: Binding<Bool>) {
        self.webView = webView
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._isLargeDetent = isLargeDetent
    }
    
    enum Constants {
        static let headerHeight: CGFloat = 56
        static let iconSize: CGFloat = 32
        static let cornerRadius: CGFloat = 12
        static let horizontalPadding: CGFloat = 16
        static let videoAspectRatio: CGFloat = 9/16 // 16:9 in portrait
        static let daxLogoSize: CGFloat = 24.0
        static let daxLogo = "Home"
        static let bottomButtonHeight: CGFloat = 44
    }
    
    

    
    var body: some View {
        let _ = Logger.duckplayer.debug("DuckPlayerView body: description length = \(viewModel.videoDescription.count), isLargeDetent = \(isLargeDetent)")

        GeometryReader { geometry in
            ZStack {
                // Background
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Header
                    header
                        .frame(height: Constants.headerHeight)
                    
                    // Video Container
                    let videoHeight = (geometry.size.width - (Constants.horizontalPadding * 2)) * Constants.videoAspectRatio
                    ZStack {
                        RoundedRectangle(cornerRadius: Constants.cornerRadius)
                            .fill(Color.black)
                            .overlay(
                                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                                    .stroke(Color(designSystemColor: .background).opacity(0.1), lineWidth: 1)
                            )
                        webView.clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
                    }
                    .frame(
                        width: geometry.size.width - (Constants.horizontalPadding * 2),
                        height: videoHeight
                    )
                    .padding(.horizontal, Constants.horizontalPadding)
                    
                    // Description Section
                    ZStack(alignment: .bottom) {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 0) {
                                if viewModel.videoDescription.isEmpty {
                                    Text("Loading video description...")
                                        .daxBodyRegular()
                                        .foregroundColor(.gray)
                                        .padding(.top, 16)
                                } else {
                                    // Display markdown description with clickable links
                                    Text(.init(viewModel.videoDescription))
                                        .daxSubheadRegular()
                                        .foregroundColor(.white.opacity(0.84))
                                        .tint(Color(designSystemColor: .accent))
                                        .environment(\.openURL, OpenURLAction { url in
                                            viewModel.handleYouTubeNavigation(url)
                                            return .handled
                                        })
                                    .padding(.vertical, 16)
                                }
                            }
                            .padding(.horizontal, Constants.horizontalPadding)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Gradient overlay
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0),
                                Color.black.opacity(0.1),
                                Color.black.opacity(0.2),
                                Color.black.opacity(0.5),
                                Color.black.opacity(0.8),
                                Color.black
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 60)
                        .opacity(isLargeDetent ? 0 : 1)
                        .animation(.easeInOut, value: isLargeDetent)
                    }
                    .background(Color(designSystemColor: .surface))
                    .colorScheme(.dark)
                    .cornerRadius(10)
                    .padding(16)
            

                }
            }
        }
        .onFirstAppear {
            viewModel.onFirstAppear()
        }
        .onAppear {
            viewModel.onAppear()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
    }
    
    var header: some View {
        HStack(spacing: 0) {
            // Left side with logo and title
            HStack(spacing: 8) {
                Image(Constants.daxLogo)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Constants.daxLogoSize, height: Constants.daxLogoSize)
                
                Text(UserText.duckPlayerFeatureName)
                    .foregroundColor(.white)
                    .font(.headline)
            }
            
            Spacer()
            
            // Right side with YouTube and close buttons
            HStack(spacing: 4) {
                if viewModel.shouldShowYouTubeButton {
                    Button {
                        viewModel.openInYouTube()
                    } label: {
                        Image("youtube.logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 44, height: 30)
                        
                    }
                }
                
                // Close Button
                Button(action: { dismiss() }, label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .medium))
                        .frame(width: 40, height: 44)
                })
            }
        }
        .padding(.horizontal, Constants.horizontalPadding)
        .background(Color.black)
    }
}
