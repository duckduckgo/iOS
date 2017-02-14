//
// Created by Sean Reilly on 2017.01.27.
// Copyright (c) 2017 DuckDuckGo. All rights reserved.
//

import Foundation



extension NSRange {
  
  func range(for str: String) -> Range<String.Index>? {
    guard location != NSNotFound else { return nil }
    
    guard let fromUTFIndex = str.utf16.index(str.utf16.startIndex, offsetBy: location, limitedBy: str.utf16.endIndex) else { return nil }
    guard let toUTFIndex = str.utf16.index(fromUTFIndex, offsetBy: length, limitedBy: str.utf16.endIndex) else { return nil }
    guard let fromIndex = String.Index(fromUTFIndex, within: str) else { return nil }
    guard let toIndex = String.Index(toUTFIndex, within: str) else { return nil }
    
    return fromIndex ..< toIndex
  }
}