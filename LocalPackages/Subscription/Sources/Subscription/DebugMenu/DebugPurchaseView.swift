//
//  DebugPurchaseView.swift
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
import StoreKit

@available(macOS 12.0, *)
public struct DebugPurchaseView: View {

    @ObservedObject var model: DebugPurchaseModel
    public let dismissAction: () -> Void

    public var body: some View {
        VStack {
            if model.subscriptions.isEmpty {
                loadingProductsView
            } else {
                purchaseSubscriptionSection
            }

            Divider()

            HStack {
                Spacer()
                Button("Close") {
                    dismissAction()
                }
            }
        }
        .padding(20)
    }

    private var loadingProductsView: some View {
        VStack {
            Text("Loading subscriptions...")
                .font(.largeTitle)
            ActivityIndicator(isAnimating: .constant(true), style: .spinning)
        }
        .padding(.all, 32)
    }

    private var purchaseSubscriptionSection: some View {
        VStack {
            Text("Purchase Subscription")
                .font(.largeTitle)
            Spacer(minLength: 16)
            VStack {
                ForEach(model.subscriptions, id: \.id) { rowModel in
                    SubscriptionRow(product: rowModel.product,
                                    isPurchased: rowModel.isPurchased,
                                    isBeingPurchased: rowModel.isBeingPurchased,
                                    buyButtonAction: { model.purchase(rowModel.product) })
                    Divider()
                }
                .padding(10)
            }
            .roundedBorder()
            Spacer(minLength: 16)
        }
    }
}

struct ActivityIndicator: NSViewRepresentable {

    @Binding var isAnimating: Bool

    let style: NSProgressIndicator.Style

    func makeNSView(context: NSViewRepresentableContext<ActivityIndicator>) -> NSProgressIndicator {
        let progressIndicator = NSProgressIndicator()
        progressIndicator.style = self.style
        progressIndicator.controlSize = .small
        return progressIndicator
    }

    func updateNSView(_ nsView: NSProgressIndicator, context: NSViewRepresentableContext<ActivityIndicator>) {
        if isAnimating {
            nsView.startAnimation(nil)
        } else {
            nsView.stopAnimation(nil)
        }
    }
}

@available(macOS 12.0, *)
struct SubscriptionRow: View {

    var product: Product
    @State var isPurchased: Bool = false
    @State var isBeingPurchased: Bool = false

    var buyButtonAction: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                Text(product.displayName)
                    .font(.title)
                Text(product.description)
                    .font(.body)
                Text("Price: \(product.displayPrice)")
                    .font(.caption)
            }

            Spacer()

            Button {
                buyButtonAction()
            } label: {
                if isPurchased {
                    Text(Image(systemName: "checkmark"))
                        .bold()
                        .foregroundColor(.white)
                } else if isBeingPurchased {
                    ActivityIndicator(isAnimating: .constant(true), style: .spinning)
                } else {
                    Text("Buy")
                        .bold()
                        .foregroundColor(.white)
                }

            }
            .buttonStyle(BuyButtonStyle(isPurchased: isPurchased))

        }
        .disabled(isPurchased)
    }
}

struct CapsuleButton: ButtonStyle {

    @ViewBuilder
    func makeBody(configuration: Configuration) -> some View {
        let background = configuration.isPressed ? Color(white: 0.25) : Color(white: 0.5)

        configuration.label
            .padding(12)
            .background(background)
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
}

@available(macOS 12.0, *)
extension Product {

    var isSubscription: Bool {
        type == .nonRenewable || type == .autoRenewable
    }
}

extension String: Identifiable {
    public typealias ID = Int
    public var id: Int {
        return hash
    }
}

@available(macOS 12.0, *)
struct BuyButtonStyle: ButtonStyle {
    let isPurchased: Bool

    init(isPurchased: Bool = false) {
        self.isPurchased = isPurchased
    }

    func makeBody(configuration: Self.Configuration) -> some View {
        var bgColor: Color = isPurchased ? Color.green : Color.blue
        bgColor = configuration.isPressed ? bgColor.opacity(0.7) : bgColor.opacity(1)

        return configuration.label
            .frame(width: 50)
            .padding(10)
            .background(bgColor)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}
