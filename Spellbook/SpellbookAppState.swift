//
//  SpellbookStateController.swift
//  Spellbook
//
//  Created by Mac Pro on 10/2/22.
//  Copyright © 2022 Jonathan Carifio. All rights reserved.
//

import ReSwift

struct SpellbookAppState {
    var profile: CharacterProfile? = nil
    var spell: Spell? = nil
    var searchQuery: String? = nil
    var spellList: [Spell] = []
    var currentSpellList: [Spell] = []
}
