//
//  File.swift
//  Spellbook
//
//  Created by Mac Pro on 3/29/20.
//  Copyright © 2020 Jonathan Carifio. All rights reserved.
//

import Foundation

// This is a weaker form of NameConstructible that has no Self constraints
// In particular, we can use this as a constraint outside of a generic context
protocol NameDisplayable {
    var displayName: String { get }
    //func getDisplayName() -> String
}

protocol NameConstructible: NameDisplayable, CaseIterable, Hashable {
    
    static func fromName(_ s: String) -> Self
    static var displayNameMap: EnumMap<Self,String> { get }
    static func allNames() -> [String]
    
}

// No need to repeat these in every implementing class
// All an implementing class needs is a displayNameMap that includes all of the cases
// Changing displayNameMap to an EnumMap would be a nice way to enforce that
extension NameConstructible {
    
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
