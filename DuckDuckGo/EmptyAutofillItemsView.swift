//
//  EmptyAutofillItemsView.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import DuckUI

@available(iOS 14.0, *)
final class EmptyAutofillItemsView: UIView {
    
    enum ViewState {
        case autofillEnabled
        case autofillDisabled
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        installSubviews()
        installConstraints()
    }
    
    var viewState: ViewState = .autofillEnabled {
        didSet {
            updateLabels(with: viewState)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var title: UILabel = {
        let label = UILabel(frame: CGRect.zero)

        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title3)
        label.font = UIFont.systemFont(ofSize: descriptor.pointSize, weight: .bold)
        
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.textColor = .gray90
        
        return label
    }()
    
    private lazy var subtitle: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .footnote, compatibleWith: nil)
        label.textColor = .gray70
        label.text = "Logins are stored securely on this device only."

        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let image = UIImage(named: "AutofillKey")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: 87, height: 87)

        return imageView
    }()
    
    private lazy var stackContentView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, title])
        stackView.axis = .vertical
        stackView.spacing = 28
        return stackView
    }()
    
    
    private func installSubviews() {
        addSubview(stackContentView)
        addSubview(subtitle)
    }
    
    private func updateLabels(with state: EmptyAutofillItemsView.ViewState) {
        switch state {
        case .autofillDisabled:
            title.text = "Enable Autofill to start saving Logins."
        case .autofillEnabled:
            title.text = "No logins saved yet."
        }
    }
    
    private func installConstraints() {
        stackContentView.translatesAutoresizingMaskIntoConstraints = false
     //   imageView.translatesAutoresizingMaskIntoConstraints = false
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
//            imageView.heightAnchor.constraint(equalToConstant: 87),
//            imageView.widthAnchor.constraint(equalToConstant: 87),
//
            stackContentView.topAnchor.constraint(equalTo: topAnchor),
            stackContentView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackContentView.widthAnchor.constraint(equalTo: widthAnchor),
            
            subtitle.centerXAnchor.constraint(equalTo: centerXAnchor),
            subtitle.widthAnchor.constraint(equalTo: widthAnchor),
            subtitle.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
