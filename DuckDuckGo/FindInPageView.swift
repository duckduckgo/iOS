//
//  FindInPageView.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 15/02/2019.
//  Copyright © 2019 DuckDuckGo. All rights reserved.
//

import UIKit

class FindInPageView: UIView {
    
    func update(with findInPage: FindInPage?) {
        guard let findInPage = findInPage else {
            isHidden = true
            return
        }
        
    }
}
