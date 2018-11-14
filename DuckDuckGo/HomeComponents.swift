//
//  HomeComponents.swift
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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

protocol HomeComponent {
    
    typealias Configure = (UITableViewCell) -> Void
    
    var name: String { get }
    var height: CGFloat { get }
    
    func configure(cell: UITableViewCell)
    
}

class LogoComponent: HomeComponent {
    
    struct Constants {
        static let logoHeightPortrait: CGFloat = 170
        static let logoHeightLandscape: CGFloat = 65
    }
    
    let name: String = "logo"
    
    var imageYOffset: CGFloat {
        return 0
    }
    
    var height: CGFloat {
        return UIDevice.current.orientation == .portrait ? Constants.logoHeightPortrait : Constants.logoHeightLandscape
    }
    
    func configure(cell: UITableViewCell) {
        guard let logoCell = cell as? HomeLogoTableViewCell else {
            fatalError("cell is not a HomeLogoTableViewCell")
        }
        
        let theme = ThemeManager.shared.currentTheme
        switch theme.currentImageSet {
        case .light:
            logoCell.logo.image = UIImage(named: "LogoDarkText")
        case .dark:
            logoCell.logo.image = UIImage(named: "LogoLightText")
        }
        
        logoCell.centerYConstraint.constant = imageYOffset
    }

}

class CenteredLogoComponent: LogoComponent {
    
    struct Constants {
        
        // this offset should match the offset in the launch screen
        static let logoOffsetPortrait: CGFloat = -35
        static let logoOffsetLandscape: CGFloat = 0
    }
    
    weak var parent: UIView!
    
    override var height: CGFloat {
        return parent.bounds.height
    }
    
    override var imageYOffset: CGFloat {
        return UIDevice.current.orientation == .portrait ? Constants.logoOffsetPortrait : Constants.logoOffsetLandscape
    }
    
    init(parent: UIView) {
        self.parent = parent
    }
    
}

class SpaceComponent: HomeComponent {
    
    let name: String = "space"
    
    var height: CGFloat
    
    init(height: CGFloat) {
        self.height = height
    }
    
    func configure(cell: UITableViewCell) {
        // no-op
    }
    
}

class TopSpaceComponent: HomeComponent {
    
    weak var parent: UIView!
    
    let name: String = "space"
    
    var height: CGFloat {
        let logoHeight = UIDevice.current.orientation == .portrait ?
            LogoComponent.Constants.logoHeightPortrait : LogoComponent.Constants.logoHeightLandscape
        let searchHeight = SearchComponent.Constants.height
        let halfScreenHeight = parent.bounds.height / 2
        let halfSearchHeight = searchHeight / 2
        let targetHeight = halfScreenHeight - logoHeight - halfSearchHeight
        return max(0, targetHeight)
    }
    
    init(parent: UIView) {
        self.parent = parent
    }
    
    func configure(cell: UITableViewCell) {
        // no-op
    }
    
}

class SearchComponent: HomeComponent {

    struct Constants {
        static let height: CGFloat = 60
    }
    
    let height: CGFloat = Constants.height
    
    let name: String = "search"

    func configure(cell: UITableViewCell) {
        // no-op
        cell.backgroundColor = UIColor.blue
    }
    
}

class NewsFeedComponent: HomeComponent {
    
    let name: String = "space"
    
    let height: CGFloat
    
    init(items: Int) {
        height = CGFloat(items * 200)
    }
    
    func configure(cell: UITableViewCell) {
        // no-op
        cell.backgroundColor = UIColor.red
    }
    
}

class ShortcutsComponent: HomeComponent {

    let name: String = "space"
    
    let height: CGFloat
    
    init(rows: Int) {
        height = CGFloat(rows * 100)
    }

    func configure(cell: UITableViewCell) {
        // no-op
        cell.backgroundColor = UIColor.green
    }

}
