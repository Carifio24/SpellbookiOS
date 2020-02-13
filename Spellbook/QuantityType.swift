//
//  QuantityType.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 2/12/20.
//  Copyright © 2020 Jonathan Carifio. All rights reserved.
//

import Foundation

protocol QuantityType: NameDisplayable {
    
    // Is the quantity type the spanning type
    func isSpanningType() -> Bool
    
    // Static method to get the spanning type
    static func spanningType() -> Self
    
}

extension QuantityType {
    static func spanningType() -> Self {
        for qt in Self.allCases {
            if qt.isSpanningType() { return qt }
        }
        return Self.allCases.first!
    }
}
