//
//  Transitions.swift
//  
//
//  Created by Jonathan Carifio on 1/7/20.
//

import Foundation

class Transitions {

    static let fromRightTransition: CATransition = {
       let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        return transition
    }()
    
    static let fromLeftTransition: CATransition = {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        return transition
    }()

}
