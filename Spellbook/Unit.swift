//
//  Unit.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 8/14/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import Foundation

protocol Unit: Hashable & CaseIterable {
    
    static var names: [Self:Array<String>] { get }
    
    var singularName: String { get }
    var pluralName: String { get }
    var abbreviation: String { get }
    var value: Int { get }
    
    static func fromString(_ s: String) throws -> Self
    static var defaultUnit: Self { get }
}

extension Unit {
    
    var singularName: String {
        return Self.names[self]![0]
    }
    
    var pluralName: String {
        return Self.names[self]![1]
    }
    
    var abbreviation: String {
        return Self.names[self]![2]
    }
    
    // Create a Unit instance from a String
    static func fromString(_ s: String) throws -> Self {
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
