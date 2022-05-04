//
//  ImageTitleSubtitleListItemViewModelProtocol.swift
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

import Foundation
import UIKit

protocol ImageTitleSubtitleListItemViewModelProtocol: ObservableObject {
    typealias LoadImageClosure = ((@escaping (UIImage) -> Void) -> Void)

    var title: String { get }
    var subtitle: String { get }
    #warning("does this needs to be a property here? maybe only image is good enough")
    var loadImage: LoadImageClosure { get set }
    var image: UIImage { get }
}
