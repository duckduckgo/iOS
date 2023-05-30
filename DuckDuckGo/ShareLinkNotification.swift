//
//  ShareLinkNotification.swift
//  DuckDuckGo
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

import Foundation
import UIKit
import LinkPresentation

class ShareLinkNotification {

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
    private static let titleUserInfo = "title"

    class func postShareLinkNotification(urlString: String, title: String) {
        NotificationCenter.default.post(name: .shareLink, object: nil, userInfo: [ urlUserInfo: urlString, titleUserInfo: title ])
    }

    class func addObserver(handler: @escaping (String, String) -> Void) -> Observer {
        let observer = NotificationCenter.default.addObserver(forName: .shareLink, object: nil, queue: nil) { notification in
            guard let urlString = notification.userInfo?[urlUserInfo] as? String,
                  let title = notification.userInfo?[titleUserInfo] as? String else { return }
            handler(urlString, title)
        }

        return Observer(observer: observer)
    }

}

private extension NSNotification.Name {

    static let shareLink: NSNotification.Name = Notification.Name(rawValue: "com.duckduckgo.notification.shareLink")

}

class TitledURLActivityItem: NSObject, UIActivityItemSource {

    let url: URL
    let title: String

    init(_ url: URL, _ title: String) {
        self.url = url
        self.title = title
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        url
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        url
    }

    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = title
        metadata.url = url
        return metadata
    }

}
