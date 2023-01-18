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

    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var model: SyncCodeCollectionViewModel

    /// When targetting 15+ we can delete this function and inject it with
    /// `@Environment(\.dismiss) var dismiss`
    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }

    @ViewBuilder
    func header() -> some View {
        ZStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
                .foregroundColor(.primary.opacity(0.9))
                Spacer()
            }

            Text("Scan QR Code")
                .font(.headline)
        }
        .padding(.horizontal)
        .padding(.bottom, 32)
        .modifier(CameraMaskModifier())
    }

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
            Text("Go to Settings > Sync in the *DuckDuckGo App* on a different device and scan supplied code to connect instantly.")
                .multilineTextAlignment(.center)
                .padding()
        }
    }

    @ViewBuilder
    func buttons() -> some View {

        List {

            Button {
                print("*** keyboard entry")
            } label: {
                HStack {
                    Label("Manually Enter Code", image: "SyncKeyboardIcon")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .frame(height: 40)
            }

            Button {
                print("*** qr code entry")
            } label: {
                HStack {
                    Label("Show QR Code", image: "SyncQRCodeIcon")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .frame(height: 40)
            }

        }
        .hideScrollContentBackground()
        .foregroundColor(.primary.opacity(0.6))
    }

    @ViewBuilder
    func cameraViewPort(width: CGFloat) -> some View {
        ZStack(alignment: .center) {
            waitingForCameraPermission()
            cameraTarget()
        }
        .frame(width: width, height: width)
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
            ZStack {
                fullscreenCameraBackground()

                VStack {
                    header()

                    cameraViewPort(width: g.size.width)

                    VStack {
                        cameraPermissionDenied()
                        cameraUnavailable()
                        instructions()
                        buttons()
                        Spacer()
                    }
                    .ignoresSafeArea()
                    .modifier(CameraMaskModifier())
                }
                .padding(.horizontal, 0)
            }
            .environment(\.colorScheme, .dark)
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
