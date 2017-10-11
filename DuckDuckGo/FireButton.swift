//
//  FireButton.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 11/10/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit

class FireButton: UIView, NibLoading {

    typealias OnCilckHandler = () -> Void

    var onClickHandler: OnCilckHandler!

    @IBAction func onClick() {
        onClickHandler()
    }

    static func loadFromNib(_ onClickHandler:@escaping OnCilckHandler) -> FireButton {
        let view = FireButton.load(nibName: "FireButton") as FireButton
        view.onClickHandler = onClickHandler
        return view
    }

}

extension UIToolbar {

    func addFireButton(_ onClickHandler:@escaping FireButton.OnCilckHandler) -> FireButton {
        let view = FireButton.loadFromNib(onClickHandler)
        view.center = CGPoint(x: bounds.midX, y: bounds.midY)
        addSubview(view)
        return view
    }

}
