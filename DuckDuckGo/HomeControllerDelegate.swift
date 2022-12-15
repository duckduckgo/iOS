//
//  HomeControllerDelegate.swift
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

import UIKit
import Core
import Bookmarks

protocol HomeControllerDelegate: AnyObject {

    func home(_ home: HomeViewController, didRequestUrl url: URL)
    
    func home(_ home: HomeViewController, didRequestEdit favorite: BookmarkEntity)

    func home(_ home: HomeViewController, didRequestQuery query: String)
    
    func home(_ home: HomeViewController, didRequestContentOverflow shouldOverflow: Bool) -> CGFloat

    func homeDidDeactivateOmniBar(home: HomeViewController)

    func showSettings(_ home: HomeViewController)
    
    func home(_ home: HomeViewController, didRequestHideLogo hidden: Bool)
        
    func homeDidRequestLogoContainer(_ home: HomeViewController) -> UIView
    
    func home(_ home: HomeViewController, searchTransitionUpdated percent: CGFloat)
    
}
