//
//  QRCodeScannerView.swift
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
import AVFoundation

#warning("see if we can either set the area of interest, or filter by area of interest")
struct QRCodeScannerView: UIViewRepresentable {

    var onQRCodeScanned: (String) -> Void
    var onCameraUnavailable: () -> Void

    func makeCoordinator() -> Coordinator {
        print(#function)
        return Coordinator(self)
    }

    func makeUIView(context: Context) -> UIView {
        print(#function)
        let view = AutoResizeLayersView()
        context.coordinator.start(view)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        print(#function, uiView.frame)
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        print(#function, uiView.frame)
        coordinator.stop()
    }

    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {

        let session: AVCaptureSession
        let metadataOutput = AVCaptureMetadataOutput()
        let cameraView: QRCodeScannerView

        init(_ cameraView: QRCodeScannerView) {
            self.cameraView = cameraView
            self.session = AVCaptureSession()
            super.init()
        }

        func start(_ uiView: UIView) {
            session.sessionPreset = .high

            guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let input = try? AVCaptureDeviceInput(device: backCamera) else {

                // This updates the view so needs to be done in a separate UI cycle
                DispatchQueue.main.async {
                    self.cameraView.onCameraUnavailable()
                }
                return
            }
            session.addInput(input)
            session.addOutput(metadataOutput)
            metadataOutput.metadataObjectTypes = [.qr]
            metadataOutput.setMetadataObjectsDelegate(self, queue: .main)

            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.frame = uiView.frame
            previewLayer.videoGravity = .resizeAspectFill
            uiView.layer.addSublayer(previewLayer)

            DispatchQueue.global().async {
                self.session.startRunning()
            }
        }

        func stop() {
            DispatchQueue.global().async {
                self.session.stopRunning()
            }
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput,
                            didOutput metadataObjects: [AVMetadataObject],
                            from connection: AVCaptureConnection) {

            guard metadataObjects.count == 1,
                  let codeObject = metadataObjects[0] as? AVMetadataMachineReadableCodeObject,
                  let code = codeObject.stringValue else { return }

            // let rect = previewLayer.layerRectConverted(fromMetadataOutputRect: codeObject.bounds)
            // print(#function, rect)

            cameraView.onQRCodeScanned(code)
        }

        deinit {
            print(#function)
        }
    }

}

class AutoResizeLayersView: UIView {

    override var frame: CGRect {
        didSet {
            layer.sublayers?.forEach {
                $0.frame = self.frame
            }
        }
    }

}
