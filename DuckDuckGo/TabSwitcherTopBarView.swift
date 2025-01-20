//
//  TabSwitcherTopBarView.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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

struct TabSwitcherTopBarView: View {

    @ObservedObject var model: TabSwitcherTopBarModel

    @ViewBuilder func bookmarkAllButton() -> some View {
        Button {
            model.onBookmarkAllPressed()
        } label: {
            Image("Bookmark-New-24")
        }
    }

    @ViewBuilder func modeButton() -> some View {
        Button {
            model.toggleTabsStyle()
        } label: {
            Image(model.tabsStyle.rawValue)
        }
    }

    @ViewBuilder func editButton() -> some View {
        Button {
            model.onEditPressed()
        } label: {
            Text(UserText.navigationTitleEdit)
        }
    }

    @ViewBuilder func doneButton() -> some View {
        Button {
            model.onDonePressed()
        } label: {
            Text(UserText.navigationTitleDone)
        }
    }

    @ViewBuilder func plusButton() -> some View {
        Button {
            model.onPlusPressed()
        } label: {
            Image("Add-24")
        }
    }

    @ViewBuilder func fireButton() -> some View {
        Button {
            model.onFirePressed()
        } label: {
            Image("Fire")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 22) // make it look closer to size on parent screen
                .background {
                    GeometryReader { geo in
                        Color
                            .clear
                            .onAppear {
                                model.locationOfFireButton(geo.frame(in: .global))
                            }
                    }
                }
        }
    }

    var body: some View {
        HStack(spacing: 24) {

            switch model.uiModel {

            case .singleSelectNormal:
                bookmarkAllButton()

            case .singleSelectLarge:
                bookmarkAllButton()
                modeButton()

            case .multiSelectNormal:
                modeButton()

            case .multiSelectLarge:
                editButton()
                modeButton()
            }

            Text(model.title)
                .frame(maxWidth: .infinity)
                .font(.headline)

            switch model.uiModel {
            case .singleSelectNormal:
                modeButton()

            case .multiSelectNormal:
                editButton()

            case .singleSelectLarge,
                    .multiSelectLarge:
                plusButton()
                fireButton()
                doneButton()
            }
        }
        .padding(.horizontal, 16)
    }

}

class TabSwitcherTopBarModel: ObservableObject {

    protocol Delegate: AnyObject {

        func onTabStyleChange()
        func burn()
        func startEditing()
        func dismiss()
        func addNewTab()
        func bookmarkAll()

    }

    enum UIMode {

        case singleSelectNormal
        case singleSelectLarge
        case multiSelectNormal
        case multiSelectLarge

    }

    enum TabsStyleToggle: String {

        case list = "tabsToggleList"
        case grid = "tabsToggleGrid"

    }

    weak var delegate: Delegate?
    var fireButtonFrame: CGRect?

    @Published var uiModel: UIMode = .singleSelectNormal
    @Published var title = ""
    @Published var tabsStyle: TabsStyleToggle = .grid

    func toggleTabsStyle() {
        if tabsStyle == .grid {
            tabsStyle = .list
        } else {
            tabsStyle = .grid
        }
        delegate?.onTabStyleChange()
    }

    func onEditPressed() {
        delegate?.startEditing()
    }

    func onDonePressed() {
        delegate?.dismiss()
    }

    func onPlusPressed() {
        delegate?.addNewTab()
    }

    func onFirePressed() {
        delegate?.burn()
    }

    func onBookmarkAllPressed() {
        delegate?.bookmarkAll()
    }

    func locationOfFireButton(_ point: CGRect) {
        fireButtonFrame = point
    }

}
