//
//  HashableType.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 2/9/20.
//  Copyright © 2020 Jonathan Carifio. All rights reserved.
//

import Foundation

// Hashable wrapper for a metatype
struct HashableType<T> : Hashable {
    
    static func == (lhs: HashableType, rhs: HashableType) -> Bool {
        return lhs.base == rhs.base
    }
    
    let base: T.Type
    
    init(_ base: T.Type) {
        self.base = base
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(base))
    }
    
}
