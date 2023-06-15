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

    override func viewDidLoad() {
        super.viewDidLoad()
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
            homeViewModel?.messageId ?? ""
        }

        var title: String {
            homeViewModel?.title ?? ""
        }

        var subtitle: String {
            homeViewModel?.subtitle ?? ""
        }

        var image: String {
            homeViewModel?.image ?? ""
        }

        var primaryAction: String {
            homeViewModel?.buttons[0].title ?? ""
        }

        lazy var homeViewModel: HomeMessageViewModel? = {
            guard let message = controller?.message else { return nil }
            return HomeMessageViewModelBuilder.build(for: message, onDidClose: { _, _ in })
        }()

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
                        .foregroundColor(Color(designSystemColor: .textPrimary))
                }
                .padding()

                Spacer()

            }.frame(height: 56)

            VStack {

                Image(model.image)
                    .padding(.bottom, 16)

                Text(UIDevice.current.userInterfaceIdiom == .pad ? model.title : model.title.replacingOccurrences(of: "\n", with: " "))
                    .daxTitle1()
                    .foregroundColor(Color(designSystemColor: .textPrimary))
                    .padding(.bottom, 24)

                Text(model.subtitle)
                    .daxHeadline()
                    .foregroundColor(Color(designSystemColor: .textPrimary))
                    .padding(.bottom, 24)

                Button {
                    activityItem = model.activityItem
                } label: {
                    HStack {
                        Image("Share-24")
                            .resizable()
                            .frame(width: 24, height: 24)
                        Text(model.primaryAction)
                            .daxButton()
                    }
                }
                .buttonStyle(HomeMessageButtonStyle(foregroundColor: Color("RemoteMessagePrimaryActionTextColor"),
                                                    backgroundColor: Color(designSystemColor: .accent),
                                                    height: 50))
                .padding(.bottom, 24)
                .sheet(item: $activityItem) { activityItem in
                    ActivityViewController(activityItems: [activityItem],
                                           applicationActivities: nil,
                                           completionWithItemsHandler: model.shareSheetFinished)
                    .modifier(ActivityViewPresentationModifier())
                }

                #warning("Hardcoded for experiment")
                Text("Or visit **duckduckgo.com/browser** on your computer.")
                    .daxSubheadRegular()
                    .foregroundColor(Color(designSystemColor: .textSecondary))
                    .padding(.bottom, 4)

                Spacer()

            }
            .padding(.horizontal, 24)
            .frame(maxWidth: 514)
        }
        .multilineTextAlignment(.center)
    }

}
