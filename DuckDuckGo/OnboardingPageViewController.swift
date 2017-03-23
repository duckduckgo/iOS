//
//  OnboardingPageViewController.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 03/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit

class OnboardingPageViewController: UIViewController {
    
    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var pageDescription: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    var configuration: OnboardingPageConfiguration!
    var size: OnboardingViewSize!
    var isLastPage = false
    
    static func loadFromStoryboard(withConfiguartion configuration: OnboardingPageConfiguration, size: OnboardingViewSize) -> OnboardingPageViewController {
        let storyboard = UIStoryboard.init(name: "Onboarding", bundle: nil)
        let identifier = size == .mini ? "MiniOnboardingPageViewController" : "OnboardingPageViewController"
        let controller = storyboard.instantiateViewController(withIdentifier: identifier) as! OnboardingPageViewController
        controller.configuration = configuration
        controller.size = size
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }
    
    private func configureViews() {
        pageTitle.text = configuration.title
        pageDescription.text = configuration.description
        image.image = configuration.image
        if size == .fullScreen {
            view.backgroundColor = configuration.background
        }
    }
    
    public func performImageShrinkAnimation() {
        UIView.animate(withDuration: 0.4) {
            self.image.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }
    }
    
    public func performImageResetAnimation() {
        UIView.animate(withDuration: 0.4) {
            self.image.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
}
