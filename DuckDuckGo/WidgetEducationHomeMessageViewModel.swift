//
//  WidgetEducationHomeMessageViewModel.swift
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

import Foundation
import UIKit

struct WidgetEducationHomeMessageViewModel {
    static func makeViewModel(presentingViewController: UIViewController,
                              onDidClose: @escaping () -> Void) -> HomeMessageViewModel {
        return HomeMessageViewModel(image: "WidgetExample",
                                    topText: nil,//UserText.defaultBrowserHomeMessageHeader,
                                    title: UserText.addWidgetTitle,//UserText.defaultBrowserHomeMessageHeader,
                                    subtitle: UserText.addWidgetDescription,//UserText.defaultBrowserHomeMessageSubheader,
                                    buttons: [.init(title: UserText.addWidgetButton/*UserText.defaultBrowserHomeMessageButtonText*/, action: {
            guard #available(iOS 14.0, *) else { return }
            presentingViewController.present(AddWidgetViewController(), animated: true)
        })],
                                    onDidClose: onDidClose)
    }
}
