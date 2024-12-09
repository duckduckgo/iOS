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

struct VideoPlayerView: View {

    @ObservedObject private var model: VideoPlayerViewModel

    private var isPlaying: Binding<Bool>

    init(model: VideoPlayerViewModel, isPlaying: Binding<Bool> = .constant(true)) {
        self.model = model
        self.isPlaying = isPlaying
    }

    var body: some View {
        PlayerView(player: model.player)
            .foregroundColor(Color.red)
            .onChange(of: isPlaying.wrappedValue) { newValue in
                if newValue {
                    model.play()
                } else {
                    model.pause()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification), perform: { _ in
                isPlaying.wrappedValue = false
            })
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                isPlaying.wrappedValue = true
            }
    }

}

// MARK: - Private

// AVKit provides a SwiftUI view called VideoPlayer view to render AVPlayer.
// The issue is that is not possible to change the background/foreground color of the view so the default color is black.
// Using UIKit -> AVPlayerLayer solves the problem.
private struct PlayerView: UIViewRepresentable {

    private let player: AVPlayer

    init(player: AVPlayer) {
        self.player = player
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {
    }

    func makeUIView(context: Context) -> UIView {
        return PlayerUIView(player: player)
    }
}

private final class PlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()

    init(player: AVPlayer) {
        playerLayer.player = player
        super.init(frame: .zero)
        layer.addSublayer(playerLayer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}

// MARK: - Preview

struct VideoPlayerView_Previews: PreviewProvider {

    @MainActor
    struct VideoPlayerPreview: View {
        static let videoURL = Bundle.main.url(forResource: "add-to-dock-demo", withExtension: "mp4")!
        @State var isPlaying = false
        @State var model = VideoPlayerViewModel(url: Self.videoURL, loopVideo: true)

        var body: some View {
            VideoPlayerView(
                model: model,
                isPlaying: $isPlaying
            )
            .onAppear(perform: {
                isPlaying = true
            })
        }
    }

    static var previews: some View {
        VideoPlayerPreview()
            .preferredColorScheme(.light)
   }
}
