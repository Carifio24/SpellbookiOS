//
//  StatusFilterField.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 8/22/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import Foundation

enum StatusFilterField : Int {
    
    case All=0, Favorites, Prepared, Known
    
    static let nameMap: [StatusFilterField:String] = [
        All : "All spells",
        Favorites : "Favorites",
        Prepared : "Prepared",
        Known : "Known"
    ]
    
    func name() -> String {
        return StatusFilterField.nameMap[self]!
    }
    
    static func fromName(_ s: String) -> StatusFilterField? {
        return getOneKey(dict: nameMap, value: s)
    }
    
}

extension StatusFilterField : CaseIterable {}
