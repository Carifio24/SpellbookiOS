//
//  QuantityType.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 2/12/20.
//  Copyright © 2020 Jonathan Carifio. All rights reserved.
//

import Foundation

protocol QuantityType: NameConstructible {
    
    // Is the quantity type the spanning type
    func isSpanningType() -> Bool
    
    // Static values for spanning type and default value
    static var spanningType: Self { get }
    static var defaultValue: Int { get }
    
}

extension QuantityType {
    
    func isSpanningType() -> Bool {
        return self == Self.spanningType
    }
    
}
