//
//  WidgetEducationHomeMessage.swift
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
import Core

struct WidgetEducationHomeMessage {
    enum Const {
        static let image = "WidgetEducationWidgetExample"
    }
    
    static func makeViewModel(presentingViewController: UIViewController,
                              onDidClose: @escaping () -> Void) -> HomeMessageViewModel {
        return HomeMessageViewModel(image: Const.image,
                                    topText: nil,
                                    title: UserText.addWidgetTitle,
                                    subtitle: UserText.addWidgetDescription,
                                    buttons: [.init(title: UserText.addWidget,
                                                    action: { presentWidgetEducation(presentingViewController: presentingViewController) })],
                                    onDidClose: onDidClose)
    }
    
    private static func presentWidgetEducation(presentingViewController: UIViewController) {
        Pixel.fire(pixel: .widgetEducationOpenedFromHomeScreen)
        let widgetEducationViewController = makeWidgetEducationViewController(presentingViewController: presentingViewController)
        widgetEducationViewController.modalPresentationStyle = .formSheet
        presentingViewController.present(widgetEducationViewController, animated: true)
    }
    
    private static func makeWidgetEducationViewController(presentingViewController: UIViewController) -> UIViewController {
        guard #available(iOS 14.0, *) else { fatalError() }
        return WidgetEducationViewController().embeddedInNavigationController
    }
}

@available(iOS 14.0, *)
extension WidgetEducationViewController: Themable {
    var embeddedInNavigationController: UIViewController {
        let navigationController = ThemableNavigationController(rootViewController: self)
        configureNavigationBar()
        return navigationController
    }
    
    private func configureNavigationBar() {
        title = UserText.addWidget
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                            target: self,
                                                            action: #selector(done))
        decorate(with: ThemeManager.shared.currentTheme)
    }
    
    @objc private func done() {
        dismiss(animated: true)
    }
}
