//
//  VideoPlayerViewModel.swift
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

import AVFoundation

@MainActor
final class VideoPlayerViewModel: ObservableObject {

    @Published private(set) var player: AVPlayer
    @Published private(set) var isPIPEnabled: Bool = false

    let url: URL

    private var playerLooper: AVPlayerLooper?

    var isLoopingVideo: Bool {
        playerLooper != nil
    }

    init(
        url: URL,
        loopVideo: Bool,
        player: AVQueuePlayer = AVQueuePlayer()
    ) {
        self.url = url
        self.player = player

        configureVideoPlayer()
        loadAsset(in: player, shouldLoopVideo: loopVideo)
    }

    func play() {
        player.play()
    }

    func pause() {
        player.pause()
    }

    func startPIP() {
        isPIPEnabled = true
    }

    func stopPIP() {
        isPIPEnabled = false
    }

}

// MARK: - Private

private extension VideoPlayerViewModel {

    func configureVideoPlayer() {
        // Let the application goes to sleep if needed when the video is playing. Set to false as we're not playing a movie.
        // If in the future we have cases where these values need to be different we can inject a configuration.
        player.preventsDisplaySleepDuringVideoPlayback = false
        // Disable playback video on external displays.
        player.allowsExternalPlayback = false
    }

    func loadAsset(in player: AVQueuePlayer, shouldLoopVideo: Bool) {
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        if shouldLoopVideo {
            playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)
        }
    }

}
