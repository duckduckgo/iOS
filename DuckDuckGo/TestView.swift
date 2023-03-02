//
//  TestView.swift
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
import SyncUI

struct TestView: View {

    var body: some View {
        Text("Test")
    }

}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        RecoveryKeyPDFView(code: SyncSettingsViewController.fakeCode)
            .frame(width: 8.5 * 72, height: 11 * 72)
    }
}
