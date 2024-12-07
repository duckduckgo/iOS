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

final class RoundedPageSheetContainerViewController: UIViewController {
    let contentViewController: UIViewController
    private let logoImage: UIImage?
    private let titleText: String

    private lazy var titleBarView: TitleBarView = {
        let titleBarView = TitleBarView(logoImage: logoImage, title: titleText) { [weak self] in
            self?.closeController()
        }
        return titleBarView
    }()

    init(contentViewController: UIViewController, logoImage: UIImage?, title: String) {
        self.contentViewController = contentViewController
        self.logoImage = logoImage
        self.titleText = title
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom

        transitioningDelegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        setupTitleBar()
        setupContentViewController()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            // Update layout or constraints here
        }, completion: nil)
    }


    private func setupTitleBar() {
        view.addSubview(titleBarView)
        titleBarView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleBarView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func setupContentViewController() {
        addChild(contentViewController)
        view.addSubview(contentViewController.view)
        contentViewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentViewController.view.topAnchor.constraint(equalTo: titleBarView.bottomAnchor), // Below the title bar
            contentViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        contentViewController.view.layer.cornerRadius = 20
        contentViewController.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        contentViewController.view.clipsToBounds = true

        contentViewController.didMove(toParent: self)
    }

    @objc func closeController() {
        dismiss(animated: true, completion: nil)
    }
}

extension RoundedPageSheetContainerViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return RoundedPageSheetPresentationAnimator()
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return RoundedPageSheetDismissalAnimator()
    }
}

final private class TitleBarView: UIView {
    private let imageView: UIImageView
    private let titleLabel: UILabel
    private let closeButton: UIButton

    init(logoImage: UIImage?, title: String, closeAction: @escaping () -> Void) {
        imageView = UIImageView(image: logoImage)
        titleLabel = UILabel()
        closeButton = UIButton(type: .system)

        super.init(frame: .zero)

        setupView(title: title, closeAction: closeAction)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView(title: String, closeAction: @escaping () -> Void) {
        backgroundColor = .clear

        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let imageSize: CGFloat = 28
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: imageSize),
            imageView.heightAnchor.constraint(equalToConstant: imageSize)
        ])

        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        closeButton.setImage(UIImage(named: "Close-24"), for: .normal)
        closeButton.tintColor = .white
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)

        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(closeButton)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            closeButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            closeButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        self.closeAction = closeAction
    }

    private var closeAction: (() -> Void)?

    @objc private func closeButtonTapped() {
        closeAction?()
    }
}
