
//
//  EnumMap.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 2/7/20.
//  Copyright © 2020 Jonathan Carifio. All rights reserved.
//

// Stole the basic setup of this from John Sundell
// then modified it myself to make it mutable, and a reference type (struct -> class)

import Foundation

class EnumMap<Enum: CaseIterable & Hashable, Value> : NSCopying {

    private var values: [Enum : Value]
    
    init(resolver: (Enum) -> Value) {
        
        var values = [Enum : Value]()
        
        for key in Enum.allCases {
            values[key] = resolver(key)
        }
        
        self.values = values
    }
    
    // For copying
    private init(values: [Enum : Value]) {
        self.values = values
    }
    
    subscript(key: Enum) -> Value {
        get {
            // Here we have to force-unwrap, since there's no way
            // of telling the compiler that a value will always exist
            // for any given key. However, since it's kept private
            // it should be fine - and we can always add tests to
            // make sure things stay safe.
            return values[key]!
        }
        set {
            values[key] = newValue
        }
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return EnumMap<Enum,Value>(values: values)
    }
    
    func copy() -> EnumMap<Enum,Value> {
        return copy(with: nil) as! EnumMap<Enum,Value>
    }
    
}
