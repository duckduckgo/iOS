//
//  SwiftUICollectionViewCell.swift
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

import UIKit
import SwiftUI

/// Subclass for embedding a SwiftUI View inside of UICollectionViewCell
class SwiftUICollectionViewCell<Content>: UICollectionViewCell where Content: View {
    
    private(set) var host: UIHostingController<Content>?
    
    func embed(in parent: UIViewController, withView content: Content) {
        if let host = self.host {
            host.rootView = content
            host.view.layoutIfNeeded()
        } else {
            let host = UIHostingController(rootView: content)
            parent.addChild(host)
            host.didMove(toParent: parent)
            contentView.addSubview(host.view)
            self.host = host
        }
    }
    
    deinit {
        host?.willMove(toParent: nil)
        host?.view.removeFromSuperview()
        host?.removeFromParent()
        host = nil
    }

}
