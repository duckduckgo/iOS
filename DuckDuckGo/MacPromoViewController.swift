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
import LinkPresentation
import BrowserServicesKit

class MacPromoViewController: UIHostingController<MacPromoView> {

    let experiment = MacPromoExperiment()
    var message: RemoteMessageModel?
    var anchor: UIView!

    convenience init() {
        self.init(rootView: MacPromoView())
        self.anchor = UIView(frame: .zero)
        rootView.model.controller = self
        message = experiment.message
        assert(message != nil)
        modalPresentationStyle = .pageSheet
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        isPad ? .all : .portrait
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        experiment.sheetWasShown()
        anchor.center = view.center
        view.addSubview(anchor)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        experiment.sheetWasDismissed()
    }

    class ViewModel: ObservableObject {

        weak var controller: MacPromoViewController?

        func shareLink() {
            guard let message = controller?.message else { return }
            switch message.content {
            case .bigSingleAction(_, _, _, _, let action):
                guard case .share(let url, let title) = action else { return }
                controller?.experiment.sheetPrimaryActionClicked()
                ShareLinkNotification.postShareLinkNotification(urlString: url, title: title)
            default:
                assertionFailure("unexpected content for mac promo")
            }
        }

    }
    
}

struct MacPromoView: View {

    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var model = MacPromoViewController.ViewModel()

    var body: some View {
        VStack {

            HStack {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Close")
                        .bold()
                        .foregroundColor(.primary)
                }
                .padding()

                Spacer()

            }.frame(height: 56)

            VStack {

                Image("RemoteMessageMacComputer")
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
                    model.shareLink()
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
