//
//  ReportBrokenSiteViewController.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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
import SwiftUI
import BrowserServicesKit

class ReportBrokenSiteViewController: UIViewController {
    
//    enum ReportBrokenSiteSource {
//        case privacyDashboard
//        case
//    }
    
    public var brokenSiteInfo: BrokenSiteInfo?
    
    var privacyConfigurationManager: PrivacyConfigurationManaging?
    var contentBlockingManager: ContentBlockerRulesManager?
    private var reportView: ReportBrokenSiteView?
//    private let source:
    
    private let categories: [BrokenSite.Category] = {
        var categories = BrokenSite.Category.allCases
        categories = categories.filter { $0 != .other }
        categories = categories.shuffled()
        categories.append(.other)
        return categories
    }()
    
//    init(privacyConfigurationManager: PrivacyConfigurationManaging, contentBlockingManager: ContentBlockerRulesManager) {
//        super.init(
//        self.privacyConfigurationManager = privacyConfigurationManager
//        self.contentBlockingManager = contentBlockingManager
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyTheme(ThemeManager.shared.currentTheme)
        
        reportView = ReportBrokenSiteView(categories: categories,
                                          submitReport: submitForm(category:description:),
                                          toggleProtection: protectionSwitchChangeHandler(enabled:),
                                          isProtected: true) // TODO: here
        let hc = UIHostingController(rootView: reportView)
        
        self.addChild(hc)
        self.view.addSubview(hc.view)
        hc.didMove(toParent: self)
        
        hc.view.translatesAutoresizingMaskIntoConstraints = false
        hc.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        hc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        hc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        hc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        DispatchQueue.main.async {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func onClosePressed(sender: Any) {
        dismiss(animated: true)
    }
    
    func submitForm(category: BrokenSite.Category?, description: String) {
        brokenSiteInfo?.send(with: category?.rawValue, description: description)
        ActionMessageView.present(message: UserText.feedbackSumbittedConfirmation)
        dismiss(animated: true)
    }
    
    func protectionSwitchChangeHandler(enabled: Bool) {
        
        let domain = "" // TODO:
        guard let privacyConfigurationManager = privacyConfigurationManager,
              let contentBlockingManager = contentBlockingManager else {
            fatalError("Dependencies not configured")
        }
        
        let privacyConfiguration = privacyConfigurationManager.privacyConfig
        
        if enabled {
            privacyConfiguration.userEnabledProtection(forDomain: domain)
            ActionMessageView.present(message: UserText.messageProtectionEnabled.format(arguments: domain))
        } else {
            privacyConfiguration.userDisabledProtection(forDomain: domain)
            ActionMessageView.present(message: UserText.messageProtectionDisabled.format(arguments: domain))
        }
        
        contentBlockingManager.scheduleCompilation()
        
//        privacyDashboardController.didStartRulesCompilation()
        
//        Pixel.fire(pixel: enabled ? .privacyDashboardProtectionEnabled : .privacyDashboardProtectionDisabled)
    }
}

extension ReportBrokenSiteViewController: Themable {
    
    func decorate(with theme: Theme) {
        decorateNavigationBar(with: theme)
        
        /*
         navigationController?.navigationBar.barTintColor = theme.barBackgroundColor
         navigationController?.navigationBar.tintColor = theme.navigationBarTintColor
         
         var titleAttrs = navigationController?.navigationBar.titleTextAttributes ?? [:]
         titleAttrs[NSAttributedString.Key.foregroundColor] = theme.navigationBarTitleColor
         navigationController?.navigationBar.titleTextAttributes = titleAttrs
         
         if #available(iOS 15.0, *) {
             let appearance = UINavigationBarAppearance()
             appearance.shadowColor = .clear
             appearance.backgroundColor = theme.backgroundColor
             appearance.titleTextAttributes = titleAttrs

             navigationController?.navigationBar.standardAppearance = appearance
             navigationController?.navigationBar.scrollEdgeAppearance = appearance
         }
         */
        
        view.backgroundColor = UIColor(Color(designSystemColor: .surface))
    }
}
