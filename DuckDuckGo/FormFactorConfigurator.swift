//
//  FormFactorConfigurator.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 22/07/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import Foundation
import Core

/// Core principle: tell, don't ask.  Other classes tell this class they want to be configured,
///  then this class tells them how and manage their own state if needed.
class FormFactorConfigurator {
    
    static let shared = FormFactorConfigurator()
    
    let variantManager: VariantManager
    
    var currentTraitCollection: UITraitCollection?
    
    var isPadFormFactor: Bool {
        return variantManager.isSupported(feature: .iPadImprovements) && currentTraitCollection?.horizontalSizeClass == .regular
    }
        
    /// Only use constructor when testing
    init(variantManager: VariantManager = DefaultVariantManager()) {
        self.variantManager = variantManager
    }
    
    func viewDidLoad(mainViewController: MainViewController) {
        print("***", #function, mainViewController.view.frame)
        guard variantManager.isSupported(feature: .iPadImprovements) else { return }
        
        apply(toMainViewController: mainViewController)
    }
    
    func traitCollectionDidChange(mainViewController: MainViewController, previousTraitCollection: UITraitCollection?) {
        print("***", #function, mainViewController.view.frame, previousTraitCollection as Any)
        guard variantManager.isSupported(feature: .iPadImprovements) else { return }
        
        if mainViewController.traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass {
            apply(toMainViewController: mainViewController)
        }

    }

    func layoutSubviews(mainViewController: MainViewController) {
        print("***", #function, mainViewController.view.frame)
        mainViewController.chromeManager.refresh()
    }
    
    private func apply(toMainViewController mainViewController: MainViewController) {
        print("***", #function, mainViewController.view.frame, mainViewController.traitCollection.horizontalSizeClass == .regular ? "pad" : "phone")

        currentTraitCollection = mainViewController.traitCollection
        
        // Form factor specific
        if isPadFormFactor {
            applyPad(toMainViewController: mainViewController)
        } else {
            applyPhone(toMainViewController: mainViewController)
        }
    }
    
    private func applyPad(toMainViewController mainViewController: MainViewController) {
        print("***", #function, mainViewController.view.frame)
        mainViewController.toolbar.isHidden = true
        mainViewController.omniBar.enterPadState()
    }

    private func applyPhone(toMainViewController mainViewController: MainViewController) {
        print("***", #function, mainViewController.view.frame)
        mainViewController.toolbar.isHidden = false
        mainViewController.omniBar.enterPhoneState()
    }

}
