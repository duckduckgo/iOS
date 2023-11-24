//
//  SubscriptionAccessViewController.swift
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

import AppKit
import Account
import SwiftUI

public final class SubscriptionAccessViewController: NSViewController {

    private let accountManager: AccountManager
    private var actionHandlers: SubscriptionAccessActionHandlers

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(accountManager: AccountManager = AccountManager(), actionHandlers: SubscriptionAccessActionHandlers) {
        self.accountManager = accountManager
        self.actionHandlers = actionHandlers
        super.init(nibName: nil, bundle: nil)
    }

    public override func loadView() {
        let subscriptionAccessView = SubscriptionAccessView(model: makeSubscriptionAccessModel(),
                                                            dismiss: { [weak self] in
                guard let self = self else { return }
                self.presentingViewController?.dismiss(self)
        })

        let hostingView = NSHostingView(rootView: subscriptionAccessView)
        let size = hostingView.fittingSize

        view = NSView(frame: NSRect(x: 0, y: 0, width: size.width, height: size.height))
        hostingView.frame = view.bounds
        hostingView.autoresizingMask = [.height, .width]
        hostingView.translatesAutoresizingMaskIntoConstraints = true

        view.addSubview(hostingView)
    }

    private func makeSubscriptionAccessModel() -> SubscriptionAccessModel {
        if accountManager.isUserAuthenticated {
            ShareSubscriptionAccessModel(actionHandlers: actionHandlers, email: accountManager.email)
        } else {
            ActivateSubscriptionAccessModel(actionHandlers: actionHandlers)
        }
    }
}
