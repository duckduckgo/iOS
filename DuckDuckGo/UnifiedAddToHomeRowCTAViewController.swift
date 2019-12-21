//
//  UnifiedAddToHomeRowCTAViewController.swift
//  DuckDuckGo
//
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
//

import UIKit
import Core
import AVKit

class UnifiedAddToHomeRowCTAViewController: UIViewController {
    
    struct Constants {
        static let appearanceAnimationDuration = 0.5
    }

    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var infoView: UIView!
    
    @IBOutlet weak var videoContainerView: VideoContainerView!
    @IBOutlet weak var videoContainerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var videoContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var playButton: UIImageView!
    
    @IBOutlet weak var primaryText: UILabel!
    @IBOutlet weak var secondaryText: UILabel!
    
    @IBOutlet weak var gotItButton: UIButton!

    private var shown = false
    
    var layer: AVPlayerLayer?
    var player: AVPlayer?
    
    private var userInteracted = false

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureForFirstAppearance()
        
        addVideo()
        
        addObservers()
        
        applyTheme(ThemeManager.shared.currentTheme)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateOnFirstAppearance()
        startVideo()
    }

    @IBAction func gotItButtonPressed() {
        Pixel.fire(pixel: .homeRowCTAGotItTapped)
        dismiss()
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

    @objc func onKeyboardWillShow(notification: NSNotification) {
        UIView.animate(withDuration: notification.keyboardAnimationDuration()) {
            self.view.alpha = 0.0
        }
    }

    @objc func onKeyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: notification.keyboardAnimationDuration()) {
            self.view.alpha = 1.0
        }
    }

    private func configureViews() {
        gotItButton.layer.cornerRadius = 4
        gotItButton.layer.masksToBounds = true
    }

    private func configureForFirstAppearance() {
        blurView.alpha = 0.0
        infoView.transform = CGAffineTransform(translationX: 0, y: infoView.frame.size.height + CGFloat(#imageLiteral(resourceName: "HomeRowAppIcon").cgImage?.height ?? 0))
    }

    private func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onKeyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onKeyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    private func animateOnFirstAppearance() {
        guard !shown else { return }
        shown = true
        UIView.animate(withDuration: Constants.appearanceAnimationDuration) {
            self.blurView.alpha = 1.0
            self.infoView.transform = CGAffineTransform.identity
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func dismiss() {
        HomeRowCTA().dismissed()
        UIView.animate(withDuration: Constants.appearanceAnimationDuration, animations: {
            self.configureForFirstAppearance()
        }, completion: { _ in
            self.view.removeFromSuperview()
            self.removeFromParent()
        })
    }
    
    static func loadFromStoryboard() -> UnifiedAddToHomeRowCTAViewController {
        let sb = UIStoryboard(name: "HomeRow", bundle: nil)
        guard let controller = sb.instantiateViewController(withIdentifier: "UnifiedHomeRowCTA") as? UnifiedAddToHomeRowCTAViewController else {
            fatalError("Failed to load view controller for HomeRowCTA")
        }
        return controller
    }
    
    static func loadAlertFromStoryboard() -> UnifiedAddToHomeRowCTAViewController {
        let sb = UIStoryboard(name: "HomeRow", bundle: nil)
        guard let controller = sb.instantiateViewController(withIdentifier: "UnifiedHomeRowCTAAlert") as? UnifiedAddToHomeRowCTAViewController else {
            fatalError("Failed to load view controller for HomeRowCTA")
        }
        return controller
    }
}

extension UnifiedAddToHomeRowCTAViewController: Themable {
    
    func decorate(with theme: Theme) {
        infoView.backgroundColor = theme.homeRowBackgroundColor
        primaryText.textColor = theme.homeRowPrimaryTextColor
        secondaryText.textColor = theme.homeRowSecondaryTextColor
        videoContainerView.backgroundColor = UIColor.nearlyWhiteLight
    }
}

class VideoContainerView: UIView {
    var playerLayer: CALayer?
    
    override func layoutSublayers(of layer: CALayer) {
      super.layoutSublayers(of: layer)
      playerLayer?.frame = self.bounds
    }
}

fileprivate extension NSNotification {

    func keyboardAnimationDuration() -> Double {
        let defaultDuration = 0.3
        let duration = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? defaultDuration
        // the animation duration in userInfo could be 0, so ensure we always have some animation
        return min(duration, defaultDuration)
    }

}
