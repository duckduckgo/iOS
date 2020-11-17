//
//  HomeRowInstructionsViewController.swift
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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

import UIKit
import AVKit
import Core

class HomeRowInstructionsViewController: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var playButton: UIImageView!

    var layer: AVPlayerLayer?
    var player: AVPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationCapturesStatusBarAppearance = true
        
        view.blur(style: .dark)

        applyCorners()
        addVideo()
    }

    @IBAction func playVideo() {
        guard let player = player else { return }

        player.seek(to: CMTime(seconds: 0.0, preferredTimescale: player.currentTime().timescale))
        startVideo()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startVideo()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        HomeRowReminder().setShown()
    }

    @IBAction func dismiss() {
        dismiss(animated: true)
    }

    private func applyCorners() {
        for view in [containerView, button] {
            view?.layer.cornerRadius = 5
            view?.layer.masksToBounds = true
        }
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
        videoContainerView.layer.addSublayer(layer!)
        layer?.frame = videoContainerView.bounds
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying(note:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player!.currentItem)
        
    }

    private func startVideo() {
        playButton.isHidden = true
        player?.play()
    }

    @objc func playerDidFinishPlaying(note: NSNotification) {
        playButton.isHidden = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
