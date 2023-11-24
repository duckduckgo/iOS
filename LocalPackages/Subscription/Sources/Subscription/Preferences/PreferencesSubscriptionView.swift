//
//  PreferencesSubscriptionView.swift
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

public struct PreferencesSubscriptionView: View {
    @ObservedObject var model: PreferencesSubscriptionModel
    @State private var showingSheet = false
    @State private var showingRemoveConfirmationDialog = false

    public init(model: PreferencesSubscriptionModel) {
        self.model = model
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            TextMenuTitle(text: UserText.preferencesTitle)
                .sheet(isPresented: $showingSheet) {
                    SubscriptionAccessView(model: model.sheetModel)
                }
                .sheet(isPresented: $showingRemoveConfirmationDialog) {
                    Dialog(spacing: 20) {
                        Image("Placeholder-96x64", bundle: .module)
                        Text(UserText.removeSubscriptionDialogTitle)
                            .font(.title2)
                            .bold()
                            .foregroundColor(Color("TextPrimary", bundle: .module))
                        Text(UserText.removeSubscriptionDialogDescription)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .fixMultilineScrollableText()
                            .foregroundColor(Color("TextPrimary", bundle: .module))
                    } buttons: {
                        Button(UserText.removeSubscriptionDialogCancel) { showingRemoveConfirmationDialog = false }
                        Button(action: {
                            showingRemoveConfirmationDialog = false
                            model.removeFromThisDeviceAction()
                        }, label: {
                            Text(UserText.removeSubscriptionDialogConfirm)
                                .foregroundColor(.red)
                        })
                    }
                    .frame(width: 320)
                }

            Spacer()
                .frame(height: 20)

            VStack {
                if model.isUserAuthenticated {
                    UniversalHeaderView {
                        Image("subscription-active-icon", bundle: .module)
                            .padding(4)
                    } content: {
                        TextMenuItemHeader(text: UserText.preferencesSubscriptionActiveHeader)
                        TextMenuItemCaption(text: UserText.preferencesSubscriptionActiveCaption)
                    } buttons: {
                        Button(UserText.addToAnotherDeviceButton) { showingSheet.toggle() }

                        Menu {
                            Button(UserText.changePlanOrBillingButton, action: { model.changePlanOrBillingAction() })
                            Button(UserText.removeFromThisDeviceButton, action: {
                                showingRemoveConfirmationDialog.toggle()
                            })
                        } label: {
                            Text(UserText.manageSubscriptionButton)
                        }
                        .fixedSize()
                    }
                    .onAppear {
                        model.fetchEntitlements()
                    }

                } else {
                    UniversalHeaderView {
                        Image("subscription-inactive-icon", bundle: .module)
                            .padding(4)
                            .background(Color.black.opacity(0.06))
                            .cornerRadius(4)
                    } content: {
                        TextMenuItemHeader(text: UserText.preferencesSubscriptionInactiveHeader)
                        TextMenuItemCaption(text: UserText.preferencesSubscriptionInactiveCaption)
                    } buttons: {
                        Button(UserText.learnMoreButton) { model.learnMoreAction() }
                            .buttonStyle(DefaultActionButtonStyle(enabled: true))
                        Button(UserText.haveSubscriptionButton) { showingSheet.toggle() }
                    }
                }

                Divider()
                    .foregroundColor(Color.secondary)
                    .padding(.horizontal, -10)

                SectionView(iconName: "vpn-service-icon",
                            title: UserText.vpnServiceTitle,
                            description: UserText.vpnServiceDescription,
                            buttonName: model.isUserAuthenticated ? "Manage" : nil,
                            buttonAction: { model.openVPN() },
                            enabled: model.hasEntitlements)

                Divider()
                    .foregroundColor(Color.secondary)

                SectionView(iconName: "pir-service-icon",
                            title: UserText.personalInformationRemovalServiceTitle,
                            description: UserText.personalInformationRemovalServiceDescription,
                            buttonName: model.isUserAuthenticated ? "View" : nil,
                            buttonAction: { model.openPersonalInformationRemoval() },
                            enabled: model.hasEntitlements)

                Divider()
                    .foregroundColor(Color.secondary)

                SectionView(iconName: "itr-service-icon",
                            title: UserText.identityTheftRestorationServiceTitle,
                            description: UserText.identityTheftRestorationServiceDescription,
                            buttonName: model.isUserAuthenticated ? "View" : nil,
                            buttonAction: { model.openIdentityTheftRestoration() },
                            enabled: model.hasEntitlements)
            }
            .padding(10)
            .roundedBorder()

            PreferencePaneSection {
                TextMenuItemHeader(text: UserText.preferencesSubscriptionFooterTitle)
                HStack(alignment: .top, spacing: 6) {
                    TextMenuItemCaption(text: UserText.preferencesSubscriptionFooterCaption)
                    Button(UserText.viewFaqsButton) { model.openFAQ() }
                }
            }
        }
    }
}

struct UniversalHeaderView<Icon, Content, Buttons>: View where Icon: View, Content: View, Buttons: View {

    @ViewBuilder let icon: () -> Icon
    @ViewBuilder let content: () -> Content
    @ViewBuilder let buttons: () -> Buttons

    init(@ViewBuilder icon: @escaping () -> Icon, @ViewBuilder content: @escaping () -> Content, @ViewBuilder buttons: @escaping () -> Buttons) {
        self.icon = icon
        self.content = content
        self.buttons = buttons
    }

    public var body: some View {
        HStack(alignment: .top) {
            icon()
            VStack(alignment: .leading, spacing: 8) {

                content()
                HStack {
                    buttons()
                }
                .padding(.top, 10)
            }
            Spacer()
        }
        .padding(.vertical, 10)
    }
}

public struct SectionView: View {
    public var iconName: String
    public var title: String
    public var description: String
    public var buttonName: String?
    public var buttonAction: (() -> Void)?
    public var enabled: Bool

    public init(iconName: String, title: String, description: String, buttonName: String? = nil, buttonAction: (() -> Void)? = nil, enabled: Bool = true) {
        self.iconName = iconName
        self.title = title
        self.description = description
        self.buttonName = buttonName
        self.buttonAction = buttonAction
        self.enabled = enabled
    }

    public var body: some View {
        VStack(alignment: .center) {
            VStack {
                HStack(alignment: .center, spacing: 8) {
                    Image(iconName, bundle: .module)
                        .padding(4)
                        .background(Color("BadgeBackground", bundle: .module))
                        .cornerRadius(4)

                    VStack(alignment: .leading) {
                        Text(title)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixMultilineScrollableText()
                            .font(.body)
                            .foregroundColor(Color("TextPrimary", bundle: .module))
                        Text(description)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixMultilineScrollableText()
                            .font(.system(size: 11, weight: .regular, design: .default))
                            .foregroundColor(Color("TextSecondary", bundle: .module))
                    }

                    if let name = buttonName, !name.isEmpty, let action = buttonAction {
                        Button(name) { action() }
                    }
                }
            }
        }
        .padding(.vertical, 7)
        .disabled(!enabled)
        .opacity(enabled ? 1.0 : 0.6)
    }
}

enum Const {

    static let pickerHorizontalOffset: CGFloat = {
        if #available(macOS 12.0, *) {
            return -8
        } else {
            return 0
        }
    }()

    enum Fonts {
        static let popUpButton: NSFont = .preferredFont(forTextStyle: .title1, options: [:])
        static let sideBarItem: Font = .body
        static let preferencePaneTitle: Font = .title2.weight(.semibold)
        static let preferencePaneSectionHeader: Font = .title3.weight(.semibold)
        static let preferencePaneDisclaimer: Font = .subheadline
    }
}

struct TextMenuTitle: View {
    let text: String

    var body: some View {
        Text(text)
            .font(Const.Fonts.preferencePaneTitle)
    }
}

struct TextMenuItemHeader: View {
    let text: String

    var body: some View {
        Text(text)
            .font(Const.Fonts.preferencePaneSectionHeader)
    }
}

struct TextMenuItemCaption: View {
    let text: String

    var body: some View {
        Text(text)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixMultilineScrollableText()
            .foregroundColor(Color("GreyTextColor"))
    }
}
