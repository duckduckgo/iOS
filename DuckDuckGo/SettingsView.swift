//
//  SettingsView.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import Core
import BrowserServicesKit

struct ModalLink<Label: View, Destination: View>: View {

    @ViewBuilder
    private let destination: () -> Destination
    @ViewBuilder
    private let label: () -> Label

    public init(destination: @autoclosure @escaping () -> Destination, @ViewBuilder label: @escaping () -> Label) {
        self.destination = destination
        self.label = label
    }

    @State var isPresented: Bool = false

    var body: some View {
        Button {
            self.isPresented.toggle()
        } label: {
            NavigationLink(destination: EmptyView(), label: label)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $isPresented, content: destination)
    }

}

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var applicationLock = true

    @State private var autocompleteSuggestions = true
    @State private var privateVoiceSearch = true
    @State private var longPressPreviews = true
    @State private var openLinksInApps = true

    var body: some View {
        NavigationView {
            list
                .navigationBarTitle(Text(UserText.settings), displayMode: .inline)
                .navigationBarItems(trailing: doneButton)
        }
        .navigationViewStyle(.stack)
    }

    private var doneButton: some View {
        Button(action: {
            if #available(iOS 15.0, *) {
                presentationMode.wrappedValue.dismiss()
            } else {
                // Because: presentationMode.wrappedValue.dismiss() for view wrapped in NavigationView() does not work in iOS 14 and lower
                if var topController = UIApplication.shared.windows.first!.rootViewController {
                    while let presentedViewController = topController.presentedViewController {
                        topController = presentedViewController
                    }
                    topController.dismiss(animated: true)
                }
            }
        }, label: {
            Text(UserText.navigationTitleDone)
                .bold()
        })
    }

    @ViewBuilder
    private var list: some View {
        List {
            // MARK: Default Browser
            Section {
                // Set as Default Browser
                Button {
                    Pixel.fire(pixel: .defaultBrowserButtonPressedSettings)
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                } label: {
                    NavigationLink(destination: EmptyView()) {
                        Text(UserText.settingsSetAsDefault)
                    }
                }.buttonStyle(.plain)

                // Add App to Your Dock
                ModalLink(destination: HomeRowView()) {
                    Text(UserText.settingsAddToDock)
                }

                // Add Widget to Home Screen
                NavigationLink(destination: WidgetEducationView()) {
                    Text(UserText.settingsAddWidget)
                }
            }

            // MARK: Sync and Autofill
            Section {
                // Autofill Logins
                NavigationLink(destination: AutofillLoginSettingsView()) {
                    Text(UserText.autofillLoginListTitle)
                }
            }

            // MARK: Appearance
            Section(header: Text(UserText.settingsSectionAppearance)) {
                // Autofill Logins
                NavigationLink(destination: ThemeSettingsView()) {
                    Text(UserText.settingsTheme)
                }

                // App Icon
                NavigationLink(destination: ThemeSettingsView()) {
                    Text(UserText.settingsAppIcon)
                }

                // Fire Button Animation
                NavigationLink(destination: FireButtonAnimationView()) {
                    Text(UserText.settingsFireButtonAnimation)
                }

                // Text Size
                NavigationLink(destination: TextSizeSettingsView()) {
                    Text(UserText.settingsTextSize)
                }
            }

            // MARK: Privacy
            Section(header: Text(UserText.settingsSectionPrivacy),
                    footer: Text(UserText.settingsSectionPrivacyFooter)) {
                // Global Privacy Control
                NavigationLink(destination: GPCSettingsView()) {
                    Text(UserText.settingsGPC)
                }

                // Unprotected Sites
                NavigationLink(destination: UnprotectedSitesView()) {
                    Text(UserText.settingsUnprotectedSites)
                }

                // Fireproof Sites
                NavigationLink(destination: FireproofSitesView()) {
                    Text(UserText.preserveLoginsListTitle)
                }

                // Automatically Clear Data
                NavigationLink(destination: AutoClearSettingsView()) {
                    Text(UserText.settingsAutomaticClear)
                }

                // Application Lock
                Toggle(UserText.settingsApplicationLock, isOn: $applicationLock)
            }

            // MARK: Customize
            Section(header: Text(UserText.settingsSectionCustomize),
                    footer: Text(UserText.settingsSectionCustomizeFooter)) {

                // Keyboard
                NavigationLink(destination: KeyboardSettingsView()) {
                    Text(UserText.settingsKeyboard)
                }

                // Autocomplete Suggestions
                Toggle(UserText.settingsAutocompleteSuggestions, isOn: $autocompleteSuggestions)

                // Private Voice Search
                Toggle(UserText.settingsPrivateVoiceSearch, isOn: $privateVoiceSearch)

                // Long Press Previews
                Toggle(UserText.settingsLongPressPreviews, isOn: $longPressPreviews)

                // Open Links in Associated Apps
                Toggle(UserText.settingsOpenLinksInApps, isOn: $openLinksInApps)

            }

            // MARK: More from DuckDuckGo
            Section(header: Text(UserText.settingsSectionMore)) {

                // Email Protection
                NavigationLink(destination: emailProtectionOrWaitlist()) {
                    VStack(alignment: .leading) {
                        Text(UserText.settingsEmailProtection)
                        Text(UserText.settingsEmailProtectionDescription)
                            .font(.subheadline)
                    }
                }

                // Desktop App
                NavigationLink(destination: MacBrowserWaitlistView()) {
                    VStack(alignment: .leading) {
                        Text(UserText.settingsDesktopApp)
                        Text(UserText.settingsDesktopAppDescription)
                            .font(.subheadline)
                    }
                }

            }

            // MARK: About
            Section(header: Text(UserText.settingsSectionAbout)) {

                // About
                NavigationLink(destination: AboutView()) {
                    Text(UserText.settingsAbout)
                }

                // Version
                HStack {
                    Text(UserText.settingsVersion)
                    Spacer()
                    Text("0.1.1")
                }

                // Share Feedback
                ModalLink(destination: FeedbackView()) {
                    Text(UserText.settingsShareFeedback)
                }

            }

            // MARK: Debug
            Section {
                ModalLink(destination: DebugMenuView()) {
                    Text("Debug Menu")
                }
            }

        }
        .listStyle(.insetGrouped)
    }

    @ViewBuilder
    func emailProtectionOrWaitlist() -> some View {
        if EmailManager().isSignedIn {
            EmailProtectionView()
        } else {
            EmailWaitlistView()
        }
    }

}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
