//
//  FullscreenDaxDialogViewController.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 14/05/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import UIKit

class FullscreenDaxDialogViewController: UIViewController {

    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    
    weak var daxDialogViewController: DaxDialogViewController?

    var spec: DaxOnboarding.BrowsingSpec?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        daxDialogViewController?.cta = spec?.cta
        daxDialogViewController?.message = spec?.message
        daxDialogViewController?.onTapCta = dismissCta
        containerHeight.constant = spec?.height ?? 100
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        daxDialogViewController?.start()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.destination is DaxDialogViewController {
            daxDialogViewController = segue.destination as? DaxDialogViewController
        }
    }
    
    private func dismissCta() {
        dismiss(animated: true)
    }
    
}
