//
//  NameDisplayable.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 2/9/20.
//  Copyright © 2020 Jonathan Carifio. All rights reserved.
//

import Foundation

protocol NameDisplayable : CaseIterable, Hashable {
    
    static var displayNameMap: EnumMap<Self,String> { get }
    
    static func fromName(_ s: String) -> Self
    
    static func allNames() -> [String]
    
    var displayName: String { get }
    
}

// No need to repeat these in every implementing class
// All an implementing class needs is a displayNameMap that includes all of the cases
// Changing displayNameMap to an EnumMap would be a nice way to enforce that
extension NameDisplayable {
    
    static func fromName(_ s: String) -> Self {
        return getOneKey(enumMap: Self.displayNameMap, value: s)!
    }
    
    var displayName: String {
        return Self.displayNameMap[self]
    }
    
    static func allNames() -> [String] {
        var names: [String] = []
        for item in Self.allCases {
            names.append(item.displayName)
        }
        return names
    }
    
}
