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
    var profileNameList: [String] = []
    
    let documentsDirectory: URL
    let profilesDirectory: URL
    let profilesDirectoryName = "Characters"
    let settingsFile = "Settings.json"
    
    init() {
        documentsDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        profilesDirectory = documentsDirectory.appendingPathComponent(profilesDirectoryName)
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: profilesDirectory.path) {
            do {
                try fileManager.createDirectory(atPath: profilesDirectory.path, withIntermediateDirectories: true, attributes: nil)
            } catch let e {
                print("\(e)")
            }
        }
    }
}
