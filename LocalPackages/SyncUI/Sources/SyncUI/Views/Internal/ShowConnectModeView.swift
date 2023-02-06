//
//  ShowConnectModeView.swift
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

/// We have to defer starting connect mode untl we're visible because otherwise SwiftUI might start it prematurely as a result of the NavigationLink.
///  In iOS 16 we use a value binding on the NavigationLink, but this better anyway as we can show progress.
struct ShowConnectModeView: View {

    @ObservedObject var model: SyncCodeCollectionViewModel
    @State var qrCodeModel = ShowQRCodeViewModel()

    var body: some View {
        SyncQRCodeView(model: qrCodeModel)
            .onAppear {
                self.qrCodeModel = model.startConnectMode()
            }
    }

}
