//
//  LengthUnit.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 8/14/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import Foundation

enum LengthUnit : Int, Unit {

    case foot=1, mile=5280
    
    static var defaultUnit = foot
    
    static internal var names: [LengthUnit:Array<String>] = [
        foot: ["foot", "feet", "ft", "ft."],
        mile: ["mile", "miles", "mi", "mi."]
    ]
    
    var value: Int { return self.rawValue }
}
