//
//  Operators.swift
//  Spellbook
//
//  Created by Mac Pro on 5/14/23.
//  Copyright © 2023 Jonathan Carifio. All rights reserved.
//

import Foundation

infix operator ?!: NilCoalescingPrecedence

/// Throws the right hand side error if the left hand side optional is `nil`.
func ?!<T>(value: T?, error: @autoclosure () -> Error) throws -> T {
    guard let value = value else {
        throw error()
    }
    return value
}

