//
//  HomeScreenTips.swift
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

protocol HomeScreenTipsDelegate: NSObjectProtocol {
    
    func showPrivateSearchTip()
    
    func showCustomizeTip()
    
}

class HomeScreenTips {
    
    enum Tips: Int {
        case privateSearch
        case showCusomize
    }
    
    private weak var delegate: HomeScreenTipsDelegate?
    private var storage: ContextualTipsStorage

    init?(delegate: HomeScreenTipsDelegate,
          storage: ContextualTipsStorage = DefaultContextualTipsStorage(),
          variantManager: VariantManager = DefaultVariantManager()) {
        
        guard (variantManager.currentVariant?.features ?? []).contains(.onboardingContextual) else {
            return nil
        }
        
        self.delegate = delegate
        self.storage = storage
    }
    
    func trigger() {
        guard let tip = Tips(rawValue: storage.nextHomeScreenTip) else { return }
        
        switch tip {
            
        case .privateSearch:
            delegate?.showPrivateSearchTip()
            
        case .showCusomize:
            delegate?.showCustomizeTip()
            
        }
        
        storage.nextHomeScreenTip += 1
    }
    
}
