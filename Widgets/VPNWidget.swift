//
//  VPNWidget.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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
import AppIntents
import Core
import DesignResourcesKit
import SwiftUI
import WidgetKit
import NetworkExtension
import NetworkProtection

enum VPNStatus {
    case status(NEVPNStatus)
    case error
    case notConfigured
}

struct VPNStatusTimelineEntry: TimelineEntry {
    let date: Date
    let status: VPNStatus
    let location: String

    internal init(date: Date, status: VPNStatus = .notConfigured, location: String) {
        self.date = date
        self.status = status
        self.location = location
    }
}

class VPNStatusTimelineProvider: TimelineProvider {

    typealias Entry = VPNStatusTimelineEntry

    func placeholder(in context: Context) -> VPNStatusTimelineEntry {
        return VPNStatusTimelineEntry(date: Date(), status: .status(.connected), location: "Los Angeles")
    }

    func getSnapshot(in context: Context, completion: @escaping (VPNStatusTimelineEntry) -> Void) {
        let entry = VPNStatusTimelineEntry(date: Date(), status: .status(.connected), location: "Los Angeles")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<VPNStatusTimelineEntry>) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            let defaults = UserDefaults.networkProtectionGroupDefaults
            let location = defaults.string(forKey: NetworkProtectionUserDefaultKeys.lastSelectedServerCity) ?? "Unknown Location"
            let expiration = Date().addingTimeInterval(TimeInterval.minutes(5))

            if error != nil {
                let entry = VPNStatusTimelineEntry(date: expiration, status: .error, location: location)
                let timeline = Timeline(entries: [entry], policy: .atEnd)
                completion(timeline)
                return
            }

            guard let manager = managers?.first else {
                let entry = VPNStatusTimelineEntry(date: expiration, status: .notConfigured, location: location)
                let timeline = Timeline(entries: [entry], policy: .atEnd)
                completion(timeline)
                return
            }

            let status = manager.connection.status
            let entry = VPNStatusTimelineEntry(date: expiration, status: .status(status), location: location)
            let timeline = Timeline(entries: [entry], policy: .atEnd)

            completion(timeline)
        }
    }
}

extension NEVPNStatus {
    var description: String {
        switch self {
        case .connected: return "Connected"
        case .connecting: return "Connecting"
        case .disconnected: return "Disconnected"
        case .disconnecting: return "Disconnecting"
        case .invalid: return "Invalid"
        case .reasserting: return "Reasserting"
        default: return "Unknown Status"
        }
    }

    var isConnected: Bool {
        switch self {
        case .connected, .connecting, .reasserting: return true
        case .disconnecting, .disconnected: return false
        default: return false
        }
    }
}

@available(iOSApplicationExtension 17.0, *)
struct VPNStatusView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.openURL) private var openURL
    var entry: VPNStatusTimelineProvider.Entry

    @ViewBuilder
    var body: some View {
        Group {
            switch entry.status {
            case .status(let status):
                connectionView(with: status)
            case .error, .notConfigured:
                connectionView(with: .disconnected)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            Color(designSystemColor: .backgroundSheets)
        }
    }

    private func connectionView(with status: NEVPNStatus) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Image(headerImageName(with: status))

                Text(title(with: status))
                    .font(.system(size: 16, weight: .semibold))
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(designSystemColor: .textPrimary))

                Text(status == .connected ? entry.location : UserText.vpnWidgetDisconnectedSubtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color(designSystemColor: .textSecondary))
                    .opacity(status.isConnected ? 0.8 : 0.6)

                switch status {
                case .connected, .connecting, .reasserting:
                    Button(UserText.vpnWidgetDisconnectButton, intent: DisableVPNIntent())
                        .daxButton()
                        .foregroundStyle(disconnectButtonForegroundColor(isDisabled: status != .connected))
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.roundedRectangle(radius: 8))
                        .tint(disconnectButtonBackgroundColor(isDisabled: status != .connected))
                        .disabled(status != .connected)
                        .padding(.top, 6)
                        .padding(.bottom, 16)
                case .disconnected, .disconnecting:
                    connectButton
                        .daxButton()
                        .foregroundStyle(connectButtonForegroundColor(isDisabled: status != .disconnected))
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.roundedRectangle(radius: 8))
                        .tint(Color(designSystemColor: .accent))
                        .disabled(status != .disconnected)
                        .padding(.top, 6)
                        .padding(.bottom, 16)
                default:
                    Spacer()
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 16)
            Spacer()
        }
    }

    private var connectButton: Button<Text> {
        switch entry.status {
        case .status:
            Button(UserText.vpnWidgetConnectButton, intent: EnableVPNIntent())
        case .error, .notConfigured:
            Button(UserText.vpnWidgetConnectButton) {
                openURL(DeepLinks.openVPN)
            }
        }
    }

    private func connectButtonForegroundColor(isDisabled: Bool) -> Color {
        let isDark = colorScheme == .dark
        let standardForegroundColor = isDark ? Color.black.opacity(0.84) : Color.white
        let pressedForegroundColor = isDark ? Color.black.opacity(0.84) : Color.white
        let disabledForegroundColor = isDark ? Color.white.opacity(0.36) : Color.black.opacity(0.36)
        return isDisabled ? disabledForegroundColor : standardForegroundColor
    }

    private func disconnectButtonBackgroundColor(isDisabled: Bool) -> Color {
        let isDark = colorScheme == .dark
        let standardBackgroundColor = isDark ? Color.white.opacity(0.18) : Color.black.opacity(0.06)
        let disabledBackgroundColor = isDark ? Color.white.opacity(0.06) : Color.black.opacity(0.06)
        return isDisabled ? disabledBackgroundColor : standardBackgroundColor
    }

    private func disconnectButtonForegroundColor(isDisabled: Bool) -> Color {
        let isDark = colorScheme == .dark
        let defaultForegroundColor = isDark ? Color.white : Color.black.opacity(0.84)
        let disabledForegroundColor = isDark ? Color.white.opacity(0.36) : Color.black.opacity(0.36)
        return isDisabled ? disabledForegroundColor : defaultForegroundColor
    }

    private func headerImageName(with status: NEVPNStatus) -> String {
        switch status {
        case .connecting, .connected, .reasserting: return "vpn-on"
        case .disconnecting, .disconnected: return "vpn-off"
        case .invalid: return "vpn-off"
        @unknown default: return "vpn-off"
        }
    }

    private func title(with status: NEVPNStatus) -> String {
        switch status {
        case .connecting, .connected, .reasserting: return UserText.vpnWidgetConnectedStatus
        case .disconnecting, .disconnected, .invalid: return UserText.vpnWidgetDisconnectedStatus
        @unknown default: return "Unknown"
        }
    }

}

@available(iOSApplicationExtension 17.0, *)
struct VPNStatusWidget: Widget {
    let kind: String = "VPNStatusWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VPNStatusTimelineProvider()) { entry in
            VPNStatusView(entry: entry).widgetURL(DeepLinks.openVPN)
        }
        .configurationDisplayName(UserText.vpnWidgetGalleryDisplayName)
        .description(UserText.vpnWidgetGalleryDescription)
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()
    }
}

struct VPNStatusView_Previews: PreviewProvider {

    static let connectedState = VPNStatusTimelineProvider.Entry(
        date: Date(),
        status: .status(.connected),
        location: "Paoli, PA"
    )

    static let disconnectedState = VPNStatusTimelineProvider.Entry(
        date: Date(),
        status: .status(.disconnected),
        location: "Paoli, PA"
    )

    static let notConfiguredState = VPNStatusTimelineProvider.Entry(
        date: Date(),
        status: .notConfigured,
        location: "Paoli, PA"
    )

    static var previews: some View {
        if #available(iOSApplicationExtension 17.0, *) {
            VPNStatusView(entry: connectedState)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .environment(\.colorScheme, .light)

            VPNStatusView(entry: connectedState)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .environment(\.colorScheme, .dark)

            VPNStatusView(entry: disconnectedState)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .environment(\.colorScheme, .light)

            VPNStatusView(entry: disconnectedState)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .environment(\.colorScheme, .dark)

            VPNStatusView(entry: notConfiguredState)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .environment(\.colorScheme, .light)

            VPNStatusView(entry: notConfiguredState)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .environment(\.colorScheme, .dark)
        } else {
            Text("iOS 17 required")
        }
    }
}
