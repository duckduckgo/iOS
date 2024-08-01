//
//  WhatsNewHostingController.swift
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

enum FeatureSelected {
    case privacyPro
}

final class WhatsNewViewModel {
    var variant: WhatsNewVariant = .a
    var featureSelectedAction: ((FeatureSelected) -> Void)?
    var closeAction: (() -> Void)?
}

final class WhatsNewHostingController: UIHostingController<WhatsNewContainerView> {

    private var viewModel = WhatsNewViewModel()
    private let whatsNewExperiment = DefaultWhatsNewExperiment()
    private var featureSelectedAction: ((FeatureSelected) -> Void)

    init(featureSelectedAction: @escaping (FeatureSelected) -> Void) {

        self.featureSelectedAction = featureSelectedAction

        let containerView = WhatsNewContainerView(viewModel: viewModel)

        super.init(rootView: containerView)
        
        self.configureViewModel()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension WhatsNewHostingController {
    func configureViewModel() {

        // TODO: Here could intercept calls to call relevant methods on WhatsNewExperiment to fire pixels etc.

        viewModel.featureSelectedAction = self.featureSelectedAction

        viewModel.closeAction = { [weak self] in
            guard let self else { return }
            self.dismiss(animated: true)
        }
    }
}
