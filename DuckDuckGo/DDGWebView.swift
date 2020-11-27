//
//  DDGWebView.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

import WebKit

class DDGWebView: WKWebView {

    struct GPC {

        static let headerName = "Sec-GPC"
        static let signalOn = "1"

    }

    let appSettings = AppUserDefaults()

    override func load(_ request: URLRequest) -> WKNavigation? {
        var updatedRequest = request

        // No need to worry about removing as the header won't be in the request anyway so
        //  long as this is not called with a reused URLRequest object.
        if appSettings.sendDoNotSell {
            updatedRequest.addValue(GPC.signalOn, forHTTPHeaderField: GPC.headerName)
        }

        return super.load(updatedRequest)
    }

    override func reload() -> WKNavigation? {
        guard let url = url else {
            // returning nil would probably ok here too, but just let WKWebView do its thing
            return super.reload()
        }
        return load(URLRequest(url: url))
    }

}
