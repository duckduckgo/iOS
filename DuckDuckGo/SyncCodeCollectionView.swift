//
//  SyncCodeCollectionView.swift
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

struct SyncCodeCollectionView: View {

    @ObservedObject var model: SyncCodeCollectionViewModel

    @ViewBuilder
    func fullscreenCameraBackground() -> some View {
        Group {
            if model.showCamera {
                QRCodeScannerView {
                    model.codeScanned($0)
                } onCameraUnavailable: {
                    model.cameraUnavailable()
                }
            } else {
                Rectangle()
                    .fill(.black)
            }
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    func waitingForCameraPermission() -> some View {
        if model.videoPermission == .unknown {
            SwiftUI.ProgressView()
        }
    }

    @ViewBuilder
    func cameraPermissionDenied() -> some View {
        if model.videoPermission == .denied {
            Text("Camera permission denied")
                .padding()
        }
    }

    @ViewBuilder
    func cameraUnavailable() -> some View {
        if model.videoPermission == .authorised && !model.showCamera {
            Text("Camera unavailable")
                .padding()
        }
    }

    @ViewBuilder
    func instructions() -> some View {
        if model.showCamera {
            Text("Go to Settings > Sync in the **DuckDuckGo App** on a different device and scan supplied code to connect instantly.")
                .multilineTextAlignment(.center)
        }
    }

    @ViewBuilder
    func buttons() -> some View {

        Section {
            Group {
                NavigationLink {
                    SyncCodeManualEntryView(model: model)
                } label: {
                    Label("Manually Enter Code", image: "SyncKeyboardIcon")
                }

                #warning("Actually, if this is a new installation there won't be any code to show yet.")
                NavigationLink {
                    ShowQRCodeView(model: model.createShowQRCodeViewModel())
                } label: {
                    Label("Show QR Code", image: "SyncQRCodeIcon")
                }
            }
            .frame(height: 40)
            .foregroundColor(.primary)
        }
    }

    @ViewBuilder
    func cameraViewPort() -> some View {
        ZStack(alignment: .center) {
            waitingForCameraPermission()
            cameraTarget()
        }
    }

    @ViewBuilder
    func cameraTarget() -> some View {
        if model.showCamera {
            ZStack {
                ForEach([0.0, 90.0, 180.0, 270.0], id: \.self) { degrees in
                    RoundedCorner()
                        .stroke(lineWidth: 8)
                        .foregroundColor(.white.opacity(0.8))
                        .rotationEffect(.degrees(degrees), anchor: .center)
                        .frame(width: 300, height: 300)
                }
            }
        }
    }

    var body: some View {
        GeometryReader { g in
            ZStack(alignment: .top) {
                fullscreenCameraBackground()

                VStack(spacing: 0) {
                    Rectangle() // Also acts as the blur for the camera
                        .fill(.clear)
                        .frame(height: g.safeAreaInsets.top)
                        .modifier(CameraMaskModifier())

                    ZStack {
                        cameraViewPort()
                            .frame(width: g.size.width, height: g.size.width)
                        cameraPermissionDenied()
                        cameraUnavailable()
                    }

                    List { // Also acts as the blur for the camera
                        instructions()
                        buttons()
                    }
                    .ignoresSafeArea()
                    .hideScrollContentBackground()
                    .disableScrolling()
                    .modifier(CameraMaskModifier())
                }
                .padding(.horizontal, 0)
                .ignoresSafeArea()
            }
            .navigationTitle("Scan QR Code")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", action: model.cancel)
                    .foregroundColor(Color.white)                    
                }
            }
        }
    }
}

struct RoundedCorner: Shape {

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let c = 50.0
        let r = 30.0
        let e = c - r

        path.move(to: CGPoint(x: 0, y: c))
        path.addLine(to: CGPoint(x: 0, y: e))
        path.addCurve(to: CGPoint(x: e, y: 0),
                      control1: CGPoint(x: 0, y: 0),
                      control2: CGPoint(x: e, y: 0))
        path.addLine(to: CGPoint(x: c, y: 0))

        return path
    }

}

struct CameraMaskModifier: ViewModifier {

    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content.background(.regularMaterial)
        } else {
            content.background(Rectangle().foregroundColor(.black.opacity(0.9)))
        }
    }

}
