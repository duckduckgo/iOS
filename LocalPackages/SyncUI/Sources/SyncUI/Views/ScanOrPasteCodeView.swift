//
//  ScanOrPasteCodeView.swift
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

/// Handles scanning or pasting a code.
public struct ScanOrPasteCodeView: View {

    @ObservedObject var model: ScanOrPasteCodeViewModel

    public init(model: ScanOrPasteCodeViewModel) {
        self.model = model
    }

    @ViewBuilder
    func fullscreenCameraBackground() -> some View {
        Group {
            if model.showCamera {
                QRCodeScannerView {
                    return await model.codeScanned($0)
                } onCameraUnavailable: {
                    model.cameraUnavailable()
                }
            } else {
                Rectangle()
                    // White so that the blur / transparent doesn't become too dark
                    .fill(.white)
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
            VStack(spacing: 0) {

                Image("SyncCameraPermission")
                    .padding(.top, 40)
                    .padding(.bottom, 20)

                Text(UserText.cameraPermissionRequired)
                    .font(.system(size: 20, weight: .bold))
                    .lineSpacing(1.05)
                    .padding(.bottom, 8)

                Text(UserText.cameraPermissionInstructions)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 16, weight: .regular))
                    .lineSpacing(1.1)

                Spacer()

                Button {
                    model.gotoSettings()
                } label: {
                    HStack {
                        Image("SyncGotoButton")
                        Text(UserText.goToSettingsButton)
                    }
                }
                .buttonStyle(SyncLabelButtonStyle())
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 40)
        }
    }

    @ViewBuilder
    func cameraUnavailable() -> some View {
        if model.videoPermission == .authorised && !model.showCamera {
            VStack(spacing: 0) {

                Image("SyncCameraUnavailable")
                    .padding(.top, 40)
                    .padding(.bottom, 20)

                Text(UserText.cameraIsUnavailableTitle)
                    .font(.system(size: 20, weight: .bold))
                    .lineSpacing(1.05)

            }
            .padding(.horizontal, 40)
        }
    }

    @ViewBuilder
    func instructions() -> some View {

        Text(model.isInRecoveryMode ? UserText.recoveryModeInstructions : UserText.connectDeviceInstructions)
            .lineLimit(nil)
            .multilineTextAlignment(.center)
            .font(.system(size: 16, weight: .regular))
            .padding(.vertical)

    }

    @ViewBuilder
    func buttons() -> some View {

        Section {
            Group {
                NavigationLink {
                    PasteCodeView(model: model)
                } label: {
                    Label(UserText.manuallyEnterCodeLabel, image: "SyncKeyboardIcon")
                }

                if !model.isInRecoveryMode {
                    NavigationLink {
                        ConnectModeView(model: model)
                    } label: {
                        Label(UserText.showQRCodeLabel, image: "SyncQRCodeIcon")
                    }
                }
            }
            .frame(height: 40)
            .foregroundColor(.primary)
            .onAppear {
                model.endConnectMode()
            }
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

    public var body: some View {
        GeometryReader { g in
            ZStack(alignment: .top) {
                fullscreenCameraBackground()

                VStack(spacing: 0) {
                    Rectangle() // Also acts as the blur for the camera
                        .fill(.clear)
                        .frame(height: g.safeAreaInsets.top)
                        .regularMaterialBackground()

                    ZStack {
                        // Background in case fullscreen camera view doesn't work
                        if !model.showCamera {
                            Rectangle().fill(Color.black)
                        }
                        
                        cameraViewPort()
                            .frame(width: g.size.width, height: g.size.width)
                            .frame(maxHeight: g.size.height - 300)

                        Group {
                            cameraPermissionDenied()
                            cameraUnavailable()
                        }
                        .padding(.horizontal, 0)
                    }

                    ZStack {
                        Rectangle() // Also acts as the blur for the camera
                            .fill(.clear)
                            .regularMaterialBackground()

                        VStack {
                            instructions()
                                .padding(.horizontal, 20)

                            List {
                                buttons()
                            }
                            .ignoresSafeArea()
                            .hideScrollContentBackground()
                            .disableScrolling()
                        }
                        .frame(maxWidth: Constants.maxFullScreenWidth)
                    }
                }
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

private struct RoundedCorner: Shape {

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
