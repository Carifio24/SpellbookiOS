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
    
    static private let names: [LengthUnit:Array<String>] = [
        foot: ["foot", "feet", "ft", "ft."],
        mile: ["mile", "miles", "mi", "mi."]
    ]
    
    func name() -> String {
        return LengthUnit.names[self]![0]
    }
    
    func pluralName() -> String {
        return LengthUnit.names[self]![1]
    }
    
    func abbreviation() -> String {
        return LengthUnit.names[self]![2]
    }
    
    // Create a LengthUnit instance from a String
    static func fromString(_ s: String) -> LengthUnit {
        s = s.lowercased()
        for (unit, arr) in names {
            for name in arr {
                if (s == name) {
                    return unit
                }
            }
        }
        throw Error("Not a valid LengthUnit string")
    }
}
