//
//  MacPromoViewController.swift
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
import DesignResourcesKit
import DuckUI

class MacPromoViewController: UIHostingController<MacPromoView> {

    convenience init() {
        self.init(rootView: MacPromoView())
        modalPresentationStyle = .overCurrentContext
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        isPad ? .all : .portrait
    }

}

struct MacPromoView: View {

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {

            HStack {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Close")
                        .bold()
                        .foregroundColor(.black)
                }
                .padding()

                Spacer()

            }.frame(height: 56)

            VStack {

                Image("RemoteMessageMacComputer")
                    .resizable()
                    .frame(width: 200, height: 200)
                    .padding(.bottom, 16)

                Text("Get DuckDuckGo Browser for Mac")
                    .daxTitle1()
                    .foregroundColor(Color(designSystemColor: .textPrimary))
                    .padding(.bottom, 24)

                Text("Search privately, block trackers and hide cookie pop-ups on your Mac for free!")
                    .daxHeadline()
                    .foregroundColor(Color(designSystemColor: .textPrimary))
                    .padding(.bottom, 24)

                Text("Send a link to yourself for later:")
                    .daxBodyRegular()
                    .foregroundColor(Color(designSystemColor: .textPrimary))
                    .padding(.bottom, 16)

                Button {
                    print("Share!")
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Send Link")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.bottom, 24)

                Text("Or on your Mac, go to:")
                    .daxSubheadRegular()
                    .foregroundColor(Color(designSystemColor: .textPrimary))
                    .padding(.bottom, 4)

                Text("duckduckgo.com/mac")
                    .daxSubheadSemibold()
                    .foregroundColor(Color(.link))

                Spacer()

            }
            .padding(.horizontal, 32)
            .frame(maxWidth: 514)
        }
        .multilineTextAlignment(.center)
    }

}
