//
//  Controllers.swift
//  
//
//  Created by Jonathan Carifio on 11/10/19.
//

import Foundation

class Controllers {
    
    // The SWRevealController
    static let revealController: SWRevealViewController = UIApplication.shared.keyWindow?.rootViewController as! SWRevealViewController
    
    // The navigation controller for the main controller
    static let mainNavController: UINavigationController = revealController.frontViewController as! UINavigationController
        
    // The main controller
    static let mainController: ViewController = mainNavController.topViewController as! ViewController
    
    // The side menu controller
    static let sideMenuController = revealController.rearViewController as! SideMenuController
    
}
