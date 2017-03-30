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
    var changesColor = true
    var isLastPage = false
    
    var preferredBackgroundColor: UIColor {
        return configuration.background
    }
    
    static func loadFromStoryboard(withConfiguartion configuration: OnboardingPageConfiguration, size: OnboardingViewSize) -> OnboardingPageViewController {
        let storyboardName = (size == .mini) ? "OnboardingMini" : "Onboarding"
        let storyboard = UIStoryboard.init(name: storyboardName, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "OnboardingPageViewController") as! OnboardingPageViewController
        controller.configuration = configuration
        controller.changesColor = (size == .fullScreen)
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
        refreshBackgroundColor()
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
    
    public func refreshBackgroundColor() {
        if changesColor {
            self.view.backgroundColor = preferredBackgroundColor
        }
    }
    
    public func animateBackground(fromColor: UIColor, toColor: UIColor) {
        if !changesColor {
            return
        }
        view.backgroundColor = fromColor
        UIView.animate(withDuration: 0.7) {
            self.view.backgroundColor = toColor
        }
    }
}
