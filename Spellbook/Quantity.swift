//
//  Quantity.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 8/14/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import Foundation

class Quantity<QuantityType, UnitType: Unit> where QuantityType:Comparable {
    
    let type: QuantityType
    let value: Int
    let unit: UnitType
    let str: String
    
    // Constructors
    init(type: QuantityType, value: Int, unit: UnitType, str: String) {
        self.type = type
        self.value = value
        self.unit = unit
        self.str = str
    }
    
    convenience init(type: QuantityType, value: Int, unit: UnitType) {
        self.init(type: type, value: value, unit: unit, str: "")
    }
    
    // Methods
    func baseValue() -> Int {
        return value * unit.value()
    }
    
}

// Equatability
extension Quantity: Equatable {
    static func == (lhs: Quantity, rhs: Quantity) -> Bool {
        return (lhs.type == rhs.type) && (lhs.baseValue() == rhs.baseValue())
    }
}

// Comparability
extension Quantity: Comparable {
    static func <  (lhs: Quantity, rhs: Quantity) -> Bool {
        if (lhs.type == rhs.type) {
            return lhs.baseValue() < rhs.baseValue()
        }
        return lhs.type < rhs.type
    }
}
