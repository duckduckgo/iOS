//
//  ContentBlockerDisabledViewController.swift
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

class ContentBlockerDisabledViewController: UITableViewController {

    weak var delegate: ContentBlockerDisabledDelegate?
    
    static func loadFromStoryboard(withDelegate delegate: ContentBlockerDisabledDelegate) -> ContentBlockerDisabledViewController {
        let storyboard = UIStoryboard(name: "ContentBlocker", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ContentBlockerDisabledViewController") as! ContentBlockerDisabledViewController
        controller.delegate = delegate
        return controller
    }
    
    @IBAction func onBlockingEnabledToggle(_ sender: UISwitch) {
        delegate?.contentBlockerWasEnabled(disabledController: self)
    }
}
