//
//  NotificationView.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 30/04/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import UIKit

protocol NotificationViewDelegate: class {
    
    func dismised(_ view: NotificationView)
    func tapped(_ view: NotificationView)
    
}

class NotificationView: UIView {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    weak var delegate: NotificationViewDelegate?

    var tapGesture: UITapGestureRecognizer?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    func sharedInit() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(NotificationView.tap))
        addGestureRecognizer(tapGesture)
        self.tapGesture = tapGesture
    }

    @objc func tap() {
        delegate?.tapped(self)
    }
    
    @IBAction func dismiss() {
        delegate?.dismised(self)
    }
    
    func setMessage(text: String) {
        messageLabel.text = text
        update()
    }
    
    func setTitle(text: String) {
        titleLabel.text = text
        update()
    }
    
    func setIcon(image: UIImage) {
        icon.image = image
        update()
    }
 
    func update() {
        guard let superview = superview else { return }
        let height = titleLabel.frame.height + messageLabel.frame.height + 24

        frame.size.width = superview.frame.width
        frame.size.height = height
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        update()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        update()
    }
    
    func hide() {
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 0
        }, completion: { completed in
            self.removeFromSuperview()
        })
    }
    
    static func loadFromNib() -> NotificationView {
        let index = UIDevice.current.userInterfaceIdiom == .phone ? 0 : 1
        return Bundle.main.loadNibNamed("NotificationView", owner: self, options: nil)![index] as! NotificationView
    }
    
}
