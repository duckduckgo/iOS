//
//  FavoriteSearchResultDecorator.swift
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

import Foundation
import LinkPresentation
import UniformTypeIdentifiers

struct FavoriteSearchResultDecorator {
    func decorate(results: [WebPageSearchResultValue]) async -> [WebPageSearchResultValue] {
        return await withTaskGroup(of: WebPageSearchResultValue.self, returning: [WebPageSearchResultValue].self) { group in
            for result in results {
                let isAdded = group.addTaskUnlessCancelled {
                    let provider = LPMetadataProvider()
                    let metadata = try? await provider.startFetchingMetadata(for: result.url)

                    guard let metadata else {
                        return result
                    }

                    let name = metadata.title ?? result.name
                    var icon: UIImage?
                    if let provider = metadata.iconProvider {
                        icon = try? await self.getIcon(using: provider)
                    }

                    return WebPageSearchResultValue(id: result.id, name: name, displayUrl: result.displayUrl, url: result.url, icon: icon)
                }

                if !isAdded {
                    return results
                }
            }

            var decoratedResults: [WebPageSearchResultValue] = []
            for await taskResult in group {
                decoratedResults.append(taskResult)
            }

            return decoratedResults
        }
    }

    private func getIcon(using provider: NSItemProvider) async throws -> UIImage? {
        guard let data = try await provider.loadItem(forTypeIdentifier: UTType.image.identifier) as? Data else { return nil }
        let image = UIImage(data: data)
        return image
    }
}
