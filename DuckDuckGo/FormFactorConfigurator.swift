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
    var currentWidth: CGFloat?
    
    var isPadFormFactor: Bool {
        return variantManager.isSupported(feature: .iPadImprovements) && currentTraitCollection?.horizontalSizeClass == .regular
    }
        
    /// Only use constructor when testing
    init(variantManager: VariantManager = DefaultVariantManager()) {
        self.variantManager = variantManager
    }
    
    func viewDidLoad(mainViewController: MainViewController) {
        print("***", #function, mainViewController.view.frame)
        apply(toMainViewController: mainViewController)
    }
    
    func traitCollectionDidChange(mainViewController: MainViewController, previousTraitCollection: UITraitCollection?) {
        print("***", #function, mainViewController.view.frame, previousTraitCollection as Any)
        
        if mainViewController.traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass {
            apply(toMainViewController: mainViewController)
        }
        
    }

    func layoutSubviews(mainViewController: MainViewController) {
        print("***", #function, mainViewController.view.frame, mainViewController.view.traitCollection)

        // we're interested in the state after the layout
        DispatchQueue.main.async {
            let newWidth = mainViewController.view.frame.width
            if self.currentWidth != newWidth {
                print("***", #function, mainViewController.view.frame)
                self.currentWidth = newWidth
                mainViewController.tabsBarController?.refresh()
            }
        }

    }
    
    private func apply(toMainViewController mainViewController: MainViewController) {
        print("***", #function, mainViewController.view.frame, mainViewController.traitCollection.horizontalSizeClass == .regular ? "pad" : "phone")

        currentTraitCollection = mainViewController.traitCollection
        currentWidth = mainViewController.view.frame.width
        
        if isPadFormFactor {
            applyPad(toMainViewController: mainViewController)
        } else {
            applyPhone(toMainViewController: mainViewController)
        }

        mainViewController.applyTheme(ThemeManager.shared.currentTheme)

        print("***", #function, "navBarTop.constant", mainViewController.navBarTop.constant)
        DispatchQueue.main.async {
            print("***", #function, "navBarTop.constant", mainViewController.navBarTop.constant)
            // Do this async otherwise the toolbar buttons skew to the right
            if mainViewController.navBarTop.constant >= 0 {
                mainViewController.showBars()
            }

            // If tabs have been udpated, do this async to make sure size calcs are current
            mainViewController.tabsBarController?.refresh()

        }
    }
    
    private func applyPad(toMainViewController mainViewController: MainViewController) {
        print("***", #function, mainViewController.view.frame)
        mainViewController.tabsBar.isHidden = false
        mainViewController.toolbar.isHidden = true
        mainViewController.omniBar.enterPadState()
    }

    private func applyPhone(toMainViewController mainViewController: MainViewController) {
        print("***", #function, mainViewController.view.frame)
        mainViewController.tabsBar.isHidden = true
        mainViewController.toolbar.isHidden = false
        mainViewController.omniBar.enterPhoneState()
    }

}
