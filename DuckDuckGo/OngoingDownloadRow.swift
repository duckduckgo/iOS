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
    @ObservedObject var rowModel: OngoingDownloadRowViewModel
    
    var cancelButtonAction: () -> Void
        
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(rowModel.filename)")
                    .font(Font(uiFont: Const.Font.filename))
                    .foregroundColor(.filename)
                    .lineLimit(2)
                Spacer()
                    .frame(height: Const.Spacing.betweenLabels)
                Text("\(rowModel.fileSize)")
                    .font(Font(uiFont: Const.Font.fileSize))
                    .foregroundColor(.fileSize)
            }
            
            Spacer(minLength: Const.Spacing.betweenLabelsAndProgressCircle)
            
            ZStack {
                if rowModel.isTotalSizeKnown {
                    ProgressCircle(progress: rowModel.progress)
                        .frame(width: Const.Size.progress.width, height: Const.Size.progress.height)
                } else {
                    IndefiniteProgressCircle()
                        .frame(width: Const.Size.progress.width, height: Const.Size.progress.height)
                }
                
                cancelButton
            }
            
        }
        .frame(height: Const.Size.rowHeight)
        .listRowInsets(EdgeInsets.rowInsets)
    }
    
    private var cancelButton: some View {
        Button {
            cancelButtonAction()
        } label: {
            Image("Close-24")
        }
        .accessibilityLabel(UserText.cancelDownloadAlertCancelAction)
        .buttonStyle(.plain)
    }
}

struct ProgressCircle: View {
    var progress: Float
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: Const.Size.progressStrokeWidth)
                .foregroundColor(.progressBackground)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: Const.Size.progressStrokeWidth, lineCap: .butt, lineJoin: .miter))
                .foregroundColor(.progressFill)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear)
        }
    }
}

struct IndefiniteProgressCircle: View {
    
    @State private var angle = 0.0
    
    private let gradient = AngularGradient(gradient: Gradient(colors: [.progressFill, .progressBackground]),
                                           center: .center,
                                           startAngle: .degrees(270),
                                           endAngle: .degrees(0))
    
    private var animation: Animation {
        Animation.linear(duration: 1.5)
            .repeatForever(autoreverses: false)
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: Const.Size.progressStrokeWidth)
                .foregroundColor(.progressBackground)
            
            Circle()
                .trim(from: 0, to: CGFloat(0.8))
                .stroke(gradient, style: StrokeStyle(lineWidth: Const.Size.progressStrokeWidth, lineCap: .round))
                .rotationEffect(Angle.degrees(angle))
                .onAppear(perform: {
                    withAnimation(animation) {
                        angle = 360
                    }
                })
        }
    }
}

private enum Const {
    enum Font {
        static let filename = UIFont.semiBoldAppFont(ofSize: 16)
        static let fileSize = UIFont.appFont(ofSize: 14)
    }

    enum Spacing {
        static let betweenLabels: CGFloat = 6
        static let betweenLabelsAndProgressCircle: CGFloat = 16
    }
    
    enum Size {
        static let progress = CGSize(width: 34, height: 34)
        static let progressStrokeWidth: CGFloat = 3
        static let cancel = CGSize(width: 13, height: 13)
        static let rowHeight: CGFloat = 76
    }
}

private extension EdgeInsets {
    static let rowInsets = EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 15)
}

private extension Color {
    static let filename = Color("DownloadsListFilenameColor")
    static let fileSize = Color("DownloadsListFileSizeColor")
    static let cancel = Color("DownloadsListCancelButtonColor")
    static let progressBackground = Color("DownloadsListProgressBackgroundColor")
    static let progressFill = Color("DownloadsListProgressFillColor")
}
