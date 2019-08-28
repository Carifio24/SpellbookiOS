//
//  Settings.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 4/15/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import Foundation

class Settings {
    
    // Keys
    static let headerTextKey: String = "HeaderTextSize"
    static let tableTextKey: String = "TableTextSize"
    static let nRowsKey: String = "TableNRows"
    static let spellTextKey: String = "SpellTextSize"
    static let characterKey = "Character"
    
    // Default values
    static let defaultHeaderTextSize: Int = 18
    static let defaultTextSize: Int = 16
    static let defaultNTableRows: Int = 10
    static let defaultSpellTextSize: Int = 15
    
    // Member values
    private(set) var tableSize: Int
    private(set) var headerSize: Int
    private(set) var nRows: Int
    private(set) var spellSize: Int
    private(set) var charName: String?
    
    // Constructors
    init() {
        tableSize = Settings.defaultTextSize
        headerSize = Settings.defaultHeaderTextSize
        nRows = Settings.defaultNTableRows
        spellSize = Settings.defaultSpellTextSize
        charName = nil
    }
    
    init(json: SION) {
        tableSize = json[SION(Settings.tableTextKey)].int ?? Settings.defaultTextSize
        headerSize = json[SION(Settings.headerTextKey)].int ?? Settings.defaultHeaderTextSize
        nRows = json[SION(Settings.nRowsKey)].int ?? Settings.defaultNTableRows
        spellSize = json[SION(Settings.spellTextKey)].int ?? Settings.defaultSpellTextSize
        charName = json[SION(Settings.characterKey)].string ?? nil
    }
    
    // Setters
    func setCharacterName(name: String?) { charName = name }
    func setHeaderTextSize(size: Int) { headerSize = size }
    func setSpellTextSize(size: Int) { spellSize = size }
    func setTableTextSize(size: Int) { tableSize = size }
    func setNTableRows(n: Int) { nRows = n }
    
    // To SION
    func toSION() -> SION {
        var sion = SION([:])
        sion[SION(Settings.tableTextKey)] = SION(tableSize)
        sion[SION(Settings.nRowsKey)] = SION(nRows)
        sion[SION(Settings.spellTextKey)] = SION(spellSize)
        sion[SION(Settings.headerTextKey)] = SION(headerSize)
        if charName != nil {
            sion[SION(Settings.characterKey)] = SION(charName!)
        }
        return sion
    }
    
    // To JSON string form
    func toJSONString() -> String {
        return toSION().json
    }
    
    // Save to file
    func save(filename: URL) {
        do {
            try toJSONString().write(to: filename, atomically: false, encoding: .utf8)
        } catch let e {
            print("\(e)")
        }
    }
    
}
