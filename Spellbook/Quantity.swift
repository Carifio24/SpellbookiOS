//
//  Quantity.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 8/14/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import Foundation

class Quantity<ValueType: QuantityType, UnitType: Unit> where ValueType:Comparable {
    
    // Get the associated types
    let quantityType = ValueType.self
    let unitType = UnitType.self
    
    let type: ValueType
    let value: Int
    let unit: UnitType
    let str: String
    
    // Constructors
    required init(type: ValueType, value: Int, unit: UnitType, str: String) {
        self.type = type
        self.value = value
        self.unit = unit
        self.str = str
    }
    
    convenience init(type: ValueType, value: Int, unit: UnitType) {
        self.init(type: type, value: value, unit: unit, str: "")
    }
    
    convenience init(type: ValueType, value: Int) {
        self.init(type: type, value: value, unit: UnitType.defaultUnit)
    }
    
    convenience init(type: ValueType) {
        self.init(type: type, value: ValueType.defaultValue)
    }
    
    convenience init() {
        self.init(type: ValueType.spanningType)
    }
    
    // Methods
    func baseValue() -> Int {
        return value * unit.value
    }
    
    func isTypeSpanning() -> Bool {
        return type.isSpanningType()
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
