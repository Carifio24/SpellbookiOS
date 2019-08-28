//
//  CharacterProfile.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 4/17/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import Foundation

typealias StatusPropertySetter = (SpellStatus, Bool) -> Void
typealias StatusPropertyGetter = (SpellStatus) -> Bool

class CharacterProfile {
    
    // Default books filter
    // True for PHB, false for all others
    private static let defaultBookFilters = {
        () -> [Sourcebook:Bool] in
        var defaultMap: [Sourcebook:Bool] = [:]
        for sb in Sourcebook.allCases {
            defaultMap[sb] = (sb == Sourcebook.PlayersHandbook)
        }
        return defaultMap
    }()
    
    // Member values
    private var charName: String
    private var spellStatuses: [String : SpellStatus]
    private var sortField1: SortField
    private var sortField2: SortField
    private var filterClass: CasterClass? = nil
    private var reverse1: Bool
    private var reverse2: Bool
    private var filterByBooks: [Sourcebook:Bool]
    private var statusFilter: StatusFilterField
    
    // Keys for loading/saving
    private static let charNameKey: String = "CharacterName"
    private static let spellsKey: String = "Spells"
    private static let spellNameKey: String = "SpellName"
    private static let favoriteKey: String = "Favorite"
    private static let preparedKey: String = "Prepared"
    private static let knownKey: String = "Known"
    private static let sort1Key: String = "SortField1"
    private static let sort2Key: String = "SortField2"
    private static let classFilterKey: String = "FilterClass"
    private static let reverse1Key: String = "reverse1"
    private static let reverse2Key: String = "reverse2"
    private static let booksFilterKey: String = "BookFilters"
    private static let statusFilterKey: String = "StatusFilter"
    
    init(_ nameIn: String, _ spellStatusesIn: [String:SpellStatus], _ sort1: SortField, _ sort2: SortField, _ cc: CasterClass?, _ rev1: Bool, _ rev2: Bool, _ booksFilter: [Sourcebook:Bool], _ status: StatusFilterField) {
        charName = nameIn
        spellStatuses = spellStatusesIn
        sortField1 = sort1
        sortField2 = sort2
        filterClass = cc
        reverse1 = rev1
        reverse2 = rev2
        filterByBooks = booksFilter
        statusFilter = status
    }
    
    convenience init(_ nameIn: String, _ spellStatuses: [String:SpellStatus]) {
        self.init(nameIn, spellStatuses, SortField.Name, SortField.Name, nil, false, false, CharacterProfile.defaultBookFilters, StatusFilterField.All)
    }
    
    convenience init(name: String) {
        self.init(name, [:])
        
    }
    
    convenience init() {
        self.init(name: "")
    }
    
    init(sion: SION) {
        
        print(sion.toJSON())
        
        spellStatuses = [:]
        charName = sion[SION(CharacterProfile.charNameKey)].string!
        for (k, v) in sion[SION(CharacterProfile.spellsKey)] {
            let spellName: String = v[SION(CharacterProfile.spellNameKey)].string!
            let fav = v[SION(CharacterProfile.favoriteKey)].bool!
            let prep = v[SION(CharacterProfile.preparedKey)].bool!
            let known = v[SION(CharacterProfile.knownKey)].bool!
            let status = SpellStatus(favIn: fav, prepIn: prep, knownIn: known)
            spellStatuses[spellName] = status
        }
        
        // The sorting fields
        let sortStr1: String = sion[SION(CharacterProfile.sort1Key)].string ?? SortField.Name.name()
        let sortStr2: String = sion[SION(CharacterProfile.sort2Key)].string ?? SortField.Name.name()
        sortField1 = SortField.fromName(sortStr1)!
        sortField2 = SortField.fromName(sortStr2)!
        
        // The class filter
        filterClass = nil
        let classStr: String? = sion[SION(CharacterProfile.classFilterKey)].string
        if (classStr == nil) {
            filterClass = nil
        } else {
            filterClass = CasterClass.fromName(classStr!)!
        }
        
        // The sorting directions
        reverse1 = sion[SION(CharacterProfile.reverse1Key)].bool ?? false
        reverse2 = sion[SION(CharacterProfile.reverse2Key)].bool ?? false
        
        // The status filter
        let filterStr = sion[SION(CharacterProfile.statusFilterKey)].string ?? StatusFilterField.All.name()
        statusFilter = StatusFilterField.fromName(filterStr)!
        
        // Sourcebook filters
        filterByBooks = [:]
        let booksSION = sion[SION(CharacterProfile.booksFilterKey)]
        for sb in Sourcebook.allCases {
            let b = booksSION[SION(sb.code())].bool ?? (sb == Sourcebook.PlayersHandbook)
            filterByBooks[sb] = b
        }
        
    }
    
    // To SION
    func asSION() -> SION {
        var sion = SION([:])
        sion[SION(CharacterProfile.charNameKey)] = SION(charName)
        var spellsSION = SION([])
        var idx: Int = 0
        for (spellName, status) in spellStatuses {
            var statusSION = SION([:])
            statusSION[SION(CharacterProfile.spellNameKey)] = SION(spellName)
            statusSION[SION(CharacterProfile.favoriteKey)] = SION(status.favorite)
            statusSION[SION(CharacterProfile.preparedKey)] = SION(status.prepared)
            statusSION[SION(CharacterProfile.knownKey)] = SION(status.known)
            spellsSION[idx] = statusSION
            idx += 1
        }
        sion[SION(CharacterProfile.spellsKey)] = spellsSION
        
        sion[SION(CharacterProfile.sort1Key)] = SION(sortField1.name())
        sion[SION(CharacterProfile.sort2Key)] = SION(sortField2.name())
        sion[SION(CharacterProfile.reverse1Key)] = SION(reverse1)
        sion[SION(CharacterProfile.reverse2Key)] = SION(reverse2)
        if (filterClass != nil) {
            sion[SION(CharacterProfile.classFilterKey)] = SION(filterClass!.name())
        }
        
        var booksSION = SION([:])
        for sb in Sourcebook.allCases {
            booksSION[SION(sb.code())] = SION(filterByBooks[sb]!)
        }
        sion[SION(CharacterProfile.booksFilterKey)] = booksSION
        sion[SION(CharacterProfile.statusFilterKey)] = SION(statusFilter.name())
        
        return sion
    }
    
    // As a JSON string
    func asJSONString() -> String {
        return asSION().json
    }
    
    // For setting spell status properties
    private func isProperty(s: Spell, propGetter: StatusPropertyGetter) -> Bool {
        let status: SpellStatus? = spellStatuses[s.name]
        if (status != nil) {
            return propGetter(status!)
        }
        return false
    }
    
    // The property getters
    func isFavorite(_ s: Spell) -> Bool {
        return isProperty(s: s, propGetter: { return $0.favorite })
    }
    
    func isPrepared(_ s: Spell) -> Bool {
        return isProperty(s: s, propGetter: { return $0.prepared })
    }
    
    func isKnown(_ s: Spell) -> Bool {
        return isProperty(s: s, propGetter: { return $0.known })
    }
    
    func oneTrue(_ s: Spell) -> Bool {
        return ( isFavorite(s) || isPrepared(s) || isKnown(s) )
    }
    
    func name() -> String { return charName }
    func getStatusFilter() -> StatusFilterField { return statusFilter }
    func getFilterClass() -> CasterClass? { return filterClass }
    func getFirstSortField() -> SortField { return sortField1 }
    func getSecondSortField() -> SortField { return sortField2 }
    func getFirstSortReverse() -> Bool { return reverse1 }
    func getSecondSortReverse() -> Bool { return reverse2 }
    func getSourcebookFilter(_ book: Sourcebook) -> Bool { return filterByBooks[book]! }
    
    func favoritesSelected() -> Bool { return (statusFilter == StatusFilterField.Favorites) }
    func preparedSelected() -> Bool { return (statusFilter == StatusFilterField.Prepared) }
    func knownSelected() -> Bool { return (statusFilter == StatusFilterField.Known) }
    
    
    // For getting spell status properties
    private func setProperty(s: Spell, val: Bool, propSetter: StatusPropertySetter) {
        
        // Get the status for the given spell
        let status: SpellStatus? = spellStatuses[s.name]
        
        // If the status already exists, modify it
        if (status != nil) {
            propSetter(status!, val)
        // Otherwise, add it to the dictionary. The default status has all values False
        } else {
            let newStatus = SpellStatus()
            propSetter(newStatus, val)
            spellStatuses[s.name] = newStatus
        }
        
        // If all of the values are now false, remove the entry
        if !oneTrue(s) {
            spellStatuses.removeValue(forKey: s.name)
        }
    }
    
    // The property setters
    func setFavorite(s: Spell, fav: Bool) {
        setProperty(s: s, val: fav, propSetter: { $0.setFavorite($1) })
    }
    
    func setPrepared(s: Spell, prep: Bool) {
        setProperty(s: s, val: prep, propSetter: { $0.setPrepared($1) })
    }
    
    func setKnown(s: Spell, known: Bool) {
        setProperty(s: s, val: known, propSetter: { $0.setKnown($1) })
    }
    
    func setFilterClass(_ cc: CasterClass?) { filterClass = cc }
    func setFirstSortField(_ sf: SortField) { sortField1 = sf }
    func setSecondSortField(_ sf: SortField) { sortField2 = sf }
    func setFirstSortReverse(_ r1: Bool) { reverse1 = r1 }
    func setSecondSortReverse(_ r2: Bool) { reverse2 = r2 }
    func setSourcebookFilter(book: Sourcebook, tf: Bool) {
        filterByBooks[book] = tf
    }
    func setStatusFilter(_ sff: StatusFilterField) { statusFilter = sff }
    
    // Save to a file
    func save(filename: URL) {
        do {
            //print(asJSONString())
            try asJSONString().write(to: filename, atomically: false, encoding: .utf8)
        } catch let e {
            print("\(e)")
        }
    }
}
