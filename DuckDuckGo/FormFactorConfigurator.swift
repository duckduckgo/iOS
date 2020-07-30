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
    
    struct Constants {
        
        static let minPadWidth: CGFloat = 678
        
    }
    
    static let shared = FormFactorConfigurator()
    
    let variantManager: VariantManager
    
    var currentWidth: CGFloat = 0
    
    var isPadFormFactor: Bool {
        return variantManager.isSupported(feature: .iPadImprovements) && currentWidth >= Constants.minPadWidth
    }
        
    /// Only use constructor when testing
    init(variantManager: VariantManager = DefaultVariantManager()) {
        self.variantManager = variantManager
    }
    
    func willResize(mainViewController: MainViewController, toWidth width: CGFloat) {
        print("***", #function, width)
        
        if width != currentWidth {
            currentWidth = width
            apply(toMainViewController: mainViewController)
        }
        
    }
    
    func viewDidLoad(mainViewController: MainViewController) {
        print("***", #function, mainViewController.view.frame)
        willResize(mainViewController: mainViewController, toWidth: mainViewController.view.frame.width)
    }
        
    private func apply(toMainViewController mainViewController: MainViewController) {
        print("***", #function, mainViewController.view.frame, mainViewController.traitCollection.horizontalSizeClass == .regular ? "pad" : "phone")

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
        mainViewController.suggestionTrayController?.float(withWidth: mainViewController.omniBar.searchStackContainer.frame.width)
    }

    private func applyPhone(toMainViewController mainViewController: MainViewController) {
        print("***", #function, mainViewController.view.frame)
        mainViewController.tabsBar.isHidden = true
        mainViewController.toolbar.isHidden = false
        mainViewController.omniBar.enterPhoneState()
        mainViewController.suggestionTrayController?.fill()
    }

}
