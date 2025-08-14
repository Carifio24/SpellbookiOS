//
//  Ruleset.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 9/21/24.
//  Copyright © 2024 Jonathan Carifio. All rights reserved.
//

import Foundation

enum Ruleset: Int, NameConstructible {
    case Rules2014, Rules2024, RulesCreated
    
    internal static var displayNameMap = EnumMap<Ruleset, String> { e in
        switch(e) {
        case .Rules2014:
            return "2014"
        case .Rules2024:
            return "2024"
        case .RulesCreated:
            return "Created"
        }
    }
}
