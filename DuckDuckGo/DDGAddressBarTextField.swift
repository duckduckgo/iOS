//
//  DDGAddressBarTextField.swift
//  Browser
//
//  Created by Sean Reilly on 2017.01.03.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit


enum DDGAddressBarRightButtonMode: Int {
  case None = -1, Default = 0, Refresh = 1, Stop = 2
}


class DDGAddressBarTextField: UITextField, UITextFieldDelegate {
  
  @IBOutlet var placeholderTextLeft: NSLayoutConstraint?
  @IBOutlet var placeholderTextCenter: NSLayoutConstraint?
  @IBOutlet var placeholderIconView: UIImageView?
  
  var additionalLeftSideInset: CGFloat = 0
  var additionalRightSideInset: CGFloat = 0
  var clearButton: UIButton?
  var stopButton: UIButton?
  var reloadButton: UIButton?
  var placeholderView: UIView?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.setup()
  }
  
  
  func updatePlaceholder() {
    self.updatePlaceholder(animated:true)
  }
  
  
  override func updateConstraints() {
    super.updateConstraints()
    let fieldIsActive = self.isFirstResponder
    self.placeholderTextLeft?.isActive = fieldIsActive;
    self.placeholderTextCenter?.isActive = !fieldIsActive;
  }
  
  func updatePlaceholder(animated: Bool) {
    let text = self.text ?? ""
    let fieldIsActive = self.isFirstResponder
    let emptyText = text.characters.count > 0
    if !emptyText {
      // if the text is non-empty then hide the placeholder immediately
      self.placeholderView?.alpha = 0
    }
    
    let animator = { () -> Void in
      // position the placeholder
      self.placeholderTextLeft?.isActive = fieldIsActive
      self.placeholderTextCenter?.isActive = !fieldIsActive
      
      // fade the loupe icon in or out
      self.placeholderIconView?.alpha = fieldIsActive ? 0 : 1
      
      // if the text is empty, then let's fade in the placeholder
      if(emptyText) {
        self.placeholderView?.alpha = 1
      }
      
      self.placeholderView?.layoutIfNeeded()
    }
    
    if(animated) {
      UIView.animate(withDuration: 0.2, animations: animator)
    } else {
      animator();
    }
  }

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if (keyPath=="text") {
      self.updatePlaceholder(animated:true)
      self.textWasUpdated()
    }
  }


  func textWasUpdated() {
    if let newText = self.text, newText.characters.count>0 {
      self.clearButton?.isHidden = false;
    } else {
      self.clearButton?.isHidden = true;
    }
  }

  func setup() {
    let stopButton = UIButton.init(type: UIButtonType.custom)
    stopButton.setImage(UIImage.init(named: "stop.png"), for: .normal)
    stopButton.frame = CGRect.init(x: 0, y: 0, width: 27, height: 23)
    self.stopButton = stopButton
    
    
    let reloadButton = UIButton.init(type: UIButtonType.custom)
    reloadButton.setImage(UIImage.init(named: "refresh.png"), for:.normal)
    reloadButton.frame = CGRect.init(x:0, y:0, width:27, height:23)
    self.reloadButton = reloadButton
    
    let clearButton = UIButton.init(type: UIButtonType.custom)
    clearButton.setImage(UIImage.init(named:"clear.png"), for:.normal)
    clearButton.frame = CGRect.init(x:0, y:0, width:27, height:23)
    clearButton.addTarget(self, action: #selector(DDGAddressBarTextField.clear), for: .touchUpInside)
    self.clearButton = clearButton

    self.addTarget(self, action: #selector(textWasUpdated), for: .editingChanged)
    self.addObserver(self, forKeyPath: "text", options: .new, context: nil)

    self.addTarget(self, action: #selector(DDGAddressBarTextField.updatePlaceholder(animated:)), for: .editingDidBegin)
    self.addTarget(self, action: #selector(DDGAddressBarTextField.updatePlaceholder(animated:)), for: .editingDidEnd)
    self.addTarget(self, action: #selector(DDGAddressBarTextField.updatePlaceholder(animated:)), for: .editingChanged)
    
    self.backgroundColor = UIColor.duckSearchFieldBackground()
    self.textColor = UIColor.duckSearchFieldForeground()
    self.tintColor = UIColor.duckSearchFieldForeground()
    self.contentHorizontalAlignment = .center
    
    self.layer.cornerRadius = 4
  }


  func setRightButtonMode(newMode:DDGAddressBarRightButtonMode) {
    switch (newMode) {
    case .Default:
      self.rightView = self.clearButton;
      self.rightViewMode = .whileEditing
      break;
    case .Refresh:
      self.rightView = self.reloadButton
      self.rightViewMode = .always
      break;
    case .Stop:
      self.rightView = self.stopButton
      self.rightViewMode = .always
      break;
    case .None:
      self.rightView = self.reloadButton
      self.rightViewMode = .never
      break;
    }
  }

  func resetField() {
    self.clear()
    self.updatePlaceholder()
  }


  func clear() {
    self.text = ""
  }
  
  
  // placeholder position
  override func textRect(forBounds bounds: CGRect) -> CGRect {
    var rect = super.textRect(forBounds: bounds)
    if (self.additionalLeftSideInset != 0) {
      rect.origin.x = self.additionalLeftSideInset;
      rect.size.width -= self.additionalLeftSideInset;
    }
    rect.size.width -= self.additionalRightSideInset;
    return rect;
  }

  // text position
  override func editingRect(forBounds bounds: CGRect) -> CGRect {
    var rect = super.editingRect(forBounds: bounds)
    if(self.additionalLeftSideInset != 0) {
      rect.origin.x = self.additionalLeftSideInset;
      rect.size.width -= self.additionalLeftSideInset;
    }
    rect.size.width -= self.additionalRightSideInset;
    return rect;
  }
  
  deinit {
    self.removeObserver(self, forKeyPath: "text")
  }
  
  func safeUpdate(textToUpdate:String) {
    self.text = ""
    self.updatePlaceholder(animated:false)
    self.text = textToUpdate;
  }
}

