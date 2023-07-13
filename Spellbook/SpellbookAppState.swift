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
    
    static let allSpells = SpellbookAppState.spellbook.spells
    
    var profile: CharacterProfile? = nil
    var spell: Spell? = nil
    var searchQuery: String? = nil
    let spellList: [Spell]
    var dirtySpellIDs: [Int]
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
        profileNameList = SerializationUtils.characterNameList()
        dirtySpellIDs = []

        self.filterAndSortSpells()
    }

    mutating func sortSpells() {
        if (profile == nil) { return }
        let sortFilterStatus = profile!.sortFilterStatus
        let comparator = spellComparator(sortField1: sortFilterStatus.firstSortField, sortField2: sortFilterStatus.secondSortField, reverse1: sortFilterStatus.firstSortReverse, reverse2: sortFilterStatus.secondSortReverse)
        currentSpellList = currentSpellList.sorted { comparator($0, $1) }
    }

    mutating func filterAndSortSpells() {
        let filter = createFilter(state: self)
        currentSpellList = spellList.filter(filter)
        self.sortSpells()
    }
}
