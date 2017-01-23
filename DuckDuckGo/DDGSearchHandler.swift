//
//  DDGSearchHandler.swift
//  DuckDuckGo
//
//  Created by Sean Reilly on 2017.01.18.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

protocol DDGSearchHandler: NSObjectProtocol {
  func searchControllerLeftButtonPressed()
  
  func loadQueryOrURL(_ queryOrURLString: String)
  
  func prepareForUserInput()
  
  func beginSearchInput(with string: String)
  
  func searchControllerStopOrReloadButtonPressed()
  
  func searchControllerAddressBarWillOpen()
  
  func searchControllerAddressBarWillCancel()
  
  func searchControllerActionButtonPressed(_ sender: Any)
}
