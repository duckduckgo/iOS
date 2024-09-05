//
//  AutofillHeaderViewFactory.swift
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

import Foundation
import UIKit
import SwiftUI
import Core

protocol AutofillHeaderViewDelegate: AnyObject {
    func handlePrimaryAction(for headerType: AutofillHeaderViewFactory.ViewType)
    func handleDismissAction(for headerType: AutofillHeaderViewFactory.ViewType)
}

protocol AutofillHeaderViewFactoryProtocol: AnyObject {
    var delegate: AutofillHeaderViewDelegate? { get set }
    
    func makeHeaderView(for type: AutofillHeaderViewFactory.ViewType) -> UIViewController
}

final class AutofillHeaderViewFactory: AutofillHeaderViewFactoryProtocol {
    
    weak var delegate: AutofillHeaderViewDelegate?
    
    enum ViewType {
        case syncPromo(SyncPromoManager.Touchpoint)
        case survey(AutofillSurveyManager.AutofillSurvey)
    }
    
    init(delegate: AutofillHeaderViewDelegate?) {
        self.delegate = delegate
    }
    
    func makeHeaderView(for type: ViewType) -> UIViewController {
        switch type {
        case .syncPromo(let touchpointType):
            return makeSyncPromoView(touchpointType: touchpointType)
        case .survey(let survey):
            return makeSurveyView(survey: survey)
        }
    }
    
    private func makeSyncPromoView(touchpointType: SyncPromoManager.Touchpoint) -> UIHostingController<SyncPromoView> {
        let headerView = SyncPromoView(viewModel: SyncPromoViewModel(
            touchpointType: touchpointType,
            primaryButtonAction: { [weak delegate] in
                delegate?.handlePrimaryAction(for: .syncPromo(touchpointType))
            },
            dismissButtonAction: { [weak delegate] in
                delegate?.handleDismissAction(for: .syncPromo(touchpointType))
            }
        ))
        
        Pixel.fire(.syncPromoDisplayed, withAdditionalParameters: ["source": touchpointType.rawValue])
        
        let hostingController = UIHostingController(rootView: headerView)
        hostingController.view.backgroundColor = .clear
        return hostingController
    }
    
    private func makeSurveyView(survey: AutofillSurveyManager.AutofillSurvey) -> UIHostingController<AutofillSurveyView> {
        let headerView = AutofillSurveyView(
            primaryButtonAction: { [weak delegate] in
                delegate?.handlePrimaryAction(for: .survey(survey))
            },
            dismissButtonAction: { [weak delegate] in
                delegate?.handleDismissAction(for: .survey(survey))
            }
        )
        
        Pixel.fire(pixel: .autofillManagementScreenVisitSurveyAvailable)
        
        let hostingController = UIHostingController(rootView: headerView)
        hostingController.view.backgroundColor = .clear
        return hostingController
    }
}
