//
//  Unit.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 8/14/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import Foundation

protocol Unit {
    func singularName() -> String
    func pluralName() -> String
    func abbreviation() -> String
    func value() -> Int
}
