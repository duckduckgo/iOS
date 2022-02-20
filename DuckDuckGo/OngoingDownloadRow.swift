//
//  OngoingDownloadRow.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import Combine

struct OngoingDownloadRow: View {
    @ObservedObject var rowModel: DownloadsListRow
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(rowModel.filename)")
                Spacer()
                    .frame(height: 4.0)
                Text("\(rowModel.fileSize)")
                    .foregroundColor(.gray)
//                Text("\(rowModel.type.) of 100MB")
//                    .foregroundColor(.gray)
            }
            Spacer()
            
            ProgressBar(progress: rowModel.progress)
                .frame(width: 30.0, height: 30.0)
                .padding(10.0)
        }
        .frame(height: 72.0)
        .listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
}

struct ProgressBar: View {
    var progress: Float
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 10.0)
                .opacity(0.3)
                .foregroundColor(Color.red)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 10.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.red)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear)

            Text(String(format: "%.0f %%", min(self.progress, 1.0)*100.0))
//                .font(.largeTitle)
//                .bold()
        }
    }
}
