//
//  SwipeToBurnView.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

struct SwipeToBurnView: View {

    @Environment(\.dismiss) var dismiss

    let confirm: () -> Void

    @State private var dragOffset: CGFloat = 0.0
    @State private var maxWidth: CGFloat = 0.0
    @State private var fired = false

    var body: some View {
        VStack {
            HStack {
                Text("Swipe to Close Tabs and Clear Data")
                    .fontWeight(.bold)
                    .foregroundStyle(.red)
                Spacer()
                Button("Cancel") {
                    dismiss()
                }
            }

            Spacer()

            GeometryReader { proxy in
                HStack {
                    Image("Fire")
                        .padding()
                        .frame(width: 50)
                        .background(Color.red)
                        .cornerRadius(10)
                        // .foregroundColor(.white)
                        .shadow(color: .gray, radius: 3, x: 3, y: 3)
                        .offset(x: dragOffset, y: 0)
                        .zIndex(10)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    dragOffset = min(value.translation.width, proxy.size.width - 60)
                                    if dragOffset >= proxy.size.width - 62 && !fired {
                                        dismiss()
                                        confirm()
                                        fired = true
                                    }
                                }.onEnded { _ in
                                    withAnimation {
                                        dragOffset = 0
                                    }
                                })

                    Spacer()

                    Text(">")
                    Spacer()
                    Text(">")
                    Spacer()
                    Text(">")
                    Spacer()

                    Image("Fire")
                        .padding()

                }
                .padding(.horizontal, 4)

                .background {
                    RoundedRectangle(cornerRadius: 8)
                    // .fill(.gray.opacity(0.5))
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.gray, Color.white]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(height: 50)
                }

            }
        }
        .padding(12)
    }
}

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color.white)
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 8)
            }
    }

}

#Preview {
    SwipeToBurnView {
        print("confirmed")
    }
}
