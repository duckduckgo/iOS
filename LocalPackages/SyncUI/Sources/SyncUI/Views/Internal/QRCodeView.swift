//
//  QRCodeView.swift
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

struct QRCodeView: View {

    @ObservedObject var model: ShowQRCodeViewModel

    @ViewBuilder
    func progressView() -> some View {
        if model.code == nil {
            ZStack {
                SwiftUI.ProgressView()
            }.frame(width: 200, height: 200)
        }
    }

    @ViewBuilder
    func qrCodeView() -> some View {
        if let code = model.code {
            VStack(spacing: 20) {
                Spacer()

                QRCode(string: code)
                    .padding()

                Spacer()

                Button {
                    model.copy()
                } label: {
                    Label(UserText.copyCodeLabel, image: "SyncCopy")
                }
                .buttonStyle(SyncLabelButtonStyle())
                .padding(.bottom, 20)
            }
        }
    }

    @ViewBuilder
    func instructions() -> some View {

        if model.code != nil {
            Text(UserText.viewQRCodeInstructions)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
        }

    }

    @ViewBuilder
    func qrCodeSection() -> some View {
        ZStack {
            VStack {
                HStack { Spacer() }
                Spacer()
            }
            RoundedRectangle(cornerRadius: 8).foregroundColor(.white.opacity(0.12))
            progressView()
            qrCodeView()
        }
        .frame(maxWidth: 350, maxHeight: 350)
        .padding()
    }

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 20) {
                qrCodeSection()
                instructions()
                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: Constants.maxWidth, alignment: .center)
        }
        .navigationTitle("QR Code")
        .modifier(BackButtonModifier())
    }

}

private struct QRCode: View {

    @Environment(\.displayScale) var displayScale

    let context = CIContext()

    let string: String

    var body: some View {
        Image(uiImage: generateQRCode(from: string, scale: 200))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxHeight: 200)
    }

    func generateQRCode(from text: String, scale: CGFloat) -> UIImage {
        var qrImage = UIImage(systemName: "xmark.circle") ?? UIImage()
        let data = Data(text.utf8)
        let qrCodeFilter: CIFilter = CIFilter.init(name: "CIQRCodeGenerator")!
        qrCodeFilter.setValue(data, forKey: "inputMessage")
        qrCodeFilter.setValue("H", forKey: "inputCorrectionLevel")

        let transform = CGAffineTransform(scaleX: scale, y: scale)
        guard let outputImage = qrCodeFilter.outputImage?.transformed(by: transform) else {
            return qrImage
        }

        let colorParameters: [String: Any] = [
            "inputColor0": CIColor(color: .white),
            "inputColor1": CIColor(color: .clear)
        ]
        let coloredImage = outputImage.applyingFilter("CIFalseColor", parameters: colorParameters)

        if let image = context.createCGImage(coloredImage, from: outputImage.extent) {
            qrImage = UIImage(cgImage: image)
        }

        return qrImage
    }

}

private extension CIFilter {

    static func qrCodeGenerator() -> CIFilter {
        CIFilter(name: "CIQRCodeGenerator", parameters: [
            "inputCorrectionLevel": "H"
        ])!
    }

}
