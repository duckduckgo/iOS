//
//  DuckPlayerURLExtension.swift
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
import Core

extension String {
    
    var url: URL? {
        return URL(trimmedAddressBarString: self)
    }
}

extension URL {
    
    static let duckPlayerHost: String = "player"

    static func duckPlayer(_ videoID: String, timestamp: String? = nil) -> URL {
        let url = "\(NavigationalScheme.duck.rawValue)://player/\(videoID)".url!
        return url.addingTimestamp(timestamp)
    }

    static func youtubeNoCookie(_ videoID: String, timestamp: String? = nil) -> URL {
        let url = "https://www.youtube-nocookie.com/embed/\(videoID)".url!
        return url.addingTimestamp(timestamp)
    }

    static func youtube(_ videoID: String, timestamp: String? = nil) -> URL {
            #if os(iOS)
            let baseUrl = "https://m.youtube.com/watch?v=\(videoID)"
            #else
            let baseUrl = "https://www.youtube.com/watch?v=\(videoID)"
            #endif

            let url = URL(string: baseUrl)!
            return url.addingTimestamp(timestamp)
    }

    var isDuckURLScheme: Bool {
        navigationalScheme == .duck
    }

    private var isYoutubeWatch: Bool {
        guard let host else { return false }
        return host.contains("youtube.com") && path == "/watch"
    }

    private var isYoutubeNoCookie: Bool {
        host == "www.youtube-nocookie.com" && pathComponents.count == 3 && pathComponents[safe: 1] == "embed"
    }
    
    /// Returns true only if the URL represents a playlist itself, i.e. doesn't have `index` query parameter
    var isYoutubePlaylist: Bool {
        guard isYoutubeWatch, let components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return false
        }

        let isPlaylistURL = components.queryItems?.contains(where: { $0.name == "list" }) == true &&
        components.queryItems?.contains(where: { $0.name == "v" }) == true &&
        components.queryItems?.contains(where: { $0.name == "index" }) == false

        return isPlaylistURL
    }
    
    /// Returns true if the URL represents a YouTube video, but not the playlist (playlists are not supported by Private Player)
    var isYoutubeVideo: Bool {
        isYoutubeWatch && !isYoutubePlaylist
    }
    
    /// Attempts extracting video ID and timestamp from the URL. Works with all types of YouTube URLs.
    var youtubeVideoParams: (videoID: String, timestamp: String?)? {
        if isDuckURLScheme {
            guard let components = URLComponents(string: absoluteString) else {
                return nil
            }
            let unsafeVideoID = components.path
            let timestamp = components.queryItems?.first(where: { $0.name == "t" })?.value
            return (unsafeVideoID.removingCharacters(in: .youtubeVideoIDNotAllowed), timestamp)
        }

        if isDuckPlayer {
            let unsafeVideoID = lastPathComponent
            let timestamp = getParameter(named: "t")
            return (unsafeVideoID.removingCharacters(in: .youtubeVideoIDNotAllowed), timestamp)
        }

        guard isYoutubeVideo,
              let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let unsafeVideoID = components.queryItems?.first(where: { $0.name == "v" })?.value
        else {
            return nil
        }

        let timestamp = components.queryItems?.first(where: { $0.name == "t" })?.value
        return (unsafeVideoID.removingCharacters(in: .youtubeVideoIDNotAllowed), timestamp)
    }
    
    
    var isDuckPlayer: Bool {
        let isPrivatePlayer = isDuckURLScheme && host == Self.duckPlayerHost
        return isPrivatePlayer || isYoutubeNoCookie
        
    }
    
    var isYoutube: Bool {
        guard let host else { return false }
        return host == "m.youtube.com" || host == "youtube.com"
        
    }
    
    func addingWatchInYoutubeQueryParameter() -> URL? {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return nil
        }
        
        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: "embeds_referring_euri", value: "some_value"))
        components.queryItems = queryItems
        
        return components.url
    }
    
    var hasWatchInYoutubeQueryParameter: Bool {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return false
        }
        
        for queryItem in queryItems where queryItem.name == "embeds_referring_euri" {
            return true
        }
        
        return false
    }
    
    private func addingTimestamp(_ timestamp: String?) -> URL {
        guard let timestamp = timestamp,
              let regex = try? NSRegularExpression(pattern: "^(\\d+[smh]?)+$"),
              timestamp.matches(regex)
        else {
            return self
        }
        return appendingParameter(name: "t", value: timestamp)
    }
}

extension CharacterSet {
    static let youtubeVideoIDNotAllowed = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_").inverted
}
