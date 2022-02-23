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
    var cancelButtonAction: () -> Void
        
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(rowModel.filename)")
                    .font(Font(uiFont: Const.Font.filename))
                    .foregroundColor(.filename)
                Spacer()
                    .frame(height: 6.0)
                Text("\(rowModel.fileSize)")
                    .font(Font(uiFont: Const.Font.fileSize))
                    .foregroundColor(.fileSize)
            }
            Spacer()
            
            ZStack {
                ProgressBar(progress: rowModel.progress)
                    .frame(width: 34.0, height: 34.0)
                
                Button {
                    cancelButtonAction()
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 13.0, height: 13.0)
                }
                .buttonStyle(.plain)
                
            }
            
        }
        .frame(height: 76.0)
        .listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 13))
    }
}

struct ProgressBar: View {
    var progress: Float
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 3.0)
                .foregroundColor(.progressBackground)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 3.0, lineCap: .butt, lineJoin: .miter))
                .foregroundColor(.progressFill)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear)
        }
    }
}

private enum Const {
    enum Font {
        static let filename = UIFont.semiBoldAppFont(ofSize: 16)
        static let fileSize = UIFont.appFont(ofSize: 14)
    }

}

private extension Color {
    static let filename = Color(UIColor.darkGreyish)
    static let fileSize = Color(UIColor.greyish3)
    static let cancel = Color(UIColor.charcoalGrey)
    static let progressBackground = Color(UIColor.mercury)
    static let progressFill = Color(UIColor.cornflowerBlue)
}
