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

    let coordinator: TextZoomCoordinating
    let model: TextZoomEditorModel

    @MainActor init(domain: String, coordinator: TextZoomCoordinating, defaultTextZoom: TextZoomLevel) {
        self.coordinator = coordinator
        self.model = TextZoomEditorModel(domain: domain, coordinator: coordinator, defaultTextZoom: defaultTextZoom)
        super.init(rootView: TextZoomEditorView(model: model))
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
