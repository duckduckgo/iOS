//
//  OnboardingHomeRowViewController.swift
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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

import UIKit
import Core
import AVKit

class OnboardingHomeRowViewController: OnboardingContentViewController {
    
    @IBOutlet weak var videoContainerView: VideoContainerView!
    
    var layer: AVPlayerLayer?
    var player: AVPlayer?
    
    @IBOutlet weak var playButton: UIImageView!
    
    private var userInteracted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addVideo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didEnterBackground(notification:)),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil)
        startVideo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didEnterBackgroundNotification,
            object: nil)
    }
    
    override var header: String {
        return UserText.homeRowOnboardingHeader
    }
    
    override var continueButtonTitle: String {
        return UserText.onboardingStartBrowsing
    }
        
    override func onContinuePressed(navigationHandler: @escaping () -> Void) {
        navigationHandler()
    }
    
    @IBAction func playVideo() {
        guard let player = player else { return }
        
        if !userInteracted {
            userInteracted = true
            Pixel.fire(pixel: .homeRowInstructionsReplayed)
        }
        
        player.seek(to: CMTime(seconds: 0.0, preferredTimescale: player.currentTime().timescale))
        startVideo()
    }
    
    private func addVideo() {
        let movieURL: URL

        if #available(iOS 13, *) {
            movieURL = Bundle.main.url(forResource: "ios13-home-row", withExtension: "mp4")!
        } else {
            movieURL = Bundle.main.url(forResource: "ios12-home-row", withExtension: "mp4")!
        }

        player = AVPlayer(url: movieURL)
        _ = try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)

        layer = AVPlayerLayer(player: player)
        if let layer = layer {
            layer.videoGravity = .resizeAspect
            videoContainerView.layer.addSublayer(layer)
            layer.frame = videoContainerView.bounds
            videoContainerView.playerLayer = layer
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying(note:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player!.currentItem)
        
    }

    private func startVideo() {
        playButton.isHidden = true
        player?.play()
    }

    @objc func playerDidFinishPlaying(note: NSNotification) {
        HomeRowReminder().setShown()
        playButton.isHidden = false
    }
    
    @objc func didEnterBackground(notification: NSNotification) {
        Pixel.fire(pixel: .homeRowOnboardingMovedToBackground)
    }
    
    deinit {
        // swiftlint:disable unneeded_notification_center_removal
        NotificationCenter.default.removeObserver(self)
        // swiftlint:enable unneeded_notification_center_removal
    }
}

class VideoContainerView: UIView {
    var playerLayer: CALayer?

    override func layoutSublayers(of layer: CALayer) {
      super.layoutSublayers(of: layer)
      playerLayer?.frame = self.bounds
    }
}
