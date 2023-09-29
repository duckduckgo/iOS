//
//  UIView+Constraints.swift
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

import UIKit

extension UIView {

    func constrainView(_ other: Any,
                       by attribute: NSLayoutConstraint.Attribute,
                       to otherAttribute: NSLayoutConstraint.Attribute? = nil,
                       relatedBy relation: NSLayoutConstraint.Relation = .equal,
                       multiplier: Double = 1.0,
                       constant: Double = 0.0) -> NSLayoutConstraint {

        return NSLayoutConstraint(item: self,
                                  attribute: attribute,
                                  relatedBy: relation,
                                  toItem: other,
                                  attribute: otherAttribute ?? attribute,
                                  multiplier: multiplier,
                                  constant: constant)

    }

    func constrainAttribute(_ attribute: NSLayoutConstraint.Attribute,
                            to constant: Double,
                            relatedBy relation: NSLayoutConstraint.Relation = .equal,
                            multiplier: Double = 1.0) -> NSLayoutConstraint {

        return NSLayoutConstraint(item: self,
                                  attribute: attribute,
                                  relatedBy: relation,
                                  toItem: nil,
                                  attribute: .notAnAttribute,
                                  multiplier: 1.0,
                                  constant: constant)

    }

}
