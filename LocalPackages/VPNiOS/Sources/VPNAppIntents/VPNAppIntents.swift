//
//  VPNAppIntents.swift
//  VPNiOS
//
//  Created by ddg on 12/17/24.
//

// MARK: - Toggle

/// `ForegroundContinuableIntent` isn't available for extensions, which makes it impossible to call
/// from extensions.  This is the recommended workaround from:
///     https://mastodon.social/@mgorbach/110812347476671807
///

import AppIntents
import VPNWidgetSupport
import WidgetKit

public struct VPNAppIntents: AppIntentsPackage { }
/*
@available(iOS 17.0, *)
public struct ControlWidgetToggleVPNIntent: SetValueIntent {
    public static let title: LocalizedStringResource = "Toggle DuckDuckGo VPN from the Control Center Widget"
    public static let description: LocalizedStringResource = "Toggles the DuckDuckGo VPN from the Control Center widget"
    public static let isDiscoverable = false
    public static let openAppWhenRun = false

    @Parameter(title: "Enabled")
    public var value: Bool

    public init() {}

    public func perform() async throws -> some IntentResult {
        if value {
            try await startVPN()
        } else {
            try await stopVPN()
        }

        return .result()
    }

    private func startVPN() async throws {
        do {
            //DailyPixel.fireDailyAndCount(pixel: .vpnControlCenterConnectAttempt)

            let controller = VPNWidgetTunnelController()
            try await controller.start()

            WidgetCenter.shared.reloadAllTimelines()

            //await VPNSnoozeLiveActivityManager().endSnoozeActivity()
            //VPNReloadStatusWidgets()

            //DailyPixel.fireDailyAndCount(pixel: .vpnControlCenterConnectSuccess)
        } catch {
            switch error {
            case VPNWidgetTunnelController.StartFailure.vpnNotConfigured:
                //DailyPixel.fireDailyAndCount(pixel: .vpnControlCenterConnectCancelled)
                throw error
            default:
                //DailyPixel.fireDailyAndCount(pixel: .vpnControlCenterConnectFailure, error: error)
                throw error
            }
        }
    }

    private func stopVPN() async throws {
        do {
            //DailyPixel.fireDailyAndCount(pixel: .vpnControlCenterDisconnectAttempt)

            let controller = VPNWidgetTunnelController()
            try await controller.stop()

            WidgetCenter.shared.reloadAllTimelines()
            //await VPNSnoozeLiveActivityManager().endSnoozeActivity()
            //VPNReloadStatusWidgets()

            //DailyPixel.fireDailyAndCount(pixel: .vpnControlCenterDisconnectSuccess)
        } catch {
            switch error {
            case VPNWidgetTunnelController.StopFailure.vpnNotConfigured:
                //DailyPixel.fireDailyAndCount(pixel: .vpnControlCenterDisconnectCancelled)
                throw error
            default:
                //DailyPixel.fireDailyAndCount(pixel: .vpnControlCenterDisconnectFailure, error: error)
                throw error
            }
        }
    }
}
*/
