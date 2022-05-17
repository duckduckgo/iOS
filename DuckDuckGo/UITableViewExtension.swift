//
//  UITableViewExtension.swift
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

extension UITableView {
    func dequeueCell<CellType: UITableViewCell>(ofType: CellType.Type, for indexPath: IndexPath) -> CellType {
        
        let reuseIdentifier = "\(CellType.self)"
        let someCell = self.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        guard let cell = someCell as? CellType else {
            fatalError("Could not dequeue cell of type \(CellType.self)")
        }
        return cell
    }
    
    func registerCell<CellType: UITableViewCell>(ofType: CellType.Type) {
        let reuseIdentifier = "\(CellType.self)"
        self.register(CellType.self, forCellReuseIdentifier: reuseIdentifier)
    }
}
