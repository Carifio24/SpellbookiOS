//
//  Toast.swift
//  Spellbook
//
//  Created by Mac Pro on 2/26/23.
//  Copyright © 2023 Jonathan Carifio. All rights reserved.
//

import Foundation
import Toast

class Toast {
    
    static func makeToast(_ message: String, duration: TimeInterval = Constants.toastDuration, controller: UIViewController) {
        controller.view.makeToast(message, duration: duration)
    }
    
    // By default, we make our Toast messages through the main ViewController of the app
    // which is the SWRevealController
    // If we ever change this, we only need to change it here
    static func makeToast(_ message: String, duration: TimeInterval = Constants.toastDuration) {
        makeToast(message, duration: duration, controller: Controllers.revealController)
    }

}
