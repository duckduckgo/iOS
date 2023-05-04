//
//  AppTPSummaryNotifView.swift
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

import SwiftUI
import Core
import Charts

struct NotifNetworkView: View {
    let network: AppTrackerNetworkStat
    let imageCache: AppTrackerImageCache
    let scale: CGFloat
    
    let standardWidth: CGFloat = 40
    
    var body: some View {
        HStack {
            let image = imageCache.loadTrackerImage(for: network.trackerOwner)
            switch image {
            case .svg(let uiimage):
                Image(uiImage: uiimage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: standardWidth * scale, height: standardWidth * scale)
            case .view(let iconData):
                GenericIconView(trackerLetter: iconData.trackerLetter,
                                trackerColor: iconData.trackerColor,
                                width: standardWidth * scale)
            }
            
            Text("\(Int(network.blockedPrevalence * 100))%")
                .font(.title3)
                .padding(.leading, 4)
        }
    }
}

struct AppTPSummaryNotifView: View {
    
    @ObservedObject var viewModel: AppTrackingProtectionNotificationViewModel
    
    let appTrackerCache = AppTrackerImageCache()
    
    func formatSummary() -> Text {
        return Text("DuckDuckGo's AppTP blocked ")
            + Text("\(viewModel.totalTrackerCount()) trackers")
                .fontWeight(.heavy)
            + Text(" over the last 24 hours")
    }
    
    var topNetworks: some View {
        VStack(alignment: .leading) {
            Text("Top Networks")
                .font(.title2)
                .bold()
            
            HStack(alignment: .bottom) {
                let owners = viewModel.topTrackerOwners()
                ForEach(Array(owners.enumerated()), id: \.element) { index, network in
                    HStack {
                        NotifNetworkView(network: network,
                                         imageCache: appTrackerCache,
                                         scale: index == 1 ? 1.325 : 1)
                        
                        if network != owners.last {
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding(.vertical)
    }
    
    var trackerChart: some View {
        Chart {
            ForEach(Array(viewModel.aggregatedResults().enumerated()), id: \.element) { index, tracker in
                BarMark(
                    x: .value("", index),
                    y: .value("Blocked Count", tracker.count)
                )
                .foregroundStyle(Color.green)
                .annotation {
                    switch appTrackerCache.loadTrackerImage(for: tracker.trackerOwner) {
                    case .svg(let uiimage):
                        Image(uiImage: uiimage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                    case .view(let iconData):
                        GenericIconView(trackerLetter: iconData.trackerLetter,
                                        trackerColor: iconData.trackerColor,
                                        width: 24)
                    }
                }
            }
        }
        .chartXAxis(.hidden)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image("Logo")
                    .resizable()
                    .frame(width: 35, height: 35)
                    .padding(.trailing, 2)
                
                formatSummary()
            }
            
            topNetworks
            
            trackerChart
        }
        .padding()
    }
}
