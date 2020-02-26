//
//  Unit.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 8/14/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import Foundation

protocol Unit: Hashable {
    
    static var names: [Self:Array<String>] { get }
    
    func singularName() -> String
    func pluralName() -> String
    func abbreviation() -> String
    func value() -> Int
    
    static func fromString(_ s: String) throws -> Self
}

extension Unit {
    
    func singularName() -> String {
        return Self.names[self]![0]
    }
    
    func pluralName() -> String {
        return Self.names[self]![1]
    }
    
    func abbreviation() -> String {
        return Self.names[self]![2]
    }
    
}
