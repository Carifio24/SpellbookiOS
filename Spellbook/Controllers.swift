//
//  Controllers.swift
//  
//
//  Created by Jonathan Carifio on 11/10/19.
//

import Foundation

class Controllers {
    
    // The SWRevealController
    static let revealController: SWRevealViewController = (UIApplication.shared.keyWindow?.rootViewController as! SWRevealViewController)
    
    // The main controller
    static let mainController: ViewController = revealController.frontViewController as! ViewController
    
    // The side menu controller
    static let sideMenuController = revealController.rearViewController as! SideMenuController
    
}
