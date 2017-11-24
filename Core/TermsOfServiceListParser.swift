//
//  TermsOfServiceListParser.swift
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
import SwiftyJSON


public class TermsOfServiceListParser {
    
    public init() {}
    
    func convert(fromJsonData data: Data) throws -> [String: TermsOfService] {
        guard let json = try? JSON(data: data) else {
            throw JsonError.invalidJson
        }
        return try convertList(fromJson: json)
    }

    private func convertList(fromJson json: JSON) throws -> [String: TermsOfService] {
        var dict = [String: TermsOfService]()
        for (key, termsJson) in json {
            let terms = try convertTerms(fromJson: termsJson)
            dict[key] = terms
        }
        return dict
    }
    
    private func convertTerms(fromJson json: JSON) throws -> TermsOfService {
        var classification: TermsOfService.Classification? = nil
        if let classificationString = json["class"].string?.lowercased() {
            classification = TermsOfService.Classification(rawValue: classificationString)
        }
        guard let score = json["score"].int else { throw JsonError.typeMismatch }
        let goodReasons = json["all"]["good"].arrayObject as? [String] ?? []
        let badReasons = json["all"]["bad"].arrayObject as? [String] ?? []
        return TermsOfService(classification: classification, score: score, goodReasons: goodReasons, badReasons: badReasons)
    }

}
