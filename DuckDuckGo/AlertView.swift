//
//  AlertView.swift
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

import Foundation
import SwiftUI

struct AlertButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.18))
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }

}

struct AlertView: View {
    let question: String
    let onYes: () -> Void
    let onNo: () -> Void
    @Binding var isVisible: Bool

    var body: some View {
        if isVisible {
            VStack(alignment: .leading) {
                HStack(spacing: 5) {
                    Image("ChatPrivate")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 53)
                    Text(question)
                        .font(.headline)
                        .foregroundColor(.white)
                }

                HStack(spacing: 10) {
                    Group {
                        Button("Yes") {
                            onYes()
                            isVisible = false
                        }
                        Button("No") {
                            onNo()
                            isVisible = false
                        }
                    }
                    .buttonStyle(AlertButtonStyle())
                }

            }
            .padding()
            .background(Color.black.opacity(0.9))
            .cornerRadius(10)
        }
    }
}

struct AlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlertView(question: "Did turning Privacy Protections off resolve the issue on this site?",
                  onYes: {},
                  onNo: {},
                  isVisible: Binding<Bool>(get: { true },
                                           set: { _ in }))
    }
}
