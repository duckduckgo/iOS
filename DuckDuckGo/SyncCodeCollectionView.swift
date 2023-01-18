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
                Spacer()
            }

            Text("Scan QR Code")
                .font(.headline)
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    func cameraView() -> some View {
        if model.videoPermission == .authorised {
            QRCodeScannerView {
                model.codeScanned($0)
            }
            .ignoresSafeArea()

            GeometryReader { g in
                CameraViewPort(top: g.safeAreaInsets.top + 50)
                    .ignoresSafeArea()
                    .modifier(CameraMaskModifier())
            }
        }
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
            Text("Camera denied")
        }
    }

    var body: some View {
        ZStack {
            cameraView()

            VStack {
                header()

                waitingForCameraPermission()

                cameraPermissionDenied()

                Spacer()
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
            content.foregroundStyle(.regularMaterial)
        } else {
            content.foregroundColor(.black.opacity(0.9))
        }
    }

}
