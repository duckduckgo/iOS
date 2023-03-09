//
//  RecoveryKeyPDFView.swift
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

// Will externalise strings once we work out how to share this with macOS
public struct RecoveryKeyPDFView: View {

    let code: String

    public init(code: String) {
        self.code = code
    }

    @ViewBuilder
    func codeBoxHeader() -> some View {
        VStack(spacing: 0) {
            Text("Keep this information safe and secure.")
                .font(.system(size: 13, weight: .semibold))
                .lineSpacing(1.03)
                .foregroundColor(.white)
                .padding(.top, 6)

            Text("Anyone with access to this code can access your synced data.")
                .font(.system(size: 10, weight: .regular))
                .lineSpacing(1.09)
                .foregroundColor(.white)
                .padding(.top, 2)
        }
    }

    @ViewBuilder
    func headerImage() -> some View {
        Image("SyncSuccess")
            .padding(.top, 28)
    }

    @ViewBuilder
    func title() -> some View {
        Text("Sync Recovery Code")
            .font(.system(size: 22))
    }

    @ViewBuilder
    func information() -> some View {
        // swiftlint:disable line_length
        Text("The Recovery Code allows you to sync your bookmarks across multiple devices and recover your synced data if you lose access to a device.")
            .font(.system(size: 12))
            .lineSpacing(1.167)
            .lineLimit(2)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 54)
        // swiftlint:enable line_length
    }

    @ViewBuilder
    func codeBox() -> some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                codeBoxHeader()

                ZStack {
                    HStack {
                        QRCodeView(string: code, size: 144, style: .light)
                        Spacer()
                    }
                }
                .padding(24)
                .background(
                    ZStack(alignment: .top) {
                        RoundedRectangle(cornerRadius: 8).foregroundColor(.white)
                        Rectangle()
                            .foregroundColor(.white)
                            .frame(height: 10)
                    }
                )
                .padding(.top, 6)
            }
            .padding(1)
        }
        .background(ZStack {
            RoundedRectangle(cornerRadius: 8).foregroundColor(.blue80)

            RoundedRectangle(cornerRadius: 8).foregroundColor(.blueBase)
                .padding(1)
        })
        .padding(.top, 28)
        .padding(.horizontal, 54)
    }

    @ViewBuilder
    func instructionsTitle() -> some View {
        Text("How does this code work?")
            .font(.system(size: 17, weight: .bold))
    }

    @ViewBuilder
    func step(id: Int, text: String) -> some View {
        VStack(spacing: 16) {
            Text("\(id)")
                .foregroundColor(.white)
                .font(.system(size: 17, weight: .bold))
                .background(Circle()
                    .frame(width: 36, height: 36)
                    .foregroundColor(.blueBase))

            Text(text)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .lineSpacing(0.98)
                .font(.system(size: 12))
        }
        .frame(width: 156)
    }

    @ViewBuilder
    func instructions() -> some View {
        HStack {

            step(id: 1, text: "Open DuckDuckGo on another device and go to Sync in Settings.")

            step(id: 2, text: "Go to Scan QR Code and scan the QR code or copy and paste the text code.")

            step(id: 3, text: "Sync will be activated and you'll once again have access to all of your data.")

        }
    }

    @ViewBuilder
    func appLogo() -> some View {
        Image("LogoDarkText")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 72)
    }

    public var body: some View {
        VStack(spacing: 0) {
            headerImage()

            title()
                .padding(.top, 14.25)

            information()
                .padding(.top, 10)

            codeBox()

            instructionsTitle()
                .padding(.top, 28)

            instructions()
                .padding(.top, 28)

            Divider()
                .frame(width: 280)
                .padding(.top, 28)

            appLogo()
                .padding(.top, 10)

        }
    }

}
