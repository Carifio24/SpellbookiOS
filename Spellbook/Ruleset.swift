//
//  Ruleset.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 9/21/24.
//  Copyright © 2024 Jonathan Carifio. All rights reserved.
//

import Foundation

enum Ruleset {
    case Rules2014, Rules2024, RulesCreated
    
    private static let nameMap: [String:Ruleset] = [
        "2014": Rules2014,
        "2024": Rules2024,
        "created": RulesCreated,
    ]
    
    static func fromName(_ name: String?) -> Ruleset? {
        guard var key = name?.lowercased() else { return nil }
        return Ruleset.nameMap[key]
    }
}
