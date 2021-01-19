//
//  FullscreenDaxDialogViewController.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

protocol FullscreenDaxDialogDelegate: NSObjectProtocol {

    func hideDaxDialogs(controller: FullscreenDaxDialogViewController)
    func closedDaxDialogs(controller: FullscreenDaxDialogViewController)
    func daxDialogDidRequestFireButtonPosition(controller: FullscreenDaxDialogViewController) -> CGPoint?
    func daxDialogDidRquestAddressBarRect(controller: FullscreenDaxDialogViewController) -> CGRect?
    
}

class FullscreenDaxDialogViewController: UIViewController {

    struct Constants {
        
        static let defaultCTAHeight: CGFloat = 100
        
    }
    @IBOutlet weak var highlightCutOutView: HighlightCutOutView!
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    
    weak var daxDialogViewController: DaxDialogViewController?
    weak var delegate: FullscreenDaxDialogDelegate?

    var spec: DaxDialogs.BrowsingSpec?
    var woShown: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        daxDialogViewController?.cta = spec?.cta
        daxDialogViewController?.message = spec?.message
        daxDialogViewController?.onTapCta = dismissCta
        
        highlightCutOutView.fillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(orientationDidChange),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateCutOut),
                                               name: TabsBarViewController.ViewDidLayoutNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateCutOut),
                                               name: OmniBar.DidLayoutNotification,
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        containerHeight.constant = daxDialogViewController?.calculateHeight() ?? 0
        
        updateCutOut()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let spec = spec {
            Pixel.fire(pixel: spec.pixelName, withAdditionalParameters: [ "wo": woShown ? "1" : "0" ])
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
    
    @objc
    func orientationDidChange() {
        updateCutOut()
    }
    
    @objc private func updateCutOut() {
        if spec?.highlightAddressBar ?? false, let rect = delegate?.daxDialogDidRquestAddressBarRect(controller: self) {
            let padding: CGFloat = 6
            let paddedRect = CGRect(x: rect.origin.x - padding,
                                    y: rect.origin.y - padding,
                                    width: rect.size.width + padding * 2,
                                    height: rect.size.height + padding * 2)
            highlightCutOutView.cutOutPath = UIBezierPath(roundedRect: paddedRect, cornerRadius: paddedRect.height / 2.0)
        } else if spec?.highlightFireButton ?? false, let pos = delegate?.daxDialogDidRequestFireButtonPosition(controller: self) {
            let size: CGFloat = 56
            let point = CGPoint(x: pos.x - size / 2.0, y: pos.y - size / 2.0)
            let rect = CGRect(origin: point, size: CGSize(width: size, height: size))
            highlightCutOutView.cutOutPath = UIBezierPath(ovalIn: rect)
        } else {
            highlightCutOutView.cutOutPath = nil
        }
        highlightCutOutView.setNeedsDisplay()
    }

    @IBAction func onTapHide() {
        dismiss(animated: true)
        delegate?.hideDaxDialogs(controller: self)
    }
    
    private func dismissCta() {
        dismiss(animated: true)
        if spec == DaxDialogs.BrowsingSpec.fireButtonEducation {
            Pixel.fire(pixel: .daxDialogsFireEducationCTA)
        }
        delegate?.closedDaxDialogs(controller: self)
    }
    
}

extension TabViewController: FullscreenDaxDialogDelegate {

    func hideDaxDialogs(controller: FullscreenDaxDialogViewController) {

        let alertController = UIAlertController(title: UserText.daxDialogHideTitle,
                                           message: UserText.daxDialogHideMessage,
                                           preferredStyle: isPad ? .alert : .actionSheet)

        alertController.addAction(title: UserText.daxDialogHideButton, style: .default) {
            if controller.spec == DaxDialogs.BrowsingSpec.fireButtonEducation {
                Pixel.fire(pixel: .daxDialogsFireEducationHidden)
            } else if DaxDialogs.shared.isFireButtonEducationEnabled {
                Pixel.fire(pixel: .daxDialogsHiddenBeforeFireEducation)
            }
            Pixel.fire(pixel: .daxDialogsHidden, withAdditionalParameters: [ "c": DefaultDaxDialogsSettings().browsingDialogsSeenCount ])
            DaxDialogs.shared.dismiss()
        }
        alertController.addAction(title: UserText.daxDialogHideCancel, style: .cancel) {
            if controller.spec != DaxDialogs.BrowsingSpec.fireButtonEducation {
                self.showDaxDialogOrStartTrackerNetworksAnimationIfNeeded()
            } else {
                Pixel.fire(pixel: .daxDialogsFireEducationHiddenCanceled)
            }
        }
        present(alertController, animated: true)
        if controller.spec?.highlightAddressBar ?? false {
            chromeDelegate?.omniBar.cancelAllAnimations()
        }
    }
    
    func closedDaxDialogs(controller: FullscreenDaxDialogViewController) {
        if controller.spec?.highlightAddressBar ?? false {
            chromeDelegate?.omniBar.completeAnimations()
        }
        
        if controller.spec != DaxDialogs.BrowsingSpec.fireButtonEducation {
            showDaxDialogOrStartTrackerNetworksAnimationIfNeeded()
        }
        
        if controller.spec == DaxDialogs.BrowsingSpec.fireButtonEducation {
            delegate?.tabDidRequestForgetAll(tab: self)
        }
    }

    func daxDialogDidRequestFireButtonPosition(controller: FullscreenDaxDialogViewController) -> CGPoint? {
        return delegate?.tabDidRequestFireButtonLocation(tab: self)
    }
    
    func daxDialogDidRquestAddressBarRect(controller: FullscreenDaxDialogViewController) -> CGRect? {
        return delegate?.tabDidRequestSearchBarRect(tab: self)
    }
}

fileprivate extension DefaultDaxDialogsSettings {
    
    var browsingDialogsSeenCount: String {
        let count = [ browsingMajorTrackingSiteShown,
                      browsingWithoutTrackersShown,
                      browsingWithTrackersShown,
                      browsingAfterSearchShown,
                      browsingFireButtonEducationShown].reduce(0, { $0 + ($1 ? 1 : 0) })
        return "\(count)"
    }
    
}
