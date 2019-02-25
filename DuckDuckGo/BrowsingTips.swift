//
//  BrowsingTips.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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
import Core

protocol BrowsingTipsDelegate: NSObjectProtocol {
    
    func showPrivacyGradeTip()
    
    func showFireButtonTip()
    
}

class BrowsingTips {
    
    enum Tips: Int {
        case privacyGrade
        case fireButton
    }
    
    private let appUrls = AppUrls()
    
    private weak var delegate: BrowsingTipsDelegate?
    private var storage: ContextualTipsStorage
    
    init?(delegate: BrowsingTipsDelegate,
          storage: ContextualTipsStorage = DefaultContextualTipsStorage(),
          variantManager: VariantManager = DefaultVariantManager()) {
        
        guard (variantManager.currentVariant?.features ?? []).contains(.onboardingContextual) else {
            return nil
        }
        
        self.delegate = delegate
        self.storage = storage
    }
    
    func onFinishedLoading(url: URL?, error: Bool) {
        guard !error else { return }
        guard let url = url else { return }
        guard !appUrls.isDuckDuckGo(url: url) else { return }
        guard let tip = Tips(rawValue: storage.nextBrowsingTip) else { return }
        
        switch tip {
            
        case .privacyGrade:
            delegate?.showPrivacyGradeTip()
            
        case .fireButton:
            delegate?.showFireButtonTip()
            
        }
        
        storage.nextBrowsingTip += 1
    }
    
}

