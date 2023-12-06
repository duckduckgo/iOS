//
//  ActionSheetDaxDialogViewController.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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

protocol ActionSheetDaxDialogDelegate: NSObjectProtocol {
    
    func actionSheetDaxDialogDidConfirmAction(controller: ActionSheetDaxDialogViewController)
    
}

class ActionSheetDaxDialogViewController: UIViewController {

    @IBOutlet weak var highlightCutOutView: HighlightCutOutView!
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    
    weak var daxDialogViewController: DaxDialogViewController?
    weak var alertController: UIAlertController?
    @IBOutlet weak var actionSheetContainerView: UIView!
    weak var delegate: ActionSheetDaxDialogDelegate?

    var spec: DaxDialogs.ActionSheetSpec?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        daxDialogViewController?.message = spec?.message
        if let spec = spec {
            let alertController = UIAlertController()
            alertController.addAction(title: spec.confirmAction, style: spec.isConfirmActionDestructive ? .destructive : .default) {
                Pixel.fire(pixel: spec.confirmActionPixelName)
                self.delegate?.actionSheetDaxDialogDidConfirmAction(controller: self)
                self.dismiss(animated: false)
            }
            alertController.addAction(title: spec.cancelAction, style: .cancel) {
                Pixel.fire(pixel: spec.cancelActionPixelName)
                self.dismiss(animated: true)
            }
            addChild(alertController)
            alertController.view.translatesAutoresizingMaskIntoConstraints = false
            actionSheetContainerView.addSubview(alertController.view)
            NSLayoutConstraint.activate([
                alertController.view.centerXAnchor.constraint(equalTo: actionSheetContainerView.centerXAnchor, constant: 0),
                alertController.view.topAnchor.constraint(equalTo: actionSheetContainerView.topAnchor, constant: 0),
                alertController.view.bottomAnchor.constraint(equalTo: actionSheetContainerView.bottomAnchor, constant: 0)
            ])
        }
        
        highlightCutOutView.fillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        containerHeight.constant = daxDialogViewController?.calculateHeight() ?? 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let spec = spec {
            Pixel.fire(pixel: spec.displayedPixelName)
        }
        containerHeight.constant = daxDialogViewController?.calculateHeight() ?? 0
        daxDialogViewController?.start()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.destination is DaxDialogViewController {
            daxDialogViewController = segue.destination as? DaxDialogViewController
        }
    }

    @IBAction func onTapOutside(_ sender: Any) {
        guard daxDialogViewController?.isFinished ?? true else {
            daxDialogViewController?.finish()
            return
        }
        
        dismiss(animated: true)
        if let spec = spec {
            Pixel.fire(pixel: spec.cancelActionPixelName)
        }
    }
}

extension MainViewController: ActionSheetDaxDialogDelegate {
    func actionSheetDaxDialogDidConfirmAction(controller: ActionSheetDaxDialogViewController) {
        forgetAllWithAnimation(showNextDaxDialog: true)
    }
}

extension TabSwitcherViewController: ActionSheetDaxDialogDelegate {
    func actionSheetDaxDialogDidConfirmAction(controller: ActionSheetDaxDialogViewController) {
        delegate?.tabSwitcherDidRequestForgetAll(tabSwitcher: self)
    }
}
