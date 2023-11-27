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
import DesignResourcesKit

/// Handles scanning or pasting a code.
public struct ScanOrPasteCodeView: View {

    @ObservedObject var model: ScanOrPasteCodeViewModel
    @State var qrCodeModel = ShowQRCodeViewModel()

    @State private var isShareSheetPresented: Bool = false

    public init(model: ScanOrPasteCodeViewModel) {
        self.model = model
    }

    @State var isInvalidCode = false

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
            VStack(spacing: 0) {

                Image("SyncCameraPermission")
                    .padding(.top, 40)
                    .padding(.bottom, 20)

                Text(UserText.cameraPermissionRequired)
                    .daxTitle3()
                    .lineSpacing(1.05)
                    .padding(.bottom, 8)

                Text(UserText.cameraPermissionInstructions)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .daxBodyRegular()
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
                    .daxTitle3()
                    .lineSpacing(1.05)

            }
            .padding(.horizontal, 40)
        }
    }

    @ViewBuilder
    func instructions() -> some View {
        
        Text(model.showConnectMode ? UserText.connectDeviceInstructions : UserText.recoveryModeInstructions)
            .daxFootnoteRegular()
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
    }

    @ViewBuilder
    func buttons() -> some View {

        Group {
            Section {
                NavigationLink {
                    PasteCodeView(model: model)
                } label: {
                    HStack(spacing: 16) {
                        Image("SyncKeyboardIcon")
                        Text(UserText.manuallyEnterCodeTitle)
                            .daxButton()
                            .foregroundColor(.white.opacity(0.84))
                    }
                }
            }
            Section {
                if model.showConnectMode {
                    NavigationLink {
                        ConnectModeView(model: model)
                    } label: {
                        HStack(spacing: 16) {
                            Image("SyncQRCodeIcon")

                            VStack(alignment: .leading, spacing: 4) {
                                Text(UserText.showQRCodeLabel)
                                    .daxButton()
                                    .foregroundColor(.white.opacity(0.84))
                                Text(UserText.showQRCodeSubLabel)
                                    .daxCaption()
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
        }
        .frame(height: 40)
        .foregroundColor(.primary)
        .onAppear {
            model.endConnectMode()
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
                        .foregroundColor(isInvalidCode ? .red.opacity(0.6) : .white.opacity(0.8))
                        .rotationEffect(.degrees(degrees), anchor: .center)
                        .frame(width: 250, height: 250)
                }
            }
        }
    }

    public var body: some View {
        VStack(spacing: 10) {
            VStack(spacing: 10) {
                if model.showConnectMode {
                    Text("Scan QR Code")
                        .daxTitle2()
                }
                instructions()
            }
            .padding(.top, 10)
            GeometryReader { g in
                ZStack(alignment: .top) {
                    fullscreenCameraBackground()

                    VStack(spacing: 0) {
                        Rectangle() // Also acts as the blur for the camera
                            .fill(.black)
                            .frame(height: g.safeAreaInsets.top)

                        ZStack {
                            // Background in case fullscreen camera view doesn't work
                            if !model.showCamera {
                                Rectangle().fill(Color.black)
                            }

                            Group {
                                cameraPermissionDenied()
                                cameraUnavailable()
                            }
                            .padding(.horizontal, 0)

                            VStack {
                                Spacer()
                                Text("Point camera at QR code to sync")
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 56)
                                            .fill(.clear)
                                            .background(BlurView(style: .light))
                                            .cornerRadius(20)
                                    )
                                    .daxCaption()
                            }
                            .padding(.bottom, 12)
                        }
                    }
                    .ignoresSafeArea()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel", action: model.cancel)
                            .foregroundColor(Color.white)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink("Manually Enter Code", destination: {
                            PasteCodeView(model: model)
                        })
                        .foregroundColor(Color(designSystemColor: .accent))
                    }
                }
            }
        }
        if model.showConnectMode {
            VStack(spacing: 8) {
                HStack(alignment: .top, spacing: 20) {
                    QRCodeView(string: qrCodeModel.code ?? "", size: 120)
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Mobile-to-Mobile?")
                                .daxBodyBold()
                                .fixedSize()
                            Spacer()
                            Image("SyncDeviceType_phone")
                                .padding(2)
                                .background(
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color(designSystemColor: .lines))
                                )
                        }
                        Text("Scan this code with another device to sync.")
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(designSystemColor: .panel))
                )
                .padding(20)
                HStack {
                    Text("can't scan?")
                    Text("Share Text Code")
                        .foregroundColor(Color(designSystemColor: .accent))
                        .onTapGesture {
                            model.showShareCodeSheet()
                        }
                    //                    .sheet(isPresented: $isShareSheetPresented, content: {
                    //                        ShareSheet(activityItems: [qrCodeModel.code ?? ""])
                    //                            .frame(height: UIScreen.main.bounds.height / 2)
                    //                    })
                }
            }
            .padding(.bottom, 40)
            .onAppear {
                if let recoveryCode = model.recoveryCode {
                    self.qrCodeModel.code = recoveryCode
                } else {
                    self.qrCodeModel = model.startConnectMode()
                }
            }
        } else {
            Rectangle().fill(Color.black)
                .frame(maxHeight: 274)
        }
    }

    struct ShareSheet: UIViewControllerRepresentable {
        let activityItems: [Any]

        func makeUIViewController(context: Context) -> UIViewController {
            let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            return controller
        }

        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        }
    }


    struct BlurView: UIViewRepresentable {
        var style: UIBlurEffect.Style

        func makeUIView(context: Context) -> UIVisualEffectView {
            return UIVisualEffectView(effect: UIBlurEffect(style: style))
        }

        func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
            uiView.effect = UIBlurEffect(style: style)
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
