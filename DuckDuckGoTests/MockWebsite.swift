//
//  MockWebsite.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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

class MockWebsite {

    struct EmbeddedResource {
        enum ResourceType {
            case image
            case script
        }

        let type: ResourceType
        let url: URL
    }

    let resources: [EmbeddedResource]

    init(resources: [EmbeddedResource]) {
        self.resources = resources
    }

    var htmlRepresentation: String {

        var content = ""

        for resource in resources {
            switch resource.type {
            case .image:
                content += "<img src=\"\(resource.url.absoluteURL)\">\n"
            case .script:
                content += "<script type=\"text/javascript\" src=\"\(resource.url.absoluteURL)\"></script>"
            }
        }

        return """
            <!DOCTYPE html>
            <html>
            <body>
                <h1>Test Page</h1>
                \(content)
            </body>
            </html>
            """
    }
}
