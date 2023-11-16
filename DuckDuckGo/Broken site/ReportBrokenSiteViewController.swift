////
////  ReportBrokenSiteViewController.swift
////  DuckDuckGo
////
////  Copyright © 2020 DuckDuckGo. All rights reserved.
////
////  Licensed under the Apache License, Version 2.0 (the "License");
////  you may not use this file except in compliance with the License.
////  You may obtain a copy of the License at
////
////  http://www.apache.org/licenses/LICENSE-2.0
////
////  Unless required by applicable law or agreed to in writing, software
////  distributed under the License is distributed on an "AS IS" BASIS,
////  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
////  See the License for the specific language governing permissions and
////  limitations under the License.
////
//
// import UIKit
// import SwiftUI
//
// class ReportBrokenSiteViewController: UIViewController {
//    
//    public var brokenSiteInfo: BrokenSiteInfo?
//    
//    private var reportView: ReportBrokenSiteView?
//    
////    private let categories: [BrokenSite.Category] = {
////        var categories = BrokenSite.Category.allCases
////        categories = categories.filter { $0 != .other }
////        categories = categories.shuffled()
////        categories.append(.other)
////        return categories
////    }()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        applyTheme(ThemeManager.shared.currentTheme)
//        
//        reportView = ReportBrokenSiteView(categories: categories, submitReport: submitForm(category:description:))
//        let hc = UIHostingController(rootView: reportView)
//        
//        self.addChild(hc)
//        self.view.addSubview(hc.view)
//        hc.didMove(toParent: self)
//        
//        hc.view.translatesAutoresizingMaskIntoConstraints = false
//        hc.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
//        hc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//        hc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        hc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//        
//        DispatchQueue.main.async {
//            self.view.setNeedsLayout()
//            self.view.layoutIfNeeded()
//        }
//    }
//    
//    @IBAction func onClosePressed(sender: Any) {
//        dismiss(animated: true)
//    }
//    
//    func submitForm(category: BrokenSite.Category?, description: String) {
//        brokenSiteInfo?.send(with: category?.rawValue, description: description)
//        ActionMessageView.present(message: UserText.feedbackSumbittedConfirmation)
//        dismiss(animated: true)
//    }
// }
//
// extension ReportBrokenSiteViewController: Themable {
//    
//    func decorate(with theme: Theme) {
//        decorateNavigationBar(with: theme)
//        
//        view.backgroundColor = theme.backgroundColor
//    }
// }
