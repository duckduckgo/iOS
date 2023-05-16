//
//  MacBrowserWaitlistView.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import Waitlist
import DesignResourcesKit

struct MacBrowserWaitlistView: View {

    @EnvironmentObject var viewModel: WaitlistViewModel

    var body: some View {
        WaitlistDownloadBrowserContentView(platform: .mac) { action in
            Task { await viewModel.perform(action: action) }
        }
    }

}

// MARK: - Previews

private struct MacBrowserWaitlistView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            PreviewView("Mac Browser Beta") {
                WaitlistDownloadBrowserContentView(platform: .mac) { _ in }
            }

            if #available(iOS 15.0, *) {
                WaitlistDownloadBrowserContentView(platform: .mac) { _ in }
                    .previewInterfaceOrientation(.landscapeLeft)
            }
        }
    }
    
    private struct PreviewView<Content: View>: View {
        let title: String
        var content: () -> Content
        
        init(_ title: String, @ViewBuilder content: @escaping () -> Content) {
            self.title = title
            self.content = content
        }
        
        var body: some View {
            NavigationView {
                content()
                    .navigationTitle("DuckDuckGo Desktop App")
                    .navigationBarTitleDisplayMode(.inline)
                    .overlay(Divider(), alignment: .top)
            }
            .previewDisplayName(title)
        }
    }
}
