//
//  UseDuckDuckGoViewController.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 01/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit

class UseDuckDuckGoViewController: UIViewController {
    
    @IBOutlet weak var versionText: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
    
    private func configureNavigationBar() {
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.isNavigationBarHidden = false
        navigationController?.isToolbarHidden = true
    }
}
