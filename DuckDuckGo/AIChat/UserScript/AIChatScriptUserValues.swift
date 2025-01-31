//
//  AIChatScriptUserValues.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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

public struct AIChatNativeHandoffData: Codable {
    let isAIChatHandoffEnabled: Bool
    let platform: String
    let aiChatPayload: AIChatPayload?

    enum CodingKeys: String, CodingKey {
        case isAIChatHandoffEnabled
        case platform
        case aiChatPayload
    }

    init(isAIChatHandoffEnabled: Bool, platform: String, aiChatPayload: [String: Any]?) {
        self.isAIChatHandoffEnabled = isAIChatHandoffEnabled
        self.platform = platform
        self.aiChatPayload = aiChatPayload
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isAIChatHandoffEnabled = try container.decode(Bool.self, forKey: .isAIChatHandoffEnabled)
        platform = try container.decode(String.self, forKey: .platform)

        if let aiChatPayloadData = try? container.decodeIfPresent(Data.self, forKey: .aiChatPayload) {
            aiChatPayload = try JSONSerialization.jsonObject(with: aiChatPayloadData, options: []) as? AIChatPayload
        } else {
            aiChatPayload = nil
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isAIChatHandoffEnabled, forKey: .isAIChatHandoffEnabled)
        try container.encode(platform, forKey: .platform)

        if let aiChatPayload = aiChatPayload,
           let data = try? JSONSerialization.data(withJSONObject: aiChatPayload, options: []),
           let jsonString = String(data: data, encoding: .utf8) {
            try container.encode(jsonString, forKey: .aiChatPayload)
        } else {
            try container.encodeNil(forKey: .aiChatPayload)
        }
    }
}

public struct AIChatNativeConfigValues: Codable {
    let isAIChatHandoffEnabled: Bool
    let platform: String
}
