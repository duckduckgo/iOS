//
//  DuckPlayer.swift
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

import Common
import Foundation
import WebKit
import UserScript

import Core

enum DuckPlayerMode: Equatable, Codable {
    case enabled, alwaysAsk, disabled

    init(_ duckPlayerMode: Bool?) {
        switch duckPlayerMode {
        case true:
            self = .enabled
        case false:
            self = .disabled
        default:
            self = .alwaysAsk
        }
    }

    var boolValue: Bool? {
        switch self {
        case .enabled:
            return true
        case .alwaysAsk:
            return nil
        case .disabled:
            return false
        }
    }

}

/// Values that the Frontend can use to determine the current state.
public struct UserValues: Codable {
    enum CodingKeys: String, CodingKey {
        case duckPlayerMode = "privatePlayerMode"
        case overlayInteracted
    }
    let duckPlayerMode: DuckPlayerMode
    let overlayInteracted: Bool
}

final class DuckPlayer {
    static let usesSimulatedRequests: Bool = {
            return true
    }()

    static let duckPlayerHost: String = "player"
    static let commonName = "Duck Player"

    static let shared = DuckPlayer()

    var isAvailable: Bool = true
    var mode: DuckPlayerMode = .enabled
    var overlayInteracted: Bool = true
    

    init() {
        mode = .enabled
    }

    // MARK: - Common Message Handlers

    public func handleGetUserValues(params: Any, message: UserScriptMessage) -> Encodable? {
        encodeUserValues()
    }

    private func encodeUserValues() -> UserValues {
        UserValues(
            duckPlayerMode: .enabled,
            overlayInteracted: true
        )
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    public func handleSetUserValuesMessage(
        from origin: YoutubeOverlayUserScript.MessageOrigin
    ) -> (_ params: Any, _ message: UserScriptMessage) -> Encodable? {

        return { [weak self] params, _ -> Encodable? in
            guard let self else {
                return nil
            }
            guard let userValues: UserValues = DecodableHelper.decode(from: params) else {
                // assertionFailure("YoutubeOverlayUserScript: expected JSON representation of UserValues")
                return nil
            }

            return self.encodeUserValues()
        }
    }

    // MARK: - Private

    private static let websiteTitlePrefix = "\(commonName) - "
}

// MARK: - Privacy Feed

extension DuckPlayer {

    func domainForRecentlyVisitedSite(with url: URL) -> String? {
        guard isAvailable, mode != .disabled else {
            return nil
        }

        return url.isDuckPlayer ? DuckPlayer.commonName : nil
    }

    func sharingData(for title: String, url: URL) -> (title: String, url: URL)? {
        guard isAvailable, mode != .disabled, url.isDuckURLScheme, let (videoID, timestamp) = url.youtubeVideoParams else {
            return nil
        }

        let title = title.dropping(prefix: Self.websiteTitlePrefix)
        let sharingURL = URL.youtube(videoID, timestamp: timestamp)

        return (title, sharingURL)
    }

    
}
