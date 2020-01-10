//
//  FromRightDismissAnimator.swift
//  
//
//  Created by Jonathan Carifio on 1/8/20.
//

import Foundation

import Foundation

class FromRightDismissAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.45
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let toViewController = transitionContext.viewController(forKey: .to)
            else {
                return
        }
        guard let fromViewController = transitionContext.viewController(forKey: .from)
            else {
                return
        }
        
        let fromView = fromViewController.view!
        let animationDuration = transitionDuration(using: transitionContext)
        let containerView = transitionContext.containerView
        
        containerView.addSubview(fromView)
        containerView.insertSubview(toViewController.view, belowSubview: fromView)
        fromView.frame.origin = .zero
        
        UIView.animate(withDuration: animationDuration,
                       animations:  { fromView.frame.origin = CGPoint(x: fromView.frame.width, y: 0) },
                       completion: {
                        finished in
                        fromView.removeFromSuperview()
                        transitionContext.completeTransition(finished)
        }
        )
        
    }
    
}
