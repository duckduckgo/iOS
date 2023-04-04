//
//  SyncSettingsViewController+PDFRendering.swift
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
import Combine
import SyncUI
import DDGSync

extension SyncSettingsViewController {

    func shareRecoveryPDF() {
        let pdfController = UIHostingController(rootView: RecoveryKeyPDFView(code: recoveryCode))
        pdfController.loadView()

        let pdfRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        pdfController.view.frame = CGRect(x: 0, y: 0, width: pdfRect.width, height: pdfRect.height + 100)
        pdfController.view.insetsLayoutMarginsFromSafeArea = false

        let rootVC = UIApplication.shared.windows.first?.rootViewController
        rootVC?.addChild(pdfController)
        rootVC?.view.insertSubview(pdfController.view, at: 0)
        defer {
            pdfController.view.removeFromSuperview()
        }

        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = [
            kCGPDFContextTitle as String: "DuckDuckGo Sync Recovery Code"
        ]

        let renderer = UIGraphicsPDFRenderer(bounds: pdfRect, format: format)
        let data = renderer.pdfData { context in
            context.beginPage()
            context.cgContext.translateBy(x: 0, y: -100)
            pdfController.view.layer.render(in: context.cgContext)

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 1.55

            recoveryCode.draw(in: CGRect(x: 240, y: 380, width: 294, height: 1000), withAttributes: [
                .font: UIFont.monospacedSystemFont(ofSize: 13, weight: .regular),
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraphStyle,
                .kern: 2
            ])
        }

        let pdf = RecoveryCodeItem(data: data)
        navigationController?.visibleViewController?.presentShareSheet(withItems: [pdf],
                                                                       fromView: view) { [weak self] _, success, _, _ in
            guard success else { return }
            self?.navigationController?.visibleViewController?.dismiss(animated: true)
        }
    }

}

private class RecoveryCodeItem: NSObject, UIActivityItemSource {

    let data: Data

    init(data: Data) {
        self.data = data
        super.init()
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return URL(fileURLWithPath: "DuckDuckGo Sync Recovery Code.pdf")
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        data
    }

}
