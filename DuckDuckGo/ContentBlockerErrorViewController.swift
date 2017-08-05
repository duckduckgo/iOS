//
//  ContentBlockerRelaoder.swift
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


import UIKit
import Core

class ContentBlockerErrorViewController: UIViewController {
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    weak var delegate: ContentBlockerErrorDelegate?
    
    static func loadFromStoryboard(delegate: ContentBlockerErrorDelegate) -> ContentBlockerErrorViewController {
        let storyboard = UIStoryboard.init(name: "ContentBlocker", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ContentBlockerErrorViewController") as! ContentBlockerErrorViewController
        controller.delegate = delegate
        return controller
    }
    
    @IBAction func onReloadButtonPressed(_ sender: Any) {
        startSpinner()
        TrackerLoader.shared.updateTrackers { [weak self] (trackers, _) in
            self?.stopSpinner()
            if trackers != nil {
                self?.onSuccess()
            }
        }
    }
    
    private func startSpinner() {
        reloadButton.isHidden = true
        spinner.startAnimating()
    }
    
    private func stopSpinner() {
        reloadButton.isHidden = false
        spinner.stopAnimating()
    }
    
    private func onSuccess() {
        delegate?.errorWasResolved()
    }
}
