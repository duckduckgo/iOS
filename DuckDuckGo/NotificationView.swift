//
//  NotificationViewDelegate.swift
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

class NotificationView: UIView {
    
    typealias DismissHandler = ((_ tapped: Bool) -> Void)
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    var dismissHandler: DismissHandler?

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
        dismissHandler?(true)
    }
    
    @IBAction func dismiss() {
        dismissHandler?(false)
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
        print("***", #function)
        update()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        print("***", #function)
        update()
    }
    
    deinit {
        print("***", #function)
        dismissHandler = nil
    }
    
    static func loadFromNib(dismissHandler: @escaping DismissHandler) -> NotificationView {
        let index = UIDevice.current.userInterfaceIdiom == .phone ? 0 : 1
        let notificationView = Bundle.main.loadNibNamed("NotificationView", owner: self, options: nil)![index] as! NotificationView
        notificationView.dismissHandler = dismissHandler
        return notificationView
    }
    
}
