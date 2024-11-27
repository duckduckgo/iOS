//
//  AIChatViewController.swift
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

final class AIChatViewController: UIViewController {

    private let webViewController = AIChatWebViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        addWebViewController()
    }

    private func setupNavigationBar() {
        let imageView = UIImageView(image: UIImage(systemName: "globe"))
        imageView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.text = UserText.aiChatTitle
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)

        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .leading
        stackView.distribution = .fill

        let leftBarButtonItem = UIBarButtonItem(customView: stackView)
        navigationItem.leftBarButtonItem = leftBarButtonItem

        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeButtonTapped))
        navigationItem.rightBarButtonItem = closeButton
    }

    private func addWebViewController() {
        addChild(webViewController)
        view.addSubview(webViewController.view)
        webViewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            webViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            webViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        webViewController.didMove(toParent: self)
    }

    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
