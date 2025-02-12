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

import BrowserServicesKit
import Common
import Combine
import Foundation
import WebKit
import UserScript
import Core
import ContentScopeScripts
import SwiftUI

/// Values that the frontend can use to determine the current state.
struct InitialPlayerSettings: Codable {
    struct PlayerSettings: Codable {
        let pip: PIP
    }

    struct PIP: Codable {
        let status: Status
    }
    
    struct Platform: Codable {
        let name: String
    }

    enum Status: String, Codable {
        case enabled
        case disabled
    }
    
    enum Environment: String, Codable {
        case development
        case production
    }

    let userValues: UserValues
    let ui: UIValues
    let settings: PlayerSettings
    let platform: Platform
    let locale: String
    let localeStrings: String?
}

/// Values that the frontend can use to determine user settings.
public struct UserValues: Codable {
    enum CodingKeys: String, CodingKey {
        case duckPlayerMode = "privatePlayerMode"
        case askModeOverlayHidden = "overlayInteracted"
    }
    let duckPlayerMode: DuckPlayerMode
    let askModeOverlayHidden: Bool
}

/// UI-related values for the frontend.
public struct UIValues: Codable {
    enum CodingKeys: String, CodingKey {
        case allowFirstVideo
    }
    let allowFirstVideo: Bool
}

// Wrapper to allow sibling properties on each event in the future.
struct TelemetryEvent: Decodable {
    let attributes: Attributes
}

// This is the first example of a new telemetry event
struct ImpressionAttributes: Decodable {
    enum Layout: String, Decodable {
        case landscape = "landscape-layout"
    }

    let name: String
    let value: Layout
}

// Designed to represent the discriminated union used by the FE (where all events are schema-driven)
enum Attributes: Decodable {

    // more events can be added here later, without needing a new handler
    case impression(ImpressionAttributes)

    private enum CodingKeys: String, CodingKey {
        case name
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)

        switch name {
        case "impression":
            let attributes = try ImpressionAttributes(from: decoder)
            self = .impression(attributes)

        default:
            throw DecodingError.dataCorruptedError(
                forKey: .name,
                in: container,
                debugDescription: "Unknown name value: \(name)"
            )
        }
    }
}


/// Protocol defining the Duck Player functionality.
protocol DuckPlayerControlling: AnyObject {
    
    /// The current Duck Player settings.
    var settings: DuckPlayerSettings { get }
    
    /// The host view controller, if any.
    var hostView: TabViewController? { get }
        
    // Navigation Request Publisher to notify when DuckPlayer needs direct Youtube Nav
    var youtubeNavigationRequest: PassthroughSubject<URL, Never> { get }
    
    /// Initializes a new instance of DuckPlayer with the provided settings and feature flagger.
    ///
    /// - Parameters:
    ///   - settings: The Duck Player settings.
    ///   - featureFlagger: The feature flag manager.
    init(settings: DuckPlayerSettings, featureFlagger: FeatureFlagger)

    /// Sets user values received from the web content.
    ///
    /// - Parameters:
    ///   - params: Parameters from the web content.
    ///   - message: The script message containing the parameters.
    /// - Returns: An optional `Encodable` response.
    func setUserValues(params: Any, message: WKScriptMessage) -> Encodable?
    
    /// Retrieves user values to send to the web content.
    ///
    /// - Parameters:
    ///   - params: Parameters from the web content.
    ///   - message: The script message containing the parameters.
    /// - Returns: An optional `Encodable` response.
    func getUserValues(params: Any, message: WKScriptMessage) -> Encodable?
    
    /// Opens a video in Duck Player within the specified web view.
    ///
    /// - Parameters:
    ///   - url: The URL of the video.
    ///   - webView: The web view to load the video in.
    func openVideoInDuckPlayer(url: URL, webView: WKWebView)
    
    /// Opens Duck Player settings.
    ///
    /// - Parameters:
    ///   - params: Parameters from the web content.
    ///   - message: The script message containing the parameters.
    func openDuckPlayerSettings(params: Any, message: WKScriptMessage) async -> Encodable?
    
    /// Opens Duck Player information modal.
    ///
    /// - Parameters:
    ///   - params: Parameters from the web content.
    ///   - message: The script message containing the parameters.
    func openDuckPlayerInfo(params: Any, message: WKScriptMessage) async -> Encodable?
    
    /// Sends a telemetry event from the FE.
    ///
    /// - Parameters:
    ///   - params: Parameters from the web content.
    ///   - message: The script message containing the parameters.
    func telemetryEvent(params: Any, message: WKScriptMessage) async -> Encodable?
    
    /// Performs initial setup for the player.
    ///
    /// - Parameters:
    ///   - params: Parameters from the web content.
    ///   - message: The script message containing the parameters.
    /// - Returns: An optional `Encodable` response.
    func initialSetupPlayer(params: Any, message: WKScriptMessage) async -> Encodable?
    
    /// Performs initial setup for the overlay.
    ///
    /// - Parameters:
    ///   - params: Parameters from the web content.
    ///   - message: The script message containing the parameters.
    /// - Returns: An optional `Encodable` response.
    func initialSetupOverlay(params: Any, message: WKScriptMessage) async -> Encodable?
    
    /// Sets the host view controller for presenting modals.
    ///
    /// - Parameter vc: The view controller to set as host.
    func setHostViewController(_ vc: TabViewController)

    /// Loads a native DuckPlayerView
    func loadNativeDuckPlayerVideo(videoID: String)
}

/// Implementation of the DuckPlayerControlling.
final class DuckPlayer: NSObject, DuckPlayerControlling {
    
    struct Constants {
        static let duckPlayerHost: String = "player"
        static let commonName = "Duck Player"
        static let translationFile = "duckplayer"
        static let translationFileExtension = "json"
        static let defaultLocale = "en"
        static let translationPath = "pages/duckplayer/locales/"
        static let featureNameKey = "featureName"
        static let landscapeUIAutohideDelay: CGFloat = 4.0
        static let chromeShowHideAnimationDuration: CGFloat = 0.4
    }
    
    
    private(set) var settings: DuckPlayerSettings
    private(set) weak var hostView: TabViewController?
    
    private var featureFlagger: FeatureFlagger
    private var hideBrowserChromeTimer: Timer?
    private var tapGestureRecognizer: UITapGestureRecognizer?
    
    private lazy var localeStrings: String? = {
        let languageCode = Locale.current.languageCode ?? Constants.defaultLocale
        if let localizedFile = ContentScopeScripts.Bundle.path(forResource: Constants.translationFile,
                                                               ofType: Constants.translationFileExtension,
                                                               inDirectory: "\(Constants.translationPath)\(languageCode)") {
            return try? String(contentsOfFile: localizedFile)
        }
        return nil
    }()
    
    private struct WKMessageData: Codable {
        var context: String?
        var featureName: String?
        var method: String?
    }
    
    private enum FeatureName: String {
        case page = "duckPlayerPage"
        case overlay = "duckPlayer"
    }
    
    // A published subject to notify when a Youtube navigation request is needed
    var youtubeNavigationRequest: PassthroughSubject<URL, Never>
    
    /// Initializes a new instance of DuckPlayer with the provided settings and feature flagger.
    ///
    /// - Parameters:
    ///   - settings: The Duck Player settings.
    ///   - featureFlagger: The feature flag manager.
    init(settings: DuckPlayerSettings = DuckPlayerSettingsDefault(),
         featureFlagger: FeatureFlagger = AppDependencyProvider.shared.featureFlagger) {
        self.settings = settings
        self.featureFlagger = featureFlagger
        self.youtubeNavigationRequest = PassthroughSubject<URL, Never>()
        super.init()
        registerOrientationSubscriber()
    }
    
    deinit {
        // Only remove our specific tap gesture recognizer
        if let tapGestureRecognizer = tapGestureRecognizer {
            hostView?.view.removeGestureRecognizer(tapGestureRecognizer)
        }
        hostView = nil
        cancellables.removeAll()
    }
    
    /// Sets the host view controller for presenting modals.
    ///
    /// - Parameter vc: The view controller to set as host.
    public func setHostViewController(_ vc: TabViewController) {
        hostView = vc
    }
    
    private func addTapGestureRecognizer() {
        guard let hostView = hostView,
              tapGestureRecognizer == nil,
              let url = hostView.url,
              url.isDuckPlayer else {
            return
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.delegate = self
        hostView.view.addGestureRecognizer(tapGesture)
        tapGestureRecognizer = tapGesture
    }
    
    private func removeTapGestureRecognizer() {
        if let tapGestureRecognizer = tapGestureRecognizer {
            hostView?.view.removeGestureRecognizer(tapGestureRecognizer)
            self.tapGestureRecognizer = nil
        }
    }
    
    /// Handles tap gestures in the hostViewController
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        if let url = hostView?.url, url.isDuckPlayer {
            let orientation = UIDevice.current.orientation
            if orientation.isLandscape {
                hostView?.chromeDelegate?.setBarsHidden(false, animated: true, customAnimationDuration: Constants.chromeShowHideAnimationDuration)
                setupHideBrowserChromeTimer()
            }
        }
    }
    
    /// Sets up a hide timer for the navigation and toolbars when the user is in landscape mode
    private func setupHideBrowserChromeTimer() {
        // Invalidate existing timer if any
        hideBrowserChromeTimer?.invalidate()
        
        // Create new timer
        hideBrowserChromeTimer = Timer.scheduledTimer(withTimeInterval: Constants.landscapeUIAutohideDelay, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                let orientation = UIDevice.current.orientation
                if orientation.isLandscape {
                    self?.hostView?.chromeDelegate?.setBarsHidden(true, animated: true, customAnimationDuration: Constants.chromeShowHideAnimationDuration)
                }
            }
        }
    }

    // Loads a native DuckPlayerView
    private var cancellables = Set<AnyCancellable>()
    private var currentPlayerController: UIHostingController<DuckPlayerView>?
    @Published private var isLargeDetent: Bool = false
        
    func loadNativeDuckPlayerVideo(videoID: String) {
        Logger.duckplayer.debug("Starting loadNativeDuckPlayerVideo with ID: \(videoID)")
        
        let viewModel = DuckPlayerViewModel(videoID: videoID)
        
        guard let url = viewModel.getVideoURL() else {
            Logger.duckplayer.debug("Failed to get video URL for ID: \(videoID)")
            return
        }
        
        // Check if we have an existing controller that's still presented
        if let existingController = currentPlayerController,
           existingController.presentingViewController != nil {
            // Update existing player with new video
            Logger.duckplayer.debug("Updating existing player with videoID: \(videoID)")
            if let currentView = existingController.rootView as? DuckPlayerView {
                currentView.viewModel.videoID = videoID
                currentView.viewModel.loadVideo()
            }
            
            // Update navigation subscription
            viewModel.youtubeNavigationRequestPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self, weak existingController] url in
                    Logger.duckplayer.debug("Received YouTube navigation request: \(url)")
                    self?.youtubeNavigationRequest.send(url)
                    existingController?.dismiss(animated: true)
                }
                .store(in: &cancellables)
        } else {
            // Create new player controller
            Logger.duckplayer.debug("Creating new player for videoID: \(videoID)")
            let webView = DuckPlayerWebView(viewModel: viewModel)
            let duckPlayerView = DuckPlayerView(viewModel: viewModel, webView: webView, isLargeDetent: Binding(get: { self.isLargeDetent }, set: { self.isLargeDetent = $0 }))
            let hostingController = UIHostingController(rootView: duckPlayerView)
            
            // Configure presentation style for interactive sheet
            hostingController.modalPresentationStyle = .pageSheet
            hostingController.isModalInPresentation = false
            
            if #available(iOS 16.0, *) {
                if let sheet = hostingController.sheetPresentationController {
                    sheet.detents = [.custom(identifier: .init("small")) { _ in return 320 }, .large()]
                    sheet.prefersGrabberVisible = true
                    sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                    sheet.prefersEdgeAttachedInCompactHeight = true
                    sheet.preferredCornerRadius = 10
                    sheet.largestUndimmedDetentIdentifier = .init("small")
                    
                    // Add delegate to handle dismissal
                    sheet.delegate = self
                }
            }
            
            // Subscribe to navigation requests
            viewModel.youtubeNavigationRequestPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self, weak hostingController] url in
                    Logger.duckplayer.debug("Received YouTube navigation request: \(url)")
                    self?.youtubeNavigationRequest.send(url)
                    hostingController?.dismiss(animated: true)
                }
                .store(in: &cancellables)
            
            currentPlayerController = hostingController
            hostView?.present(hostingController, animated: true)
        }
    }


    // MARK: - Common Message Handlers

    /// Sets user values received from the web content.
    ///
    /// - Parameters:
    ///   - params: Parameters from the web content.
    ///   - message: The script message containing the parameters.
    /// - Returns: An optional `Encodable` response.
    public func setUserValues(params: Any, message: WKScriptMessage) -> Encodable? {
        guard let userValues: UserValues = DecodableHelper.decode(from: params) else {
            assertionFailure("DuckPlayer: expected JSON representation of UserValues")
            return nil
        }
        
        Task {
            // Fire pixels for analytics
            await firePixels(message: message, userValues: userValues)
            
            // Update settings based on user values
            await updateSettings(userValues: userValues)
        }
        return userValues
    }
    
    /// Updates Duck Player settings based on user values.
    ///
    /// - Parameter userValues: The user values to update settings with.
    private func updateSettings(userValues: UserValues) async {
        settings.setMode(userValues.duckPlayerMode)
        settings.setAskModeOverlayHidden(userValues.askModeOverlayHidden)
    }
    
    /// Registers an Nootification observer for orientation changes
    private func registerOrientationSubscriber() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(orientationDidChange),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }

    /// Called when the Orientation notification is changed
    @objc private func orientationDidChange() {
        let orientation = UIDevice.current.orientation
        if let url = hostView?.url, url.isDuckPlayer {
            handleOrientationChange(orientation)
        }
    }
    
    /// Handles UI Updates based on orientation.  When switching to landscape, we hide
    /// Navigation and Tabbar to enable "Fake" full screen mode.
    private func handleOrientationChange(_ orientation: UIDeviceOrientation) {
        guard UIDevice.current.userInterfaceIdiom == .phone else { return }
        
        switch orientation {
        case .portrait, .portraitUpsideDown:
            handlePortraitOrientation()
            removeTapGestureRecognizer()
        case .landscapeLeft, .landscapeRight:
            handleLandscapeOrientation()
            addTapGestureRecognizer()
        case .unknown, .faceUp, .faceDown:
            handleDefaultOrientation()
            removeTapGestureRecognizer()
        @unknown default:
            return
        }
    }
    
    /// Handle Portrait rotation
    private func handlePortraitOrientation() {
        hostView?.chromeDelegate?.omniBar.resignFirstResponder()
        hostView?.chromeDelegate?.setBarsHidden(false, animated: true, customAnimationDuration: nil)
        hideBrowserChromeTimer?.invalidate()
        hideBrowserChromeTimer = nil
        hostView?.setupWebViewForPortraitVideo()
    }
    
    /// Handle Landscape rotation
    private func handleLandscapeOrientation() {
        hostView?.chromeDelegate?.omniBar.resignFirstResponder()
        hostView?.setupWebViewForLandscapeVideo()
        hostView?.chromeDelegate?.setBarsHidden(true, animated: true, customAnimationDuration: Constants.chromeShowHideAnimationDuration)
    }
    
    /// Default rotation should be portrait mode
    private func handleDefaultOrientation() {
        hostView?.setupWebViewForPortraitVideo()
    }
    
    /// Retrieves user values to send to the web content.
    ///
    /// - Parameters:
    ///   - params: Parameters from the web content.
    ///   - message: The script message containing the parameters.
    /// - Returns: An optional `Encodable` response.
    public func getUserValues(params: Any, message: WKScriptMessage) -> Encodable? {
        if featureFlagger.isFeatureOn(.duckPlayer) {
            return encodeUserValues()
        }
        return nil
    }
    
    /// Opens a video in Duck Player within the specified web view.
    ///
    /// - Parameters:
    ///   - url: The URL of the video.
    ///   - webView: The web view to load the video in.
    @MainActor
    public func openVideoInDuckPlayer(url: URL, webView: WKWebView) {
        webView.load(URLRequest(url: url))
    }

    /// Performs initial setup for the player.
    ///
    /// - Parameters:
    ///   - params: Parameters from the web content.
    ///   - message: The script message containing the parameters.
    /// - Returns: An optional `Encodable` response.
    @MainActor
    public func initialSetupPlayer(params: Any, message: WKScriptMessage) async -> Encodable? {
        let webView = message.webView
        return await self.encodedPlayerSettings(with: webView)
    }
    
    /// Performs initial setup for the overlay.
    ///
    /// - Parameters:
    ///   - params: Parameters from the web content.
    ///   - message: The script message containing the parameters.
    /// - Returns: An optional `Encodable` response.
    @MainActor
    public func initialSetupOverlay(params: Any, message: WKScriptMessage) async -> Encodable? {
        let webView = message.webView
        return await self.encodedPlayerSettings(with: webView)
    }
    
    /// Opens Duck Player settings.
    ///
    /// - Parameters:
    ///   - params: Parameters from the web content.
    ///   - message: The script message containing the parameters.
    public func openDuckPlayerSettings(params: Any, message: WKScriptMessage) async -> Encodable? {
        NotificationCenter.default.post(
            name: .settingsDeepLinkNotification,
            object: SettingsViewModel.SettingsDeepLinkSection.duckPlayer,
            userInfo: nil
        )
        return nil
    }
    
    /// Sends a telemetry event from the FE.
    ///
    /// - Parameters:
    ///   - params: Parameters from the web content.
    ///   - message: The script message containing the parameters.
    @MainActor
    public func telemetryEvent(params: Any, message: WKScriptMessage) async -> Encodable? {
        // Not currently accepting any telemetry events
        return nil
    }
    
    /// Opens Duck Player information modal.
    ///
    /// - Parameters:
    ///   - params: Parameters from the web content.
    ///   - message: The script message containing the parameters.
    @MainActor
    public func openDuckPlayerInfo(params: Any, message: WKScriptMessage) async -> Encodable? {
        guard let body = message.body as? [String: Any],
              let featureNameString = body[Constants.featureNameKey] as? String,
              let featureName = FeatureName(rawValue: featureNameString) else {
            return nil
        }
        let context: DuckPlayerModalPresenter.PresentationContext = featureName == .page ? .youtube : .SERP
        presentDuckPlayerInfo(context: context)
        return nil
    }

    /// Presents the Duck Player info modal.
    ///
    /// - Parameter context: The presentation context for the modal.
    @MainActor
    public func presentDuckPlayerInfo(context: DuckPlayerModalPresenter.PresentationContext) {
        guard let hostView else { return }
        DuckPlayerModalPresenter(context: context).presentDuckPlayerFeatureModal(on: hostView)
    }
    
    /// Encodes user values for sending to the web content.
    ///
    /// - Returns: An instance of `UserValues`.
    private func encodeUserValues() -> UserValues {
        return UserValues(
            duckPlayerMode: featureFlagger.isFeatureOn(.duckPlayer) ? settings.mode : .disabled,
            askModeOverlayHidden: settings.askModeOverlayHidden
        )
    }
    
    /// Encodes UI values for sending to the web content.
    ///
    /// - Returns: An instance of `UIValues`.
    private func encodeUIValues() -> UIValues {
        UIValues(
            allowFirstVideo: settings.allowFirstVideo
        )
    }

    /// Prepares and encodes player settings to send to the web content.
    ///
    /// - Parameter webView: The web view to check for PiP capability.
    /// - Returns: An instance of `InitialPlayerSettings`.
    @MainActor
    private func encodedPlayerSettings(with webView: WKWebView?) async -> InitialPlayerSettings {
        let isPiPEnabled = webView?.configuration.allowsPictureInPictureMediaPlayback == true
        let pip = InitialPlayerSettings.PIP(status: isPiPEnabled ? .enabled : .disabled)
        let platform = InitialPlayerSettings.Platform(name: "ios")
        let locale = Locale.current.languageCode ?? "en"
        let playerSettings = InitialPlayerSettings.PlayerSettings(pip: pip)
        let userValues = encodeUserValues()
        let uiValues = encodeUIValues()
        let settings = InitialPlayerSettings(
            userValues: userValues,
            ui: uiValues,
            settings: playerSettings,
            platform: platform,
            locale: locale,
            localeStrings: localeStrings
        )
        return settings
    }
        
    /// Fires analytics pixels based on user interactions.
    ///
    /// - Parameters:
    ///   - message: The script message containing the interaction data.
    ///   - userValues: The user values to determine which pixels to fire.
    @MainActor
    private func firePixels(message: WKScriptMessage, userValues: UserValues) {
        
        guard let messageData: WKMessageData = DecodableHelper.decode(from: message.body) else {
            assertionFailure("DuckPlayer: expected JSON representation of Message")
            return
        }
        guard let feature = messageData.featureName else { return }
        
        // Get the webView URL
        guard let webView = message.webView, let url = webView.url else {
            return
        }
        
        // Based on the URL, determine which pixels to fire
        let isSERP = url.isDuckDuckGoSearch
            
        // Assume we are in the SERP Overlay
        if isSERP {
            switch userValues.duckPlayerMode {
            case .enabled:
                Pixel.fire(pixel: .duckPlayerSettingsAlwaysOverlaySERP)
            case .disabled:
                Pixel.fire(pixel: .duckPlayerSettingsNeverOverlaySERP)
            default: break
            }
        
            // Assume we are in the Youtube Overlay
        } else {
            switch userValues.duckPlayerMode {
            case .enabled:
                Pixel.fire(pixel: .duckPlayerSettingsAlwaysOverlayYoutube)
            case .disabled:
                Pixel.fire(pixel: .duckPlayerSettingsNeverOverlayYoutube)
            default: break
            }
        }
       
    }

    
}

extension DuckPlayer: UISheetPresentationControllerDelegate {
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        if #available(iOS 16.0, *) {
            let isLarge = sheetPresentationController.selectedDetentIdentifier == .large
            withAnimation {
                self.isLargeDetent = isLarge
            }
        }
    }
    
    func sheetPresentationControllerDidDismiss(_ presentationController: UISheetPresentationController) {
        // Restore the player container in the web view
        hostView?.webView.evaluateJavaScript("""
            const container = document.getElementById('player-container-id');
            if (container) {
                container.style.display = 'block';
            }
        """, completionHandler: nil)
        
        // Clear the reference to the dismissed controller
        currentPlayerController = nil
    }
}

extension DuckPlayer: UIGestureRecognizerDelegate {
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let hostView = hostView,
              let view = gesture.view else { return }
        
        let translation = gesture.translation(in: hostView.view)
        let minHeight: CGFloat = 320
        let maxHeight: CGFloat = hostView.view.bounds.height - 100 // Leave some space at top
        
        switch gesture.state {
        case .changed:
            let newY = view.frame.minY + translation.y
            let newHeight = hostView.view.bounds.height - newY
            
            // Constrain the height between min and max
            if newHeight >= minHeight && newHeight <= maxHeight {
                view.frame.origin.y = newY
            }
            
            gesture.setTranslation(.zero, in: hostView.view)
            
        case .ended:
            let velocity = gesture.velocity(in: hostView.view)
            let isMovingUp = velocity.y < 0
            
            UIView.animate(withDuration: 0.3) {
                if isMovingUp {
                    // Expand to full height
                    view.frame.origin.y = hostView.view.bounds.height - maxHeight
                } else {
                    // Collapse to minimum height
                    view.frame.origin.y = hostView.view.bounds.height - minHeight
                }
            }
            
        default:
            break
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
