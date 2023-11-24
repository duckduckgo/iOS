//
//  PurchaseInProgressViewController.swift
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

import AppKit
import SwiftUI

public final class PurchaseInProgressViewController: NSViewController {

    private var purchaseInProgressView: PurchaseInProgressView?
    private var viewModel: PurchaseInProgressViewModel

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(title: String) {
        self.viewModel = PurchaseInProgressViewModel(title: title)
        super.init(nibName: nil, bundle: nil)
    }

    public override func loadView() {

        let purchaseInProgressView = PurchaseInProgressView(viewModel: viewModel)
        let hostingView = NSHostingView(rootView: purchaseInProgressView)

        self.purchaseInProgressView = purchaseInProgressView

        view = NSView(frame: NSRect(x: 0, y: 0, width: 360, height: 160))
        hostingView.frame = view.bounds
        hostingView.autoresizingMask = [.height, .width]
        hostingView.translatesAutoresizingMaskIntoConstraints = true

        view.addSubview(hostingView)
    }

    public func updateTitleText(_ text: String) {
        self.viewModel.title = text
    }
}

final class PurchaseInProgressViewModel: ObservableObject {
    @Published var title: String

    init(title: String) {
        self.title = title
    }
}

struct PurchaseInProgressView: View {

    @ObservedObject var viewModel: PurchaseInProgressViewModel

    public var body: some View {
        VStack {
            Text(viewModel.title).font(.title)
            Spacer().frame(height: 32)
            ActivityIndicator(isAnimating: .constant(true), style: .spinning)
        }
    }
}
