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
import Combine

struct VideoPlayerView: View {

    @ObservedObject private var model: VideoPlayerViewModel

    private var isPlaying: Binding <Bool>

    init(model: VideoPlayerViewModel, isPlaying: Binding<Bool> = .constant(true)) {
        self.model = model
        self.isPlaying = isPlaying
    }

    var body: some View {
        PlayerView(model: model)
            .foregroundColor(Color.red)
            .onChange(of: isPlaying.wrappedValue) { newValue in
                if newValue {
                    model.play()
                } else {
                    model.pause()
                }
            }
    }

}

// MARK: - Private

// AVKit provides a SwiftUI view called VideoPlayer view to render AVPlayer.
// The issue is that is not possible to change the background/foreground color of the view so the default color is black.
// Using UIKit -> AVPlayerLayer solves the problem.
private struct PlayerView: UIViewRepresentable {
    private let model: VideoPlayerViewModel

    init(model: VideoPlayerViewModel) {
        self.model = model
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {
    }

    func makeUIView(context: Context) -> UIView {
        let view = PlayerUIView(player: model.player)
        context.coordinator.setController(view.playerLayer, isPIPEnabled: model.$isPIPEnabled.eraseToAnyPublisher())
        return view
    }

    func makeCoordinator() -> VideoPlayerCoordinator {
        VideoPlayerCoordinator(self)
    }
}

private class VideoPlayerCoordinator: NSObject, AVPictureInPictureControllerDelegate {
    private let playerView: PlayerView
    private var controller: AVPictureInPictureController?
    private var pictureInPictureCancellable: AnyCancellable?

    init(_ playerView: PlayerView) {
        print("~~~ VideoPlayerCoordinator init")
        self.playerView = playerView
        super.init()
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .moviePlayback, options: .mixWithOthers)
            try audioSession.setActive(true)
        } catch {
            print("~~~ Error setting AVAudioSession active: \(error)")
        }
    }

    deinit {
        try? AVAudioSession.sharedInstance().setActive(false)
        print("~~~ VideoPlayerCoordinator deinit")
    }

    func setController(_ playerLayer: AVPlayerLayer, isPIPEnabled: AnyPublisher<Bool, Never>) {
        controller = AVPictureInPictureController(playerLayer: playerLayer)
        controller?.canStartPictureInPictureAutomaticallyFromInline = true
        controller?.delegate = self

        pictureInPictureCancellable = isPIPEnabled.sink { [weak self] isPIPEnabled in
            if isPIPEnabled && self?.controller?.isPictureInPicturePossible == true {
                self?.controller?.startPictureInPicture()
            } else {
                self?.controller?.stopPictureInPicture()
            }
        }
    }

    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("~~~ Picture in Picture Started")
    }

    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("~~~ Picture in Picture Stopped")
    }

    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: any Error) {
        print("~~~ Picture in Picture Failed: \(error)")
    }
}

private final class PlayerUIView: UIView {
    let playerLayer = AVPlayerLayer()

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
