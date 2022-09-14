//
//  ReaderModeServer.swift
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
import Swifter
import Core

final class ReaderModeServer {
    public static let shared = ReaderModeServer()

    private let server = HttpServer()
    var style = ReaderModeStyle.default

    private init() {
        register(fileName: "/Reader.css")
        server.notFoundHandler = self.handleRequest(_:)

        try? server.start(8081)
    }

    private func register(fileName: String, contentType: String? = nil) {
        self.server[fileName] = { _ in
            let url = Bundle(for: Self.self).url(forResource: fileName, withExtension: nil)!
            let data = (try? Data(contentsOf: url))!
            return .ok(.data(data, contentType: contentType))
        }
    }

    private func handleRequest(_ request: HttpRequest) -> HttpResponse {
        guard request.path == AppUrls.readerPath,
              let readabilityURL = request.queryParams.first(where: { key, _ in key == "url" }).flatMap({ URL(string: $0.1.removingPercentEncoding!) })
        else {
            return .badRequest(nil)
        }
        guard let readabilityResult = try? ReaderModeCache.shared.readabilityResult(for: readabilityURL) else {
            return .notFound
        }

        let stylePath = Bundle.main.path(forResource: "Reader", ofType: "css")!
        let css = (try? String(contentsOfFile: stylePath, encoding: .utf8))!
        let tmplURL = Bundle.main.url(forResource: "Reader", withExtension: "html")!
        let tmpl = (try? NSMutableString(contentsOf: tmplURL, encoding: NSUTF8StringEncoding))!

        tmpl.replaceOccurrences(of: "%READER-CSS%", with: css, options: .literal, range: NSRange(location: 0, length: tmpl.length))
        tmpl.replaceOccurrences(of: "%READER-STYLE%", with: style.encode(), options: .literal, range: NSRange(location: 0, length: tmpl.length))
        tmpl.replaceOccurrences(of: "%READER-DOMAIN%", with: simplifyDomain(readabilityResult.domain), options: .literal, range: NSRange(location: 0, length: tmpl.length))
        tmpl.replaceOccurrences(of: "%READER-URL%", with: readabilityResult.url, options: .literal, range: NSRange(location: 0, length: tmpl.length))
        tmpl.replaceOccurrences(of: "%READER-TITLE%", with: readabilityResult.title, options: .literal, range: NSRange(location: 0, length: tmpl.length))
        tmpl.replaceOccurrences(of: "%READER-CREDITS%", with: readabilityResult.credits, options: .literal, range: NSRange(location: 0, length: tmpl.length))
        tmpl.replaceOccurrences(of: "%READER-CONTENT%", with: readabilityResult.content, options: .literal, range: NSRange(location: 0, length: tmpl.length))

        return .ok(.html(tmpl as String))
    }

    static let DomainPrefixesToSimplify = ["www.", "mobile.", "m.", "blog."]
    private func simplifyDomain(_ domain: String) -> String {
        return Self.DomainPrefixesToSimplify.first { domain.hasPrefix($0) }.map {
            String($0[$0.index($0.startIndex, offsetBy: $0.count)...])
        } ?? domain
    }


}
