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
    
    let videoID: String
    var appSettings: AppSettings
    @Published private(set) var url: URL?
    let defaultParameters: [String: String] = [
        Constants.relParameter: Constants.disabled,
        Constants.playsInlineParameter: Constants.enabled
    ]
    
    init(videoID: String, appSettings: AppSettings = AppDependencyProvider.shared.appSettings) {
        self.videoID = videoID
        self.appSettings = appSettings
        self.url = getVideoURL()
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
