//
//  NSManagedObjectContextExtension.swift
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

import CoreData
import Persistence

extension Array where Element == CoreDataErrorsParser.ErrorInfo {
    
    var errorPixelParameters: [String: String] {
        let params: [String: String]
        if let first = first {
            params = [PixelParameters.errorCount: "\(count)",
                      PixelParameters.coreDataErrorCode: "\(first.code)",
                      PixelParameters.coreDataErrorDomain: first.domain,
                      PixelParameters.coreDataErrorEntity: first.entity ?? "empty",
                      PixelParameters.coreDataErrorAttribute: first.property ?? "empty"]
        } else {
            params = [PixelParameters.errorCount: "\(count)"]
        }
        return params
    }
}

extension NSManagedObjectContext {
    
    public func save(onErrorFire event: Pixel.Event) throws {
        do {
            try save()
        } catch {
            let nsError = error as NSError
            let processedErrors = CoreDataErrorsParser.parse(error: nsError)
            
            Pixel.fire(pixel: event,
                       error: error,
                       withAdditionalParameters: processedErrors.errorPixelParameters)
            
            throw error
        }
    }
}
