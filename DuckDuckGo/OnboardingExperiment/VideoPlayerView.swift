//
//  VideoPlayerView.swift
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
import AVFoundation
import AVKit

struct VideoPlayerView: View {
    
    @StateObject private var model: VideoPlayerViewModel

    init(
        url: URL,
        autoPlay: Bool = true,
        hidePlayerControls: Bool = true,
        loopVideo: Bool = false
    ) {
         let playerModel = VideoPlayerViewModel(
            url: url,
            autoPlay: autoPlay,
            hidePlayerControls: hidePlayerControls,
            loopVideo: loopVideo
         )
        _model = StateObject(wrappedValue: playerModel)
    }

    var body: some View {
        VideoPlayer(player: model.player)
            .disabled(model.hidePlayerControls) // Disable player controls
            .onFirstAppear {
                if model.autoPlay {
                    model.play()
                }
            }
            .onDisappear(perform: model.stop)
    }

}

@MainActor
final class VideoPlayerViewModel: ObservableObject {
    
    @Published private(set) var player: AVPlayer

    let url: URL
    let autoPlay: Bool
    let hidePlayerControls: Bool

    private var playerLooper: AVPlayerLooper?

    init(
        url: URL,
        autoPlay: Bool,
        hidePlayerControls: Bool,
        loopVideo: Bool
    ) {
        self.url = url
        self.autoPlay = autoPlay
        self.hidePlayerControls = hidePlayerControls
        let playerItem = AVPlayerItem(url: url)
        let player = AVQueuePlayer(playerItem: playerItem)
        if loopVideo {
            playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)
        }
        self.player = player
    }

    func play() {
        player.play()
    }

    func pause() {
        player.pause()
    }

    func stop() {
        player.replaceCurrentItem(with: nil)
    }

}

struct CornerRadiusViewModifier: ViewModifier {

    struct CornerRadiusShape: Shape {
        let cornerRadius: CGFloat
        let corners: UIRectCorner

        func path(in rect: CGRect) -> Path {
            Path(
                UIBezierPath(
                    roundedRect: rect,
                    byRoundingCorners: corners,
                    cornerRadii: .init(width: cornerRadius, height: cornerRadius)
                )
                .cgPath
            )
        }
    }

    let cornerRadius: CGFloat
    let corners: UIRectCorner

    func body(content: Content) -> some View {
        content.clipShape(CornerRadiusShape(cornerRadius: cornerRadius, corners: corners))
    }

}

extension View {

    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        self.modifier(CornerRadiusViewModifier(cornerRadius: radius, corners: corners))
    }

}


#Preview("Video Player") {
    let videoURL = Bundle.main.url(forResource: "demo", withExtension: "mp4")!

    return ZStack {
        Color.green
        VideoPlayerView(url: videoURL, loopVideo: true)
            .frame(width: 310, height: 234)
            .cornerRadius(37, corners: [.bottomLeft, .bottomRight])
    }
}

import Onboarding
import DuckUI
extension OnboardingView {

    struct AddToDockTutorialView: View {

        private let title: String
        private let message: String
        private var animateTitle: Binding<Bool>
        private var animateMessage: Binding<Bool>
        private var showCTA: Binding<Bool>
        private let action: () -> Void

        init(
            title: String,
            message: String,
            animateTitle: Binding<Bool> = .constant(true),
            animateMessage: Binding<Bool> = .constant(false),
            showCTA: Binding<Bool> = .constant(false),
            action: @escaping () -> Void
        ) {
            self.title = title
            self.message = message
            self.animateTitle = animateTitle
            self.animateMessage = animateMessage
            self.showCTA = showCTA
            self.action = action
        }

        var body: some View {
            VStack(spacing: 24.0) {
                AnimatableTypingText(title, startAnimating: animateTitle) {
                    withAnimation {
                        animateMessage.wrappedValue = true
                    }
                }
                .foregroundColor(.primary)
                .font(Font.system(size: 20, weight: .bold))

                AnimatableTypingText(message, startAnimating: animateMessage) {
                    withAnimation {
                        showCTA.wrappedValue = true
                    }
                }
                .foregroundColor(.primary)
                .font(Font.system(size: 16))

                VideoPlayerView(url: Bundle.main.url(forResource: "demo", withExtension: "mp4")!, loopVideo: true)
                    .frame(width: 310, height: 234)
                    .cornerRadius(37, corners: [.bottomLeft, .bottomRight])

                Button(action: action) {
                    Text(verbatim: "Start Browsing")
                }
                .buttonStyle(PrimaryButtonStyle())
                .visibility(showCTA.wrappedValue ? .visible : .invisible)
            }
        }

    }
}

 struct AddToDockTutorial_Previews: PreviewProvider {

     struct AddToDockPreview: View {
         let videoURL = Bundle.main.url(forResource: "demo", withExtension: "mp4")!
         @State var animateTitle = true
         @State var animateMessage = false
         @State var showCTA = false

         var body: some View {
             OnboardingView.AddToDockTutorialView(
                 title: "Adding me to your Dock is easy.",
                 message: "Find or search for the DuckDuckGo icon on your home screen. Then press and drag into place. That’s it!",
                 animateTitle: $animateTitle,
                 animateMessage: $animateMessage,
                 showCTA: $showCTA,
                 action: {}
             )
             .padding()
         }
     }

     static var previews: some View {
         AddToDockPreview()
             .preferredColorScheme(.dark)
    }
 }
