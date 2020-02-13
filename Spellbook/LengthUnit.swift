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
    
    func singularName() -> String {
        return LengthUnit.names[self]![0]
    }
    
    func pluralName() -> String {
        return LengthUnit.names[self]![1]
    }
    
    func abbreviation() -> String {
        return LengthUnit.names[self]![2]
    }
    
    func value() -> Int {
        return self.rawValue
    }
    
    // Create a LengthUnit instance from a String
    static func fromString(_ s: String) throws -> LengthUnit {
        let t = s.lowercased()
        for (unit, arr) in names {
            for name in arr {
                if (t == name) {
                    return unit
                }
            }
        }
        print(s)
        throw SpellbookError.UnitStringError
    }
}
