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
    static let favoriteKey: String = "Favorite"
    static let preparedKey: String = "Prepared"
    static let knownKey: String = "Known"
    static let headerTextKey: String = "HeaderTextSize"
    static let tableTextKey: String = "TableTextSize"
    static let nRowsKey: String = "TableNRows"
    static let spellTextKey: String = "SpellTextSize"
    static let characterKey = "Character"
    static let booksFilterKey = "BooksFilter"
    
    // Default values
    static let defaultHeaderTextSize: Int = 18
    static let defaultTextSize: Int = 16
    static let defaultNTableRows: Int = 10
    static let defaultSpellTextSize: Int = 15
    static let defaultFilterMap: [Sourcebook: Bool] = [
        Sourcebook.PlayersHandbook : true,
        Sourcebook.XanatharsGTE : false,
        Sourcebook.SwordCoastAG : false
    ]
    
    // Member values
    private(set) var filterByFavorites: Bool
    private(set) var filterByPrepared: Bool
    private(set) var filterByKnown: Bool
    private(set) var tableSize: Int
    private(set) var headerSize: Int
    private(set) var nRows: Int
    private(set) var spellSize: Int
    private(set) var charName: String?
    private(set) var filterByBooks: [Sourcebook : Bool]
    
    // Constructors
    init() {
        filterByFavorites = false
        filterByPrepared = false
        filterByKnown = false
        tableSize = Settings.defaultTextSize
        headerSize = Settings.defaultHeaderTextSize
        nRows = Settings.defaultNTableRows
        spellSize = Settings.defaultSpellTextSize
        filterByBooks = Settings.defaultFilterMap
        charName = nil
    }
    
    init(json: SION) {
        filterByFavorites = json[SION(Settings.favoriteKey)].bool ?? false
        filterByPrepared = json[SION(Settings.preparedKey)].bool ?? false
        filterByKnown = json[SION(Settings.knownKey)].bool ?? false
        tableSize = json[SION(Settings.tableTextKey)].int ?? Settings.defaultTextSize
        headerSize = json[SION(Settings.headerTextKey)].int ?? Settings.defaultHeaderTextSize
        nRows = json[SION(Settings.nRowsKey)].int ?? Settings.defaultNTableRows
        spellSize = json[SION(Settings.spellTextKey)].int ?? Settings.defaultSpellTextSize
        charName = json[SION(Settings.characterKey)].string ?? nil
        let booksFilterSION: SION? = json[SION(Settings.booksFilterKey)]
        if booksFilterSION != nil {
            filterByBooks = [:]
            for sb in Sourcebook.allCases {
                let tf: Bool = booksFilterSION![SION(sb.code)].bool ?? false
                filterByBooks[sb] = tf
            }
        } else {
            filterByBooks = Settings.defaultFilterMap
        }
    }
    
    // Getters
    func setFilterFavorites(fav: Bool) { filterByFavorites = fav }
    func setFilterPrepared(prep: Bool) { filterByPrepared = prep }
    func setFilterKnown(known: Bool) { filterByKnown = known }
    func setBookFilter(sb: Sourcebook, tf: Bool) { filterByBooks[sb] = tf }
    func setCharacterName(name: String) { charName = name }
    func setHeaderTextSize(size: Int) { headerSize = size }
    func setSpellTextSize(size: Int) { spellSize = size }
    func setTableTextSize(size: Int) { tableSize = size }
    func setNTableRows(n: Int) { nRows = n }
    
    // To SION
    func toSION() -> SION {
        var sion = SION([:])
        sion[SION(Settings.favoriteKey)] = SION(filterByFavorites)
        sion[SION(Settings.preparedKey)] = SION(filterByPrepared)
        sion[SION(Settings.knownKey)] = SION(filterByKnown)
        sion[SION(Settings.tableTextKey)] = SION(tableSize)
        sion[SION(Settings.nRowsKey)] = SION(nRows)
        sion[SION(Settings.spellTextKey)] = SION(spellSize)
        sion[SION(Settings.headerTextKey)] = SION(headerSize)
        if charName != nil {
            sion[SION(Settings.characterKey)] = SION(charName!)
        }
        var booksSION = SION([:])
        for sb in Sourcebook.allCases {
            booksSION[SION(sb.code)] = SION(filterByBooks[sb]!)
        }
        sion[SION(Settings.booksFilterKey)] = booksSION
        return sion
    }
    
    // To JSON string form
    func toJSONString() -> String {
        return toSION().json
    }
    
}
