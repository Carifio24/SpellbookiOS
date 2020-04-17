//
//  FromRightPushAnimator.swift
//  
//
//  Created by Jonathan Carifio on 1/8/20.
//

import Foundation

class FromRightPushAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.45
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to)
        else {
            return
        }
        
        let animationDuration = transitionDuration(using: transitionContext)
        let containerView = transitionContext.containerView
        
        toViewController.view.transform = CGAffineTransform(translationX: containerView.bounds.width, y: 0)
        toViewController.view.layer.shadowColor = UIColor.black.cgColor
        toViewController.view.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        toViewController.view.layer.shadowOpacity = 0.3
        toViewController.view.layer.cornerRadius = 4.0
        toViewController.view.clipsToBounds = true
        
        containerView.addSubview(toViewController.view)
        
        //print("About to animate...")
        UIView.animate(withDuration: animationDuration,
                animations:  { toViewController.view.transform = CGAffineTransform.identity },
                completion: {
                    finished in transitionContext.completeTransition(finished)
                }
        )
        
    }
    
}
