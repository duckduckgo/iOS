//
//  PrivacyProtectionErrorController.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

import Foundation
import UIKit

protocol PrivacyProtectionErrorDelegate: class {

    func canTryAgain(controller: PrivacyProtectionErrorController) -> Bool

    func tryAgain(controller: PrivacyProtectionErrorController)

}

class PrivacyProtectionErrorController: UITableViewController {

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var buttonCell: UITableViewCell!

    weak var footer: PrivacyProtectionFooterController!

    var errorText: String?

    weak var delegate: PrivacyProtectionErrorDelegate?

    override func viewDidLoad() {
        button.layer.cornerRadius = 5
        errorLabel.text = errorText
        resetTryAgain()
        buttonCell.isHidden = !canRetry()
        applyTheme(ThemeManager.shared.currentTheme)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateFooterHeight()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            self.updateFooterHeight()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let footer = segue.destination as? PrivacyProtectionFooterController {
            self.footer = footer
        }
    }

    @IBAction func onTapTryAgain() {
        activity.isHidden = false
        button.isHidden = true
        delegate?.tryAgain(controller: self)
    }

    func resetTryAgain() {
        button?.isHidden = !canRetry()
        activity?.isHidden = true
    }

    private func canRetry() -> Bool {
        return (delegate?.canTryAgain(controller: self) ?? false)
    }

    private func updateFooterHeight() {
//        guard let footerView = tableView.tableFooterView else { return }
//
//        tableView.tableFooterView = nil
//
//        let frameHeight = tableView.frame.size.height
//        let contentHeight = tableView.contentSize.height
//
//        let minSize = footer.preferredContentSize.height
//        let height = max(minSize, frameHeight - contentHeight)
//
//        let frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: height)
//        footerView.frame = frame
//        tableView.tableFooterView = footerView
    }

}

extension PrivacyProtectionErrorController: Themable {

    func decorate(with theme: Theme) {
        decorateNavigationBar(with: theme)
    }

}
