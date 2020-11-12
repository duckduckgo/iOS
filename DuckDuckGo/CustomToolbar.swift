//
//  CustomToolbar.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

class CustomToolbar: UIToolbar {

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

        let item = items?.first(where: {
            guard let customView = $0.customView else { return false }
            let location = convert(point, to: customView)
            print(location, "vs", $0.customView)
            return location.x > 0 && location.x <= 45 && location.y > 0 && location.y <= 45
        })
        print("---")
        return item?.customView ?? super.hitTest(point, with: event)
    }

}
