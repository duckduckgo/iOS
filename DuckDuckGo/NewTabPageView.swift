//
//  NewTabPageView.swift
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

struct NewTabPageView: View {
    @ObservedObject var favoritesModel: FavoritesModel

    var body: some View {
        ScrollView {
            VStack {
                if favoritesModel.isEmpty {
                    FavoritesEmptyStateView()
                        .padding(Constant.sectionPadding)
                } else {
                    FavoritesView(model: favoritesModel)
                        .padding(Constant.sectionPadding)
                }

                ShortcutsView()
                    .padding(Constant.sectionPadding)

                Button(action: {
                    // Temporary action for testing purposes
                    favoritesModel.toggleFavoritesPresence()
                }, label: {
                    NewTabPageCustomizeButtonView()
                }).buttonStyle(SecondaryFillButtonStyle(compact: true, fullWidth: false))
                    .padding(EdgeInsets(top: 88, leading: 0, bottom: 16, trailing: 0))
            }
        }
        .background(Color(designSystemColor: .background))
    }

    private struct Constant {
        static let sectionPadding = EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24)
    }
}

#Preview {
    NewTabPageView(favoritesModel: FavoritesModel())
}
