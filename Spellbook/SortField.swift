
//
//  SortField.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 8/22/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import Foundation

enum SortField: Int {
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
    
    private static let nameMap: [SortField:String] = [
        Name : "Name",
        School : "School",
        Level : "Level",
        Range : "Range",
        Duration : "Duration"
    ]
    
    func comparator() -> IntComparatorFunc<Spell> {
        return SortField.spellComparators[self]!
    }
    
    static func fromName(_ s: String) -> SortField? {
        return getOneKey(dict: SortField.nameMap, value: s)
    }
    
    static let count = SortField.allCases.count
}

extension SortField : CaseIterable {}

extension SortField: NameDisplayable {
    
    var displayName: String {
        return SortField.nameMap[self]!
    }
    
}
