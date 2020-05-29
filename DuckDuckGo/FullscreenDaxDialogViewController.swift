//
//  FullscreenDaxDialogViewController.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 14/05/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import UIKit

protocol FullscreenDaxDialogDelegate: NSObjectProtocol {

    func hideDaxDialogs(controller: FullscreenDaxDialogViewController)

}

class FullscreenDaxDialogViewController: UIViewController {

    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    
    weak var daxDialogViewController: DaxDialogViewController?
    weak var delegate: FullscreenDaxDialogDelegate?

    var spec: DaxDialogs.BrowsingSpec?
    
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

    @IBAction func onTapHide() {
        dismiss(animated: true)
        delegate?.hideDaxDialogs(controller: self)
    }
    
    private func dismissCta() {
        dismiss(animated: true)
    }
    
}

extension TabViewController: FullscreenDaxDialogDelegate {

    func hideDaxDialogs(controller: FullscreenDaxDialogViewController) {

        let controller = UIAlertController(title: "Hide remaining tips?",
                                           message: "There are only a few, and we tried to make them informative.",
                                           preferredStyle: isPad ? .alert : .actionSheet)

        controller.addAction(title: "Hide tips forever", style: .default) {
            DaxDialogs().dismiss()
        }
        controller.addAction(title: "Cancel", style: .cancel)
        present(controller, animated: true)
    }

}
