//
//  OmniBarDelegate.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

protocol OmniBarDelegate: class {

    func onOmniQueryUpdated(_ query: String)
    
    func onOmniQuerySubmitted(_ query: String)
    
    func onDismissed()
    
    func onSiteRatingPressed()
    
    func onMenuPressed()
    
    func onBookmarksPressed()
    
    func onSettingsPressed()
    
    func onCancelPressed()
    
    func onEnterPressed()

    func onRefreshPressed()
    
    func onBackPressed()
    
    func onForwardPressed()
    
    func onSharePressed()
    
    func onTextFieldWillBeginEditing(_ omniBar: OmniBar)
    
    func onTextFieldDidBeginEditing(_ omniBar: OmniBar)

}

extension OmniBarDelegate {
    
    func onOmniQueryUpdated(_ query: String) {
        
    }
    
    func onOmniQuerySubmitted(_ query: String) {
        
    }
    
    func onDismissed() {
        
    }
    
    func onSiteRatingPressed() {
        
    }
    
    func onMenuPressed() {
        
    }
    
    func onBookmarksPressed() {
        
    }
    
    func onSettingsPressed() {
        
    }
    
    func onCancelPressed() {
        
    }
    
    func onTextFieldWillBeginEditing(_ omniBar: OmniBar) {
        
    }

    func onTextFieldDidBeginEditing(_ omniBar: OmniBar) {
        
    }
    
    func onRefreshPressed() {
    
    }

    func onSharePressed() {
    }
    
    func onBackPressed() {
    }
    
    func onForwardPressed() {
    }
    
}
