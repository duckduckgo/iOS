//
//  RoundedPageSheetContainerViewController.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

protocol RoundedPageSheetContainerViewControllerDelegate: AnyObject {
    func roundedPageSheetContainerViewControllerDidDisappear(_ controller: RoundedPageSheetContainerViewController)
}

final class RoundedPageSheetContainerViewController: UIViewController {
    weak var delegate: RoundedPageSheetContainerViewControllerDelegate?
    let contentViewController: UIViewController
    private let allowedOrientation: UIInterfaceOrientationMask
    let backgroundView = UIView()

    private var interactiveDismissalTransition: UIPercentDrivenInteractiveTransition?
    private var isInteractiveDismissal = false

    init(contentViewController: UIViewController, allowedOrientation: UIInterfaceOrientationMask = .all) {
        self.contentViewController = contentViewController
        self.allowedOrientation = allowedOrientation
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return allowedOrientation
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        setupBackgroundView()
        setupContentViewController()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.roundedPageSheetContainerViewControllerDidDisappear(self)
    }

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        let progress = translation.y / view.bounds.height

        switch gesture.state {
        case .began:
            isInteractiveDismissal = true
            interactiveDismissalTransition = UIPercentDrivenInteractiveTransition()
            dismiss(animated: true, completion: nil)
        case .changed:
            interactiveDismissalTransition?.update(progress)
        case .ended, .cancelled:
            let shouldDismiss = progress > 0.3 || velocity.y > 1000
            if shouldDismiss {
                interactiveDismissalTransition?.finish()
            } else {
                interactiveDismissalTransition?.cancel()
                UIView.animate(withDuration: 0.2, animations: {
                    self.view.transform = .identity
                })
            }
            isInteractiveDismissal = false
            interactiveDismissalTransition = nil
        default:
            break
        }
    }

    private func setupBackgroundView() {
        view.addSubview(backgroundView)

        backgroundView.backgroundColor = .black
        backgroundView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupContentViewController() {
        addChild(contentViewController)
        view.addSubview(contentViewController.view)
        contentViewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        contentViewController.view.layer.cornerRadius = 20
        contentViewController.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        contentViewController.view.clipsToBounds = true

        contentViewController.didMove(toParent: self)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        contentViewController.view.addGestureRecognizer(panGesture)
    }
}

extension RoundedPageSheetContainerViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return RoundedPageSheetPresentationAnimator()
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return RoundedPageSheetDismissalAnimator()
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return isInteractiveDismissal ? interactiveDismissalTransition : nil
    }
}
