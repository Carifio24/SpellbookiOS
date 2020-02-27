
//
//  SortField.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 8/22/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import Foundation

enum SortField: Int, NameDisplayable {
    case Name=0, School, Level, Range, Duration
    
    private static let spellComparators: [SortField:IntComparatorFunc<Spell>] = [
        Name : propertyTriComp({ (_ s: Spell) -> String in
            return s.name }),
        School : propertyTriComp({ (_ s: Spell) -> School in
            return s.school }),
        Level : propertyTriComp({ (_ s:Spell) -> Int in
            return s.level }),
        Range : propertyTriComp({ (_ s:Spell) -> Range in
            return s.range }),
        Duration : propertyTriComp({ (_ s:Spell) -> Duration in
            return s.duration })
    ]
    
    internal static var displayNameMap = EnumMap<SortField,String> { e in
        switch(e) {
        case .Name:
            return "Name"
        case .School:
            return "School"
        case .Level:
            return "Level"
        case .Range:
            return "Range"
        case .Duration:
            return "Duration"
        }
        
    }

    
    func comparator() -> IntComparatorFunc<Spell> {
        return SortField.spellComparators[self]!
    }
    
    static let count = SortField.allCases.count
}
