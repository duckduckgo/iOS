//
//  CompositeTransition.swift
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

class CompositeTransition: NSObject, UIViewControllerTransitioningDelegate {

    let presentingController: UIViewControllerAnimatedTransitioning?
    let dismissingController: UIViewControllerAnimatedTransitioning?

    init(presenting: UIViewControllerAnimatedTransitioning?, dismissing: UIViewControllerAnimatedTransitioning?) {
        presentingController = presenting
        dismissingController = dismissing
        super.init()
    }

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let mainVC = presenting as? MainViewController,
            let tabSwitcherVC = presented as? TabSwitcherViewController else {
            return nil
        }
        
        return TabSwitcherTransitioningIn(mainViewController: mainVC,
                                          tabSwitcherViewController: tabSwitcherVC)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let tabSwitcherVC = dismissed as? TabSwitcherViewController else { return nil }
        return TabSwitcherTransitioningOut(tabSwitcherViewController: tabSwitcherVC)
    }
}
