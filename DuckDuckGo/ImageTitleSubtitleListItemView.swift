//
//  ImageTitleSubtitleListItemView.swift
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

import SwiftUI
import DuckUI

struct ImageTitleSubtitleListItemView<ViewModel>: View where ViewModel: ImageTitleSubtitleListItemViewModelProtocol {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        HStack(spacing: 10) {
            Image(uiImage: viewModel.image)
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(viewModel.title)
                    .font(Font.system(size: 16))
                    .foregroundColor(.gray90)
                
                Text(viewModel.subtitle)
                    .font(Font.system(size: 13))
                    .foregroundColor(.gray50)
            }
            
            Spacer()
        }
        .frame(height: 60)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
    }
}

#warning("fix with protocol")
//struct ImageTitleSubtitleListItemView_Previews: PreviewProvider {
//    static var previews: some View {
//        ImageTitleSubtitleListItemView()
//    }
//}
