//
//  DuckPlayerViewModel.swift
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

import Combine
import Foundation
import UIKit

final class DuckPlayerViewModel: ObservableObject {
    
    /// A publisher to notify when Youtube navigation is required
    let youtubeNavigationRequestPublisher = PassthroughSubject<URL, Never>()
    
    /// Current interface orientation
    @Published private var isLandscape: Bool = false
    @Published private(set) var videoDescription: String = ""
    @Published private(set) var isLoadingDescription: Bool = false
    
    /// Comments
    @Published private(set) var comments: [YouTubeComment] = []
    @Published private(set) var isLoadingComments: Bool = false
    
    /// Currently selected tab
    @Published var selectedTab: Tab = .description {
        didSet {
            // Only fetch comments data if we haven't already
            if selectedTab == .comments && comments.isEmpty && !isLoadingComments {
                fetchComments()
            }
        }
    }
    
    enum Tab {
        case description
        case comments
    }
    
    enum Constants {
        static let baseURL = "https://www.youtube-nocookie.com/embed/"
        
        // Parameters
        static let relParameter = "rel"
        static let playsInlineParameter = "playsinline"
        static let autoplayParameter = "autoplay"
        
        // Values
        static let enabled = "1"
        static let disabled = "0"
    }
    
    var videoID: String
    var appSettings: AppSettings
    @Published private(set) var url: URL?
    let defaultParameters: [String: String] = [
        Constants.relParameter: Constants.disabled,
        Constants.playsInlineParameter: Constants.enabled
    ]
    
    init(videoID: String, appSettings: AppSettings = AppDependencyProvider.shared.appSettings) {
        self.videoID = videoID
        self.appSettings = appSettings
        setupVideoURL()
        fetchVideoDescription()
    }
    
    private func setupVideoURL() {
        if let newURL = getVideoURL() {
            self.url = newURL
            Logger.duckplayer.debug("Set initial video URL to: \(String(describing: self.url))")
        }
    }
    
    func loadVideo() {
        // Update video ID URL without forcing a reload
        if let newURL = getVideoURL() {
            // Only update URL if it's different to prevent unnecessary reloads
            if self.url != newURL {
                self.url = newURL
                Logger.duckplayer.debug("Updated video URL to: \(String(describing: self.url))")
            }
        }
        
        // Fetch new description for the video
        if videoDescription.isEmpty {
            fetchVideoDescription()
        }
    }
    
    private func fetchVideoDescription() {
        Logger.duckplayer.debug("Starting fetchVideoDescription for videoID: \(self.videoID)")
        isLoadingDescription = true
        
        let urlString = "https://www.googleapis.com/youtube/v3/videos?part=snippet&id=\(videoID)&key=KEY"
        guard let url = URL(string: urlString) else {
            Logger.duckplayer.error("Failed to create URL from string: \(urlString)")
            isLoadingDescription = false
            return
        }
        
        Logger.duckplayer.debug("Making API request to: \(url)")
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                Logger.duckplayer.error("API request failed with error: \(error)")
                DispatchQueue.main.async {
                    self?.isLoadingDescription = false
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                Logger.duckplayer.debug("API response status code: \(httpResponse.statusCode)")
            }
            
            DispatchQueue.main.async {
                self?.isLoadingDescription = false
                guard let data = data else {
                    Logger.duckplayer.error("No data received from API")
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    Logger.duckplayer.debug("Received JSON: \(String(describing: json))")
                    
                    guard let items = json?["items"] as? [[String: Any]],
                          let firstItem = items.first,
                          let snippet = firstItem["snippet"] as? [String: Any],
                          let description = snippet["description"] as? String else {
                        Logger.duckplayer.error("Failed to parse JSON response")
                        return
                    }
                    
                    Logger.duckplayer.debug("Successfully parsed description, length: \(description.count)")
                    DispatchQueue.main.async {
                        self?.videoDescription = description
                        self?.parseDescription(description)
                        Logger.duckplayer.debug("Updated videoDescription property")
                    }
                } catch {
                    Logger.duckplayer.error("JSON parsing failed with error: \(error)")
                }
            }
        }.resume()
    }
    
    private func fetchComments() {
        Logger.duckplayer.debug("Starting fetchComments for videoID: \(self.videoID)")
        isLoadingComments = true
        
        let urlString = "https://www.googleapis.com/youtube/v3/commentThreads?part=snippet&videoId=\(videoID)&maxResults=50&order=relevance&key=AIzaSyA69c2ZelhzXWMzqdiw3BTPYY9sHL_UMqI"
        guard let url = URL(string: urlString) else {
            Logger.duckplayer.error("Failed to create comments URL")
            isLoadingComments = false
            return
        }
        
        Logger.duckplayer.debug("Making comments API request to: \(url)")
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                Logger.duckplayer.error("Comments API request failed: \(error)")
                DispatchQueue.main.async {
                    self?.isLoadingComments = false
                }
                return
            }
            
            DispatchQueue.main.async {
                self?.isLoadingComments = false
                guard let data = data else {
                    Logger.duckplayer.error("No comments data received")
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    guard let items = json?["items"] as? [[String: Any]] else {
                        Logger.duckplayer.error("Failed to parse comments JSON")
                        return
                    }
                    
                    let comments = items.compactMap { item -> YouTubeComment? in
                        guard let snippet = item["snippet"] as? [String: Any],
                              let topLevelComment = snippet["topLevelComment"] as? [String: Any],
                              let commentSnippet = topLevelComment["snippet"] as? [String: Any],
                              let id = topLevelComment["id"] as? String,
                              let authorDisplayName = commentSnippet["authorDisplayName"] as? String,
                              let authorProfileImageUrl = commentSnippet["authorProfileImageUrl"] as? String,
                              let textDisplay = commentSnippet["textDisplay"] as? String,
                              let likeCount = commentSnippet["likeCount"] as? Int,
                              let publishedAtString = commentSnippet["publishedAt"] as? String,
                              let publishedAt = ISO8601DateFormatter().date(from: publishedAtString) else {
                            return nil
                        }
                        
                        return YouTubeComment(
                            id: id,
                            authorDisplayName: authorDisplayName,
                            authorProfileImageUrl: authorProfileImageUrl,
                            textDisplay: textDisplay,
                            likeCount: likeCount,
                            publishedAt: publishedAt
                        )
                    }
                    
                    Logger.duckplayer.debug("Successfully parsed \(comments.count) comments")
                    self?.comments = comments
                    
                } catch {
                    Logger.duckplayer.error("Comments JSON parsing failed: \(error)")
                }
            }
        }.resume()
    }
    
    func getVideoURL() -> URL? {
        var parameters = defaultParameters
        parameters[Constants.autoplayParameter] = appSettings.duckPlayerAutoplay ? Constants.enabled : Constants.disabled
        let queryString = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        return URL(string: "\(Constants.baseURL)\(videoID)?\(queryString)")
    }
    
    func handleYouTubeNavigation(_ url: URL) {
        youtubeNavigationRequestPublisher.send(url)
    }
    
    func openInYouTube() {
        let url: URL = .youtube(videoID)
        handleYouTubeNavigation(url)
    }
    
    func onFirstAppear() {
        updateOrientation()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleOrientationChange),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }
    
    func onAppear() {
        // NOOP
    }
    
    func onDisappear() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIDevice.orientationDidChangeNotification,
                                                  object: nil)
    }
    
    private func parseDescription(_ text: String) {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        var result = text
        
        if let detector = detector {
            let matches = detector.matches(in: text, range: NSRange(text.startIndex..., in: text))
            
            // Process matches in reverse order to not invalidate ranges
            for match in matches.reversed() {
                if let range = Range(match.range, in: text),
                   let url = match.url {
                    let urlText = String(text[range])
                    result = result.replacingCharacters(in: range, with: "[\(urlText)](\(url))")
                }
            }
        }
        
        videoDescription = result
    }
    
    @objc private func handleOrientationChange() {
        updateOrientation()
    }
    
    /// Updates the current interface orientation
    func updateOrientation() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            isLandscape = windowScene.interfaceOrientation.isLandscape
        }
    }
    
    /// Whether the YouTube button should be visible
    var shouldShowYouTubeButton: Bool {
        !isLandscape
    }
}

struct YouTubeComment: Identifiable {
    let id: String
    let authorDisplayName: String
    let authorProfileImageUrl: String
    let textDisplay: String
    let likeCount: Int
    let publishedAt: Date
}
