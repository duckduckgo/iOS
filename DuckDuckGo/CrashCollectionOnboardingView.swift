//
//  CrashCollectionOnboardingView.swift
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
import DuckUI
import DesignResourcesKit

struct CrashCollectionOnboardingView: View {

    @ObservedObject var model: CrashCollectionOnboardingViewModel

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                contents
            }
        } else {
            NavigationView {
                contents
            }
        }
    }

    var contents: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    Image("Breakage-128")

                    Text(UserText.crashReportDialogTitle)
                        .daxTitle1()

                    Text(UserText.crashReportDialogMessage)
                        .multilineTextAlignment(.center)
                        .daxBodyRegular()

                    if let reportDetails = model.reportDetails {
                        VStack(spacing: 4) {

                            reportDetailsButton

                            if model.isShowingReport, #available(iOS 16.0, *) {
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(Color.init(designSystemColor: .container))
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .cornerRadius(4.0)

                                    Text(reportDetails)
                                        .font(.crashReport)
                                        .secondaryTextStyle()
                                        .padding(24)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
            .modifier(ScrollDisabledIfAvailable(isDisabled: !model.isShowingReport))

            VStack(spacing: 8) {
                Button {
                    withAnimation {
                        model.crashCollectionOptInStatus = .optedIn
                        model.onDismiss(.optedIn)
                    }
                } label: {
                    Text(UserText.crashReportAlwaysSend)
                }
                .buttonStyle(PrimaryButtonStyle())
                .frame(maxWidth: 360)

                Button {
                    withAnimation {
                        model.crashCollectionOptInStatus = .optedOut
                        model.onDismiss(.optedOut)
                    }
                } label: {
                    Text(UserText.crashReportNeverSend)
                }
                .buttonStyle(SecondaryButtonStyle())
                .frame(maxWidth: 360)
            }
            .padding(.init(top: 24, leading: 24, bottom: 0, trailing: 24))
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                Button {
                    withAnimation {
                        model.onDismiss(.undetermined)
                    }
                } label: {
                    Text(UserText.keyCommandClose)
                }
                .buttonStyle(.plain)
            }
        }
    }

    var reportDetailsButton: some View {
        Button {
            withAnimation {
                model.isShowingReport.toggle()
            }
        } label: {
            HStack {
                Text(model.isShowingReport ? UserText.crashReportHideDetails : UserText.crashReportShowDetails)
                    .daxButton()

                Image("DisclosureIndicator")
                    .rotationEffect(model.isShowingReport ? .degrees(-90) : .degrees(90))
                    .frame(width: 7, height: 12)
            }
        }
        .buttonStyle(.plain)
        .foregroundColor(Color(designSystemColor: .textSecondary))
        .frame(height: 44)
    }
}

private extension Font {
    static var crashReport: Font {
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .caption2)
        return Font(uiFont: .monospacedSystemFont(ofSize: descriptor.pointSize, weight: .regular))
    }
}

private struct ScrollDisabledIfAvailable: ViewModifier {
    let isDisabled: Bool

    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            return content.scrollDisabled(isDisabled)
        }
        return content
    }
}

#Preview {
    let model = CrashCollectionOnboardingViewModel(appSettings: AppDependencyProvider.shared.appSettings)
    // swiftlint:disable:next line_length
    model.setReportDetails(with: ["test report details test report details test report details test report details test report details\n\ntest report details\ntest report details\ntest report details\ntest report details\ntest report details\ntest report details\ntest report details\ntest report details\ntest report details\ntest report details\ntest report details\ntest report details\ntest report details\ntest report details\ntest report details\ntest report details\ntest report details\ntest report details".data(using: .utf8)!])
    return CrashCollectionOnboardingView(model: model)
}
