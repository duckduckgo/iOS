//
//  NewPrivacyDashboardViewController.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import WebKit
import Combine
import Core
import PrivacyDashboard

class NewPrivacyDashboardViewController: UIViewController {
    
    var webView: WKWebView!
    
    private let privacyDashboardLogic: PrivacyDashboardLogic
//    private var isLoaded: Bool = false

    public init(privacyInfo: PrivacyInfo?) {
        self.privacyDashboardLogic = PrivacyDashboardLogic(privacyInfo: privacyInfo)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

//        extendedLayoutIncludesOpaqueBars = true
//        isModalInPresentation = true
        navigationController?.setNavigationBarHidden(true, animated: false)

        setupWebView()
        setupPrivacyDashboardLogicHandlers()
        privacyDashboardLogic.setup(for: webView)
        
        applyTheme(ThemeManager.shared.currentTheme)
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        privacyDashboardLogic.cleanUp()
    }
    
    private func setupWebView() {
        let configuration = WKWebViewConfiguration()

        let webView = WKWebView(frame: view.frame, configuration: configuration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.allowsBackForwardNavigationGestures = true
        webView.isOpaque = false
        
        view.addSubview(webView)
        self.webView = webView
    }
    
    private func setupPrivacyDashboardLogicHandlers() {
        privacyDashboardLogic.onProtectionSwitchChange = { [weak self] isEnabled in
            self?.privacyDashboardProtectionSwitchChangeHandler(enabled: isEnabled)
        }
        
        privacyDashboardLogic.onCloseTapped = { [weak self] in
            self?.privacyDashboardCloseTappedHandler()
        }
        
        privacyDashboardLogic.onShowReportBrokenSiteTapped = { [weak self] in
            guard let mainViewController = self?.presentingViewController as? MainViewController else { return }
            
            self?.dismiss(animated: true) {
                mainViewController.launchReportBrokenSite()
            }
        }
    }
    
    public func updatePrivacyInfo(_ privacyInfo: PrivacyInfo?) {
        privacyDashboardLogic.didFinishRulesCompilation()
        privacyDashboardLogic.updatePrivacyInfo(privacyInfo)
    }
}

private extension NewPrivacyDashboardViewController {
    
    func privacyDashboardProtectionSwitchChangeHandler(enabled: Bool) {
        print("switch: \(enabled)")
        
        guard let domain = privacyDashboardLogic.privacyInfo?.url.host else { return }
        
        let privacyConfiguration = ContentBlocking.privacyConfigurationManager.privacyConfig
        
        if enabled {
            privacyConfiguration.userEnabledProtection(forDomain: domain)
            ActionMessageView.present(message: UserText.messageProtectionEnabled.format(arguments: domain))
        } else {
            privacyConfiguration.userDisabledProtection(forDomain: domain)
            ActionMessageView.present(message: UserText.messageProtectionDisabled.format(arguments: domain))
        }
        
//        let completionToken = ContentBlocking.shared.contentBlockingManager.scheduleCompilation()
//        pendingUpdates[completionToken] = domain
//        sendPendingUpdates()
        
        privacyDashboardLogic.didStartRulesCompilation()
    }
    
    func privacyDashboardCloseTappedHandler() {
        dismiss(animated: true)
    }
}

extension NewPrivacyDashboardViewController: Themable {
    
    func decorate(with theme: Theme) {
        privacyDashboardLogic.themeName = theme.name.rawValue
        view.backgroundColor = theme.backgroundColor
    }
}
