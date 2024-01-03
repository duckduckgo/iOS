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

import Foundation
import UIKit
import SwiftUI

struct QRCodeView: View {
    let context = CIContext()

    let string: String
    let size: CGFloat

    init(string: String, size: CGFloat) {
        self.string = string
        self.size = size
    }

    var body: some View {
        Image(uiImage: generateQRCode(from: string, size: size))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: size)
    }

    func generateQRCode(from text: String, size: CGFloat) -> UIImage {
        var qrImage = UIImage(systemName: "xmark.circle") ?? UIImage()
        let data = Data(text.utf8)
        let qrCodeFilter: CIFilter = CIFilter.init(name: "CIQRCodeGenerator")!
        qrCodeFilter.setValue(data, forKey: "inputMessage")
        qrCodeFilter.setValue("H", forKey: "inputCorrectionLevel")

        guard let naturalSize = qrCodeFilter.outputImage?.extent.width else {
            assertionFailure("Failed to generate qr code")
            return qrImage
        }

        let scale = size / naturalSize

        let transform = CGAffineTransform(scaleX: scale, y: scale)
        guard let outputImage = qrCodeFilter.outputImage?.transformed(by: transform) else {
            assertionFailure("transformation failed")
            return qrImage
        }

        let colorParameters: [String: Any] = [
            "inputColor0": CIColor(color: .black),
            "inputColor1": CIColor(color: .white)
        ]
        let coloredImage = outputImage.applyingFilter("CIFalseColor", parameters: colorParameters)

        if let image = context.createCGImage(coloredImage, from: outputImage.extent) {
            qrImage = UIImage(cgImage: image)
        }

        return qrImage
    }

}
