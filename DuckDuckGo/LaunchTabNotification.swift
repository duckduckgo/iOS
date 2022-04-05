//
//  LaunchTabNotification.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

class LaunchTabNotification {

    public class Observer {

        private let observer: NSObjectProtocol

        init(observer: NSObjectProtocol) {
            self.observer = observer
        }

        deinit {
            remove()
        }

        func remove() {
            NotificationCenter.default.removeObserver(observer)
        }

    }

    private static let urlUserInfo = "url"

    class func postLaunchTabNotification(urlString: String) {
        NotificationCenter.default.post(name: .launchTab, object: nil, userInfo: [ urlUserInfo: urlString ])
    }

    class func addObserver(handler: @escaping (String) -> Void) -> Observer {
        let observer = NotificationCenter.default.addObserver(forName: .launchTab, object: nil, queue: nil) { notification in
            guard let urlString = notification.userInfo?[urlUserInfo] as? String else { return }
            handler(urlString)
        }

        return Observer(observer: observer)
    }

}

private extension NSNotification.Name {

    static let launchTab: NSNotification.Name = Notification.Name(rawValue: "com.duckduckgo.notification.launchTab")

}
