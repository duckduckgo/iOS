//
//  TitleBarView.swift
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
import DesignResourcesKit

final class TitleBarView: UIView {
    private let titleLabel: UILabel
    private let closeButton: UIButton
    private let handleBar: UIView
    private var closeAction: (() -> Void)?

    init(title: String, closeAction: @escaping () -> Void) {
        titleLabel = UILabel()
        closeButton = UIButton(type: .system)
        handleBar = UIView()
        
        self.closeAction = closeAction

        super.init(frame: .zero)

        setupView(title: title)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView(title: String) {
        backgroundColor = .webViewBackgroundColor

        handleBar.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        handleBar.layer.cornerRadius = Constants.handlebarHeight / 2
        handleBar.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = UIColor(designSystemColor: .textPrimary)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        closeButton.setImage(UIImage(named: "Close-24"), for: .normal)
        closeButton.tintColor = UIColor(designSystemColor: .icons)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)

        addSubview(handleBar)
        addSubview(titleLabel)
        addSubview(closeButton)

        NSLayoutConstraint.activate([
            handleBar.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            handleBar.centerXAnchor.constraint(equalTo: centerXAnchor),
            handleBar.widthAnchor.constraint(equalToConstant: Constants.handlebarWidth),
            handleBar.heightAnchor.constraint(equalToConstant: Constants.handlebarHeight),

            titleLabel.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: handleBar.bottomAnchor, constant: 30),

            closeButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -8),
            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: Constants.closeButtonSize),
            closeButton.heightAnchor.constraint(equalToConstant: Constants.closeButtonSize)
        ])
    }

    @objc private func closeButtonTapped() {
        closeAction?()
    }
}

private enum Constants {
    static let closeButtonSize: CGFloat = 44
    static let handlebarHeight: CGFloat = 3
    static let handlebarWidth: CGFloat = 42
}
