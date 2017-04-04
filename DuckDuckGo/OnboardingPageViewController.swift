//
//  OnboardingPageViewController.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 03/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

class OnboardingPageViewController: UIViewController {
    
    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var pageDescription: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    var descriptionLineHeight: CGFloat = 0
    
    var configuration: OnboardingPageConfiguration!
    var isLastPage = false
    
    var preferredBackgroundColor: UIColor {
        return configuration.background
    }
    
    static func loadFromStoryboard(storyboard: UIStoryboard, withConfiguartion configuration: OnboardingPageConfiguration) -> OnboardingPageViewController {
        let controller = storyboard.instantiateViewController(withIdentifier: "OnboardingPageViewController") as! OnboardingPageViewController
        controller.configuration = configuration
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }
    
    private func configureViews() {
        pageTitle.text = configuration.title
        image.image = configuration.image
        pageDescription.text = configuration.description
        adjustLineHeight(descriptionLineHeight, forLabel: pageDescription)
    }
    
    public func scaleImage(_ scale: CGFloat) {
        image.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    
    public func resetImage() {
        image.transform = CGAffineTransform(scaleX: 1, y: 1)
    }
    
    private func adjustLineHeight(_ height: CGFloat, forLabel label: UILabel) {
        let paragaphStyle = NSMutableParagraphStyle()
        paragaphStyle.lineHeightMultiple = height
        paragaphStyle.alignment = label.textAlignment
        
        let attributes: [String: Any] = [
            NSFontAttributeName: label.font,
            NSForegroundColorAttributeName: label.textColor,
            NSParagraphStyleAttributeName: paragaphStyle
        ]
        label.attributedText = NSAttributedString(string: label.text!, attributes: attributes)
    }
}
