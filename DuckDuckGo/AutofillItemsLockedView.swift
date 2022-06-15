//
//  AutofillItemsLockedView.swift
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
class AutofillItemsLockedView: UIView {
   
    private lazy var title: UILabel = {
        let label = UILabel(frame: CGRect.zero)

        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title3)
        label.font = UIFont.systemFont(ofSize: descriptor.pointSize, weight: .semibold)
        label.text = UserText.autofillLockedViewTitle
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    private lazy var imageView: UIImageView = {
        let image = UIImage(named: "AutofillLock")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: 126, height: 96)
        return imageView
    }()
    
    private lazy var stackContentView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, title])
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        installSubviews()
        installConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func installSubviews() {
        addSubview(stackContentView)
    }
    
    private func installConstraints() {
        stackContentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackContentView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackContentView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

}

@available(iOS 14.0, *)
extension AutofillItemsLockedView: Themable {
    
    func decorate(with theme: Theme) {
        title.textColor = theme.textFieldFontColor
    }
}
