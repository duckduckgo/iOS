//
//  AddToDockTutorialView.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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
import Onboarding
import DuckUI

private struct VideoPlayerFramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {}
}

struct AddToDockTutorialView: View {
    private static let videoSize = CGSize(width: 898.0, height: 680.0)
    private static let videoURL = Bundle.main.url(forResource: "add-to-dock-demo", withExtension: "mp4")!

    private let title: String
    private let message: String
    private let cta: String
    private let action: () -> Void

    @State private var animateTitle = true
    @State private var animateMessage = false
    @State private var showContent = false
    @State private var isPlaying: Bool = false
    @State private var videoPlayerWidth: CGFloat = 0.0
    @StateObject private var videoPlayerModel = VideoPlayerViewModel(url: Self.videoURL, loopVideo: true)

    init(
        title: String,
        message: String,
        cta: String,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.cta = cta
        self.action = action
    }

    var body: some View {
        VStack(spacing: 24.0) {
            AnimatableTypingText(title, startAnimating: $animateTitle) {
                withAnimation {
                    animateMessage = true
                }
            }
            .foregroundColor(.primary)
            .font(Font.system(size: 20, weight: .bold))
            
            AnimatableTypingText(message, startAnimating: $animateMessage) {
                withAnimation {
                    showContent = true
                }
            }
            .foregroundColor(.primary)
            .font(Font.system(size: 16))
            
            videoPlayer
                .visibility(showContent ? .visible : .invisible)
                .onChange(of: showContent) { newValue in
                    if newValue {
                        // Need to delay playing a video. If calling isPlaying too early the video won't play.
                        DispatchQueue.main.async {
                            isPlaying = true
                        }
                    }
                }
            
            Button(action: action) {
                Text(cta)
            }
            .buttonStyle(PrimaryButtonStyle())
            .visibility(showContent ? .visible : .invisible)
        }
        .onFrameUpdate(in: .global, using: VideoPlayerFramePreferenceKey.self) { rect in
            videoPlayerWidth = rect.width
        }
    }

    private var videoPlayer: some View {
        // Calculate the height of the video based on the width it takes maintaining its aspect ratio
        let heightRatio = videoPlayerWidth * (Self.videoSize.height / Self.videoSize.width)
        return VideoPlayerView(model: videoPlayerModel, isPlaying: $isPlaying)
            .frame(width: videoPlayerWidth, height: heightRatio)
    }

}

// MARK: - Preview

struct AddToDockTutorial_Previews: PreviewProvider {

    struct AddToDockPreview: View {

        var body: some View {
            AddToDockTutorialView(
                title: UserText.AddToDockOnboarding.Tutorial.title,
                message: UserText.AddToDockOnboarding.Tutorial.message,
                cta: UserText.AddToDockOnboarding.Buttons.startBrowsing,
                action: {}
            )
            .padding()
        }
    }

    static var previews: some View {
        AddToDockPreview()
            .preferredColorScheme(.light)
   }

}
