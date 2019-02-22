//
//  BookmarksButton.swift
//  DuckDuckGo
//
//  Created by BG on 2/19/19.
//  Copyright © 2019 DuckDuckGo. All rights reserved.
//

import UIKit

protocol GestureToolBarButtonDelegate: NSObjectProtocol {
    
    func singleTapHandler()
    func longPressHandler()
    
}

class GestureToolBarButton: UIView {
    
    struct Constants {
        
        static let minLongPressDuration = 0.8
        
    }
    
    weak var delegate: GestureToolBarButtonDelegate?
    
    // UIToolBarButton size would be 29X44 and it's imageview size would be 24X24
    let iconImageView = UIImageView(frame: CGRect(x: 2.5, y: 10, width: 24, height: 24))
    
    var image: UIImage? {
        didSet {
            iconImageView.image = image
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(iconImageView)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandler))
        longPressRecognizer.minimumPressDuration = Constants.minLongPressDuration
        longPressRecognizer.allowableMovement = 20
        self.addGestureRecognizer(longPressRecognizer)

    }
    
    @objc func longPressHandler(_ sender: UIGestureRecognizer) {
        
        if sender.state == .began {
            delegate?.longPressHandler()
        }
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 29, height: 44))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        Logger.log(text: "touchesBegan \(Date.init())")
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        guard let touch = touches.first else { return }
        guard point(inside: touch.location(in: self), with: event) else { return }
        delegate?.singleTapHandler()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
}

extension GestureToolBarButton: Themable {
    
    func decorate(with theme: Theme) {
        backgroundColor = theme.barBackgroundColor
        tintColor = theme.barTintColor
    }
}
