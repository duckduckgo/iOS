//
//  DDGAutocompletionCell.swift
//  DuckDuckGo
//
//  Created by Sean Reilly on 2017.01.18.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit

protocol DDGAutocompletionCellDelegate {
  func plusButtonWasPushed(menuCell:DDGAutocompletionCell)
}


class DDGAutocompletionCell : UITableViewCell {
  var isLastItem = false
  var autocompleteMode = true
  var plusButton: UIButton?
  var delegate: DDGAutocompletionCellDelegate?
  var suggestionInfo: Dictionary<String, Any>?
  
  var icon: UIImage? {
    get {
      return self.imageView?.image
    }
    set(icon) {
      self.imageView?.image = icon?.withRenderingMode(.alwaysTemplate)
      self.imageView?.setNeedsDisplay()
    }
  }
  
  init(reuseIdentifier: String) {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    
    self.tintColor = UIColor.duckRed()
    self.imageView?.contentMode = .left
    self.isLastItem = false
    
    var plusRect = self.frame
    plusRect.origin.x = plusRect.size.width - 44;
    plusRect.size.width = 44;
    let plusButton = UIButton(type: .custom)
    plusButton.setImage(UIImage(named: "Plus"), for: .normal)
    plusButton.frame = plusRect;
    plusButton.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin]
    self.addSubview(plusButton)
    self.plusButton = plusButton
    
    self.selectedBackgroundView?.backgroundColor = UIColor.duckTableSeparator()
    
    self.textLabel?.font = UIFont.duckFont(ofSize: 17)
    self.detailTextLabel?.font = UIFont.duckFont(ofSize: 15)
    
    self.textLabel?.textColor = UIColor.duckListItemTextForeground()
    self.detailTextLabel?.textColor = UIColor.duckListItemDetailForeground()
    
    self.imageView?.contentMode = .scaleAspectFill
    self.imageView?.autoresizingMask = UIViewAutoresizing(rawValue: 0)
    
    plusButton.addTarget(self, action: #selector(plusButtonWasPushed(button:)), for: .touchUpInside)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    let frame = self.frame
    if var imgRect = self.imageView?.frame {
      imgRect.origin.x = 15
      self.imageView?.frame = imgRect;
    }
    
    if var tmpFrame = self.textLabel?.frame {
      tmpFrame.origin.x = 49
      tmpFrame.size.width = frame.size.width - tmpFrame.origin.x - (self.plusButton?.frame.size.width ?? 0)
      self.textLabel?.frame = tmpFrame
    }
    
    if var tmpFrame = self.detailTextLabel?.frame {
      tmpFrame.origin.x = 49;
      tmpFrame.size.width = frame.size.width - tmpFrame.origin.x - (self.plusButton?.frame.size.width ?? 0);
      self.detailTextLabel?.frame = tmpFrame;
    }
  }
  
  func plusButtonWasPushed(button: UIButton) {
    if let delegate = self.delegate {
      delegate.plusButtonWasPushed(menuCell: self)
    }
  }
  
  func setSuggestionInfo(suggestionInfo: Dictionary<String, Any>) {
    self.suggestionInfo = suggestionInfo
    self.textLabel?.text = suggestionInfo["phrase"] as? String ?? ""
    self.detailTextLabel?.text = suggestionInfo["snippet"] as? String ?? ""
    self.imageView?.image = nil // the image should be set in the view controller, which can maintain a shared image cache
    if suggestionInfo["calls"] != nil  { // , calls.count > 0
      self.accessoryType = .detailDisclosureButton
    } else {
      self.accessoryType = .none
    }
  }

}
