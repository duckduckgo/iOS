//
//  AutofillBreakageReportTableViewCell.swift
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

import SwiftUI
import UIKit

final class AutofillBreakageReportTableViewCell: UITableViewCell {
    
    private(set) var host: UIHostingController<AutofillBreakageReportCellContentView>?

    func embed(in parent: UIViewController, withView content: AutofillBreakageReportCellContentView) {
        if let host = self.host {
            host.rootView = content
            host.view.layoutIfNeeded()
        } else {
            let host = UIHostingController(rootView: content)
            host.view.backgroundColor = .clear
            parent.addChild(host)
            host.didMove(toParent: parent)
            contentView.addSubview(host.view)

            host.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                host.view.topAnchor.constraint(equalTo: self.contentView.topAnchor),
                host.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
                host.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
                host.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor)
            ])

            self.host = host
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        host?.view.removeFromSuperview()
        host?.removeFromParent()
        host = nil
    }
}
