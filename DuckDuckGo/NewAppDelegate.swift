//
//  NewAppDelegate.swift
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

final class NewAppDelegate: NSObject, UIApplicationDelegate, DDGAppDelegate {

    private let appStateMachine: AppStateMachine = AppStateMachine()

    var privacyProDataReporter: PrivacyProDataReporting? {
        (appStateMachine.currentState as? Active)?.appDependencies.privacyProDataReporter // just for now, we have to get rid of this antipattern
    }

    func initialize() { } // init code will happen inside AppStateMachine/Init state .init()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        appStateMachine.handle(.launching(application))
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        appStateMachine.handle(.activating)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        appStateMachine.handle(.suspending)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        appStateMachine.handle(.backgrounding)
    }

    func application(_ application: UIApplication,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void) {
        appStateMachine.handle(.handleShortcutItem(shortcutItem))
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        appStateMachine.handle(.openURL(url))
        return true
    }

    func refreshRemoteMessages() {
        // part of debug menu, let's not support it in the first iteration
    }


}
