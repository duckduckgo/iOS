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
import Core
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
        return VPNStatusTimelineEntry(date: Date(), status: .status(.connected), location: "Paoli, PA")
    }

    func getSnapshot(in context: Context, completion: @escaping (VPNStatusTimelineEntry) -> Void) {
        let entry = VPNStatusTimelineEntry(date: Date(), status: .status(.connected), location: "Paoli, PA")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<VPNStatusTimelineEntry>) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            let expiration = Date().addingTimeInterval(TimeInterval.minutes(5))

            let defaults = UserDefaults.networkProtectionGroupDefaults
            let location = defaults.string(forKey: NetworkProtectionUserDefaultKeys.lastSelectedServer) ?? "Unknown Location"

            if let error {
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
            let enabled = (status == .connected || status == .connecting)

            let entry = VPNStatusTimelineEntry(date: expiration, status: .status(status), location: location)
            let timeline = Timeline(entries: [entry], policy: .atEnd)

            completion(timeline)
        }
    }
}

extension NEVPNStatus {
    var description: String {
        switch self {
        case .connected:
            return "Connected"
        case .connecting:
            return "Connecting"
        case .disconnected:
            return "Disconnected"
        case .disconnecting:
            return "Disconnecting"
        case .invalid:
            return "Invalid"
        case .reasserting:
            return "Reasserting"
        default:
            return "Unknown Status"
        }
    }

    var isConnected: Bool {
        switch self {
        case .connected, .connecting, .reasserting:
            return true
        case .disconnecting, .disconnected:
            return false
        default:
            return false
        }
    }
}

@available(iOSApplicationExtension 17.0, *)
struct VPNStatusView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: VPNStatusTimelineProvider.Entry

    @ViewBuilder
    var body: some View {
        VStack {
            switch entry.status {
            case .status(let status):
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
                            .foregroundStyle(Color("VPNWidgetConnectedColor"))
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
                            .tint(Color("VPNWidgetConnectedColor"))
                            .disabled(status != .disconnected)
                            .padding(.top, 6)
                            .padding(.bottom, 16)
                        default:
                            Spacer()
                        }

                    }
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
                    Color("VPNWidgetConnectedColor")
                case .disconnecting, .disconnected, .invalid:
                    Color.white
                @unknown default:
                    Color.white
                }
            case .error:
                Color.white
            case .notConfigured:
                Color.white
            }
        }
    }

    private func headerImageName(with status: NEVPNStatus) -> String {
        switch status {
        case .connecting, .connected, .reasserting:
            return "vpn-on"
        case .disconnecting, .disconnected:
            return "vpn-off"
        case .invalid:
            return "vpn-off"
        @unknown default:
            return "vpn-off"
        }
    }

    private func title(with status: NEVPNStatus) -> String {
        switch status {
        case .connecting, .connected, .reasserting:
            return "Protected"
        case .disconnecting, .disconnected:
            return "Unprotected"
        case .invalid:
            return "Invalid"
        @unknown default:
            return "Unknown"
        }
    }

}

extension Image {
    func centerSquareCropped() -> some View {
        GeometryReader { geo in
            let length = geo.size.width > geo.size.height ? geo.size.height : geo.size.width
            self
                .resizable()
                .scaledToFill()
                .frame(width: length, height: length, alignment: .center)
                .clipped()
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
        .description("View and manage the DuckDuckGo VPN status")
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()
    }
}

struct VPNStatusView_Previews: PreviewProvider {

    static let connectedState = VPNStatusTimelineProvider.Entry(
        date: Date(),
        status: .status(.connected),
        location: "Vancouver, CA"
    )

    static let disconnectedState = VPNStatusTimelineProvider.Entry(
        date: Date(),
        status: .status(.disconnected),
        location: "Vancouver, CA"
    )

    static let notConfiguredState = VPNStatusTimelineProvider.Entry(
        date: Date(),
        status: .notConfigured,
        location: "Vancouver, CA"
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
