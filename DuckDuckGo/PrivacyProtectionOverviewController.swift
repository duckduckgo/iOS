//
//  PrivacyProtectionOverviewController.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 31/10/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

class PrivacyProtectionOverviewController: UITableViewController {

    @IBOutlet var margins: [NSLayoutConstraint]!
    @IBOutlet var requiresKernAdjustment: [UILabel]!

    var popRecognizer: InteractivePopRecognizer!

    lazy var contentBlocker: ContentBlockerConfigurationStore = ContentBlockerConfigurationUserDefaults()
    weak var siteRating: SiteRating!

    override func viewDidLoad() {
        super.viewDidLoad()

        initPopRecognizer()
        initGrade()
        initProtectionStatus()
        initEncryption()
        initTrackersBlocked()
        initMajorTrackersBlocked()
        initPrivacyPolicies()
        initLeaderBoard()
        adjustMargins()
        adjustKerns()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let infoDisplaying = segue.destination as? PrivacyProtectionInfoDisplaying {
            infoDisplaying.prepare(for: siteRating)
        }

    }

    // see https://stackoverflow.com/a/41248703
    private func initPopRecognizer() {
        guard let controller = navigationController else { return }
        popRecognizer = InteractivePopRecognizer(controller: controller)
        controller.interactivePopGestureRecognizer?.delegate = popRecognizer
    }

    private func initGrade() {
    }

    private func initProtectionStatus() {
    }

    private func initEncryption() {
    }

    private func initTrackersBlocked() {
    }

    private func initMajorTrackersBlocked() {
    }

    private func initPrivacyPolicies() {
    }

    private func initLeaderBoard() {

    }

    private func adjustMargins() {
        if #available(iOS 10, *) {
            for margin in margins {
                margin.constant = 0
            }
        }
    }

    private func adjustKerns() {
        for label in requiresKernAdjustment {
            label.adjustKern(1.7)
        }
    }

}

class InteractivePopRecognizer: NSObject, UIGestureRecognizerDelegate {

    var navigationController: UINavigationController

    init(controller: UINavigationController) {
        self.navigationController = controller
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController.viewControllers.count > 1
    }

    // This is necessary because without it, subviews of your top controller can
    // cancel out your gesture recognizer on the edge.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}


