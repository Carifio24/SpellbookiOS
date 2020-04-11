//
//  Images.swift
//  Spellbook
//
//  Created by Mac Pro on 4/6/20.
//  Copyright © 2020 Jonathan Carifio. All rights reserved.
//

import Foundation

class Images {
    
    // Up and down arrows
    static let upArrow = UIImage(named: "up_arrow.png")?.withRenderingMode(.alwaysOriginal)
    static let downArrow = UIImage(named: "down_arrow.png")?.withRenderingMode(.alwaysOriginal)
    
    // Up and down arrows, scaled
    static let scaledArrowHeight = 30
    static let upArrowScaled = upArrow?.resized(width: Images.scaledArrowHeight, height: Images.scaledArrowHeight)
    static let downArrowScaled = downArrow?.resized(width: Images.scaledArrowHeight, height: Images.scaledArrowHeight)
    
}
