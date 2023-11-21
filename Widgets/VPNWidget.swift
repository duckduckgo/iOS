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

#if ALPHA

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
        return VPNStatusTimelineEntry(date: Date(), status: .status(.connected), location: "Los Angeles, CA")
    }

    func getSnapshot(in context: Context, completion: @escaping (VPNStatusTimelineEntry) -> Void) {
        let entry = VPNStatusTimelineEntry(date: Date(), status: .status(.connected), location: "Los Angeles, CA")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<VPNStatusTimelineEntry>) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            let defaults = UserDefaults.networkProtectionGroupDefaults
            let location = defaults.string(forKey: NetworkProtectionUserDefaultKeys.lastSelectedServer) ?? "Unknown Location"
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
    var entry: VPNStatusTimelineProvider.Entry

    @ViewBuilder
    var body: some View {
        Group {
            switch entry.status {
            case .status(let status):
                HStack {
                    connectionView(with: status)
                        .padding([.leading, .trailing], 16)

                    Spacer()
                }
            case .error:
                Text("Error")
                    .foregroundStyle(Color.black)
            case .notConfigured:
                Text("VPN Not Configured")
                    .foregroundStyle(Color.black)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            switch entry.status {
            case .status(let status):
                switch status {
                case .connecting, .connected, .reasserting:
                    Color.vpnWidgetBackgroundColor
                case .disconnecting, .disconnected, .invalid:
                    Color.white
                @unknown default:
                    Color.white
                }
            case .error, .notConfigured:
                Color.white
            }
        }
    }

    private func connectionView(with status: NEVPNStatus) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Image(headerImageName(with: status))
                    .frame(width: 50, height: 54)
                    .padding(.top, 15)

                Spacer()

                Text(title(with: status))
                    .font(.system(size: 16, weight: .semibold))
                    .fontWeight(.semibold)
                    .foregroundStyle(status.isConnected ? Color.white : Color.black)

                Text(status.isConnected ? entry.location : "VPN is Off")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(status.isConnected ? Color.white : Color.black)
                    .opacity(status.isConnected ? 0.8 : 0.6)

                switch status {
                case .connected, .connecting, .reasserting:
                    Button(intent: DisableVPNIntent()) {
                        Text("Disconnect")
                            .font(.system(size: 15, weight: .medium))
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(Color.vpnWidgetBackgroundColor)
                    .buttonStyle(.borderedProminent)
                    .tint(.white)
                    .disabled(status != .connected)
                    .padding(.top, 6)
                    .padding(.bottom, 16)
                case .disconnected, .disconnecting:
                    Button(intent: EnableVPNIntent()) {
                        Text("Connect")
                            .font(.system(size: 15, weight: .medium))
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.white)
                    .buttonStyle(.borderedProminent)
                    .tint(Color.vpnWidgetBackgroundColor)
                    .disabled(status != .disconnected)
                    .padding(.top, 6)
                    .padding(.bottom, 16)
                default:
                    Spacer()
                }
            }
        }
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
        case .connecting, .connected, .reasserting: return "Protected"
        case .disconnecting, .disconnected: return "Unprotected"
        case .invalid: return "Invalid"
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
        .configurationDisplayName("VPN Status")
        .description("View and manage the VPN connection")
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

extension Color {

    static var vpnWidgetBackgroundColor: Color {
        let color = UIColor(designSystemColor: .accent).resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
        return Color(color)
    }

}

#endif
