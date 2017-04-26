//
//  DissolveAnimatedTransitioning.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 25/04/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Core

class DissolveAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromView = transitionContext.view(forKey: .from)!
        fromView.backgroundColor = UIColor.clear
        fromView.alpha = 1
        
        UIView.animate(withDuration: 0.5, animations: {
            fromView.alpha = 0.0
        }, completion: { (value: Bool) in
            transitionContext.completeTransition(true)
        })
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
}
