//
//  SpellbookStateController.swift
//  Spellbook
//
//  Created by Mac Pro on 10/2/22.
//  Copyright © 2022 Jonathan Carifio. All rights reserved.
//

import ReSwift

struct SpellbookAppState {
    
    private static let spellbook = Spellbook(jsonStr: try! String(contentsOf: Bundle.main.url(forResource: "Spells", withExtension: "json")!))
    
    var profile: CharacterProfile? = nil
    var spell: Spell? = nil
    var searchQuery: String? = nil
    let spellList: [Spell]
    var currentSpellList: [Spell]
    var profileNameList: [String] = []
    var settings: Settings
    
    init() {
        settings = SerializationUtils.loadSettings()
        if settings.charName != nil {
            if let profile = try? SerializationUtils.loadCharacterProfile(name: settings.charName!) {
                do {
                    self.profile = profile
                }
            } else {
                Toast.makeToast("Error loading character profile: " + settings.charName!)
            }
        }
        spellList = SpellbookAppState.spellbook.spells
        currentSpellList = spellList
    }
}
