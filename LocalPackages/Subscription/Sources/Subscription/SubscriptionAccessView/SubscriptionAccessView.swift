//
//  SubscriptionAccessView.swift
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
import SwiftUIExtensions

public struct SubscriptionAccessView: View {

    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    private let model: SubscriptionAccessModel

    private let dismissAction: (() -> Void)?

    @State private var selection: AccessChannel? = .appleID
    @State var fullHeight: CGFloat = 0.0

    public init(model: SubscriptionAccessModel, dismiss: (() -> Void)? = nil) {
        self.model = model
        self.dismissAction = dismiss
    }

    public var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 8) {
                Text(model.title)
                    .font(.title2)
                    .bold()
                    .foregroundColor(Color("TextPrimary", bundle: .module))
                Text(model.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .fixMultilineScrollableText()
                    .foregroundColor(Color("TextPrimary", bundle: .module))
            }
            .padding(4)

            VStack(spacing: 0) {
                ForEach(model.items) { item in
                    SubscriptionAccessRow(iconName: item.iconName,
                                          name: item.title,
                                          descriptionHeader: model.descriptionHeader(for: item),
                                          description: model.description(for: item),
                                          isExpanded: self.selection == item,
                                          buttonTitle: model.buttonTitle(for: item),
                                          buttonAction: {
                        dismiss {
                            model.handleAction(for: item)
                        }
                    })
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.selection = item
                        }
                        .padding(.vertical, 10)

                    if model.items.last != item {
                        Divider()
                    }
                }
                .padding(.horizontal, 20)

            }
            .roundedBorder()
            .animation(.easeOut(duration: 0.3))

            Spacer()
                .frame(minHeight: 4, idealHeight: 60)

            Divider()

            Spacer()
                .frame(height: 8)

            HStack {
                Spacer()

                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .padding(20)
        .frame(width: 480)
    }

    private func dismiss(completion: (() -> Void)? = nil) {
        dismissAction?()
        presentationMode.wrappedValue.dismiss()

        if let completion = completion {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                completion()
            }
        }
    }
}
