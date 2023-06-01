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

    convenience init() {
        self.init(rootView: MacPromoView())
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
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // This means the user did a swipe down, or closed the UI in some other way
        //  ie they didn't click close or use the share link
        if !rootView.model.programaticallyClosed {
            experiment.sheetWasDismissed()
        }

    }

    class ViewModel: ObservableObject {

        weak var controller: MacPromoViewController?

        var programaticallyClosed = false

        var messageId: String {
            controller?.message?.id ?? ""
        }

        var activityItem: TitledURLActivityItem? {
            guard let message = controller?.message else { return nil }
            switch message.content {
            case .bigSingleAction(_, _, _, _, let action):
                guard case .share(let url, let title) = action,
                        let url = URL(string: url) else { return nil }

                return TitledURLActivityItem(url, title)

            default:
                assertionFailure("unexpected content for mac promo")
                return nil
            }
        }

        func shareSheetFinished(_ activityType: UIActivity.ActivityType?, _ result: Bool, _ items: [Any]?, _ error: Error?) {
            programaticallyClosed = true
            controller?.experiment.shareSheetFinished(messageId, activityType: activityType, result: result, error: error)
            controller?.dismiss(animated: true)
        }

        func close() {
            programaticallyClosed = true
            controller?.experiment.sheetWasDismissed()
            controller?.dismiss(animated: true)
        }

    }
    
}

struct MacPromoView: View {

    @ObservedObject var model = MacPromoViewController.ViewModel()
    @State var activityItem: TitledURLActivityItem?

    var body: some View {
        VStack {

            HStack {
                Button {
                    model.close()
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
                    activityItem = model.activityItem
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Send Link")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.bottom, 24)
                .sheet(item: $activityItem) { activityItem in
                    ActivityViewController(activityItems: [activityItem],
                                           applicationActivities: nil,
                                           completionWithItemsHandler: model.shareSheetFinished)
                    .modifier(ActivityViewPresentationModifier())
                }

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
