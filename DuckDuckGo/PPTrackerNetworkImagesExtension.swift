//
//  PPTrackerNetworkImagesExtension.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 17/11/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation
import UIKit

extension PPTrackerNetwork {

    var image: UIImage {
        let imageName = "PP Pill \(name!.lowercased())"
        return UIImage(named: imageName) ?? #imageLiteral(resourceName: "PP Inline D")
    }

}
