//
//  HomeRowInstructionsViewController.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 29/04/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import UIKit
import AVKit

class HomeRowInstructionsViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var button: UIButton!
    
    weak var layer: AVPlayerLayer?
    weak var player: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.blur(style: .dark)
        
        applyCorners()
        addVideo()
    }
    
    @IBAction func playVideo() {
        guard let player = player else { return }
        player.seek(to: CMTime(seconds: 0.0, preferredTimescale: player.currentTime().timescale))
        player.play()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startVideo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        HomeRowOnboardingFeature().dismissed()
        HomeRowReminderFeature().setShown()
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
        let movieURL = Bundle.main.url(forResource: "home-row-instructions", withExtension: "mp4")!
        player = AVPlayer(url: movieURL)
        layer = AVPlayerLayer(player: player)
        videoContainerView.layer.addSublayer(layer!)
        layer?.frame = videoContainerView.bounds
    }
    
    private func startVideo() {
        player?.play()
    }
    
}
