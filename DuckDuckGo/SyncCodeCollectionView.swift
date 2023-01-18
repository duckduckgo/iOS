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
            }

            Button {
                print("*** qr code entry")
            } label: {
                HStack {
                    Label("Show QR Code", image: "SyncQRCodeIcon")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
            }

        }
        .hideScrollContentBackground()
        .foregroundColor(.primary.opacity(0.9))
    }

    @ViewBuilder
    func cameraViewPort() -> some View {
        if model.showCamera {
            EmptyView()
        }
    }

    var body: some View {
        ZStack {
            fullscreenCameraBackground()

            VStack {
                header()
                    .modifier(CameraMaskModifier())

                GeometryReader { g in
                    ZStack(alignment: .center) {
                        cameraViewPort()
                        waitingForCameraPermission()
                    }
                    .frame(width: g.size.width, height: g.size.width)
                }

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

struct CameraViewPort: Shape {

    let top: CGFloat

    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: .init(x: 0, y: 0))
        p.addLine(to: .init(x: rect.width, y: 0))
        p.addLine(to: .init(x: rect.width, y: top))
        p.addLine(to: .init(x: 0, y: top))

        p.move(to: .init(x: 0, y: top + rect.width))
        p.addLine(to: .init(x: rect.width, y: top + rect.width))
        p.addLine(to: .init(x: rect.width, y: rect.height))
        p.addLine(to: .init(x: 0, y: rect.height))
        return p
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
