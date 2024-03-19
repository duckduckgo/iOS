//
//  AsyncHeadlessWebView.swift
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

import Foundation
import WebKit
import UserScript
import SwiftUI
import DesignResourcesKit
import Core

struct AsyncHeadlessWebViewSettings {
    let bounces: Bool
    let javascriptEnabled: Bool
    let allowedDomains: [String]?
    let contentBlocking: Bool
    
    init(bounces: Bool = true,
         javascriptEnabled: Bool = true,
         allowedDomains: [String]? = nil,
         contentBlocking: Bool = true) {
        self.bounces = bounces
        self.javascriptEnabled = javascriptEnabled
        self.allowedDomains = allowedDomains
        self.contentBlocking = contentBlocking
    }
}

struct AsyncHeadlessWebView: View {
    @StateObject var viewModel: AsyncHeadlessWebViewViewModel

    var body: some View {
        GeometryReader { geometry in
            HeadlessWebView(
                userScript: viewModel.userScript,
                subFeature: viewModel.subFeature,
                settings: viewModel.settings,
                onScroll: { newPosition in
                    viewModel.updateScrollPosition(newPosition)
                },
                onURLChange: { newURL in
                    viewModel.url = newURL
                },
                onCanGoBack: { value in
                    viewModel.canGoBack = value
                },
                onCanGoForward: { value in
                    viewModel.canGoForward = value
                },
                onContentType: { value in
                    viewModel.contentType = value
                },
                onNavigationError: { value in
                    viewModel.navigationError = value
                },
                navigationCoordinator: viewModel.navigationCoordinator
            )
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}
