//
//  CameraView.swift
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

public struct CameraView: View {
    
    @ObservedObject var model: ScanOrPasteCodeViewModel

    public var body: some View {
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

                        if model.showCamera {
                            VStack {
                                Spacer()
                                Text(UserText.cameraPointCameraIndication)
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
                            .padding(.bottom, 20)
                        }
                    }
                }
                .ignoresSafeArea()
            }
        }
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
                    .fill(.black)
            }
        }
        .ignoresSafeArea()
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
                        Text(UserText.cameraGoToSettingsButton)
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
