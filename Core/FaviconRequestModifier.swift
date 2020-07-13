//
//  FaviconRequestModifier.swift
//  Core
//
//  Created by Christopher Brind on 13/07/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import Kingfisher

class FaviconRequestModifier: ImageDownloadRequestModifier {

    func modified(for request: URLRequest) -> URLRequest? {
        var r = request
        UserAgentManager.shared.update(request: &r, isDesktop: false)
        return r
    }

}
