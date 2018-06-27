//
//  HomeRowCTAExperiment1ViewController.swift
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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

class HomeRowCTAExperiment1ViewController: UIViewController {
    
    @IBOutlet weak var infoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInfoView()
    }
    
    @IBAction func showMe() {
        performSegue(withIdentifier: "showMe", sender: self)
        dismiss()
    }
    
    @IBAction func noThanks() {
        dismiss()
    }
    
    private func dismiss() {
        HomeRowCTA().dismissed()
        view.alpha = 0.0
    }
    
    private func configureInfoView() {
        infoView.layer.cornerRadius = 5
        infoView.layer.borderColor = UIColor.greyishBrownTwo.cgColor
        infoView.layer.borderWidth = 1
        infoView.layer.masksToBounds = true
    }
    
}
