//
//  QuickLookContainerViewController.swift
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
import QuickLook

class QuickLookContainerViewController: UIViewController {
    var onDoneButtonPressed: (() -> Void)?

    private lazy var quickLookController: QLPreviewController = {
        let controller = QLPreviewController()
        controller.dataSource = self
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
        return controller
    }()
    
    private lazy var quickLookNavigationController: UINavigationController = {
        let navigationController = UINavigationController(rootViewController: quickLookController)
        return navigationController
    }()
    
    private let localFileURL: URL

    init(localFileURL: URL) {
        self.localFileURL = localFileURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        installChildViewController(quickLookNavigationController)
    }
    
    func reloadData() {
        quickLookController.reloadData()
    }
    
    @objc private func doneButtonPressed() {
        onDoneButtonPressed?()
    }
}

extension QuickLookContainerViewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let string = self.localFileURL.absoluteString
        return NSURL(string: string)!
    }
}
