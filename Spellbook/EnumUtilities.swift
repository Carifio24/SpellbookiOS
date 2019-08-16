//
//  EnumUtilities.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 8/16/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import Foundation

// This function will allow us to compare two values of any type that is RawRepresentable based on their rawValue property
// In particular, we can use this to compare enums
func < <T: RawRepresentable>(_ a: T, _ b: T) -> Bool where T.RawValue: Comparable {
    return a.rawValue < b.rawValue
}

// Same as the above, but for equality
func == <T: RawRepresentable>(_ a: T, _ b: T) -> Bool where T.RawValue: Equatable {
    return a.rawValue == b.rawValue
}
