//
//  TextZoomController.swift
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

import UIKit
import SwiftUI

class TextZoomController: UIHostingController<TextZoomEditorView> {

    let storage: DomainTextZoomStoring
    let model: TextZoomEditorModel

    @MainActor init(domain: String, storage: DomainTextZoomStoring, defaultTextZoom: TextZoomLevel) {
        self.storage = storage
        self.model = TextZoomEditorModel(domain: domain, storage: storage, defaultTextZoom: defaultTextZoom)
        super.init(rootView: TextZoomEditorView(model: model))
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class TextZoomEditorModel: ObservableObject {

    let domain: String
    let storage: DomainTextZoomStoring

    var valueAsPercent: Int {
        TextZoomLevel.allCases[value].rawValue
    }

    @Published var value: Int = 0 {
        didSet {
            title = UserText.pageZoomWithPercent(valueAsPercent)
            storage.set(textZoomLevel: TextZoomLevel.allCases[value], forDomain: domain)
            NotificationCenter.default.post(
                name: AppUserDefaults.Notifications.textSizeChange,
                object: nil)
        }
    }

    @Published var title: String = ""

    init(domain: String, storage: DomainTextZoomStoring, defaultTextZoom: TextZoomLevel) {
        self.domain = domain
        self.storage = storage
        let percent = (storage.textZoomLevelForDomain(domain) ?? defaultTextZoom)
        value = TextZoomLevel.allCases.firstIndex(of: percent) ?? 0
    }

    func increment() {
        value = min(TextZoomLevel.allCases.count - 1, value + 1)
    }

    func decrement() {
        value = max(0, value - 1)
    }

}

struct TextZoomEditorView: View {

    @ObservedObject var model: TextZoomEditorModel

    @Environment(\.dismiss) var dismiss

    @ViewBuilder
    func header() -> some View {
        ZStack(alignment: .center) {
            Text(model.title)
                .font(Font(uiFont: .daxHeadline()))
                .frame(alignment: .center)

            Button {
                dismiss()
            } label: {
                Text(UserText.navigationTitleDone)
                    .font(Font(uiFont: .daxHeadline()))
            }
            .buttonStyle(.plain)
            .padding(0)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(16)
    }

    func slider() -> some View {
        HStack {
            Button {
                model.decrement()
            } label: {
                Image("Font-Smaller-24")
            }
            .foregroundColor(Color(designSystemColor: .textPrimary))
            .padding(12)

            IntervalSliderRepresentable(
                value: $model.value,
                steps: TextZoomLevel.allCases.map { $0.rawValue })
            .padding(.vertical)

            Button {
                model.increment()
            } label: {
                Image("Font-Larger-24")
            }
            .foregroundColor(Color(designSystemColor: .textPrimary))
            .padding(12)
        }
        .background(RoundedRectangle(cornerRadius: 8).foregroundColor(Color(designSystemColor: .surface)))
        .padding(16)

    }

    var body: some View {
        VStack {
            header()
            Spacer()
            slider()
            Spacer()
        }
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity)
        .background(Color(designSystemColor: .background))
    }

}

extension TabViewController {

    func showTextZoomAdjustment() {
        guard let domain = webView.url?.host?.droppingWwwPrefix() else { return }
        let controller = TextZoomController(
            domain: domain,
            storage: domainTextZoomStorage,
            defaultTextZoom: appSettings.defaultTextZoomLevel
        )

        controller.modalPresentationStyle = .formSheet
        if #available(iOS 16.0, *) {
            controller.sheetPresentationController?.detents = [.custom(resolver: { _ in
                return 180
            })]
        } else {
            controller.sheetPresentationController?.detents = [.medium()]
        }
        present(controller, animated: true)
    }

}
