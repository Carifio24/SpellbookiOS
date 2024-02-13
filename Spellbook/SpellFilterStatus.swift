//
//  SpellFilterStatus.swift
//  Spellbook
//
//  Created by Mac Pro on 10/4/22.
//  Copyright © 2022 Jonathan Carifio. All rights reserved.
//

import Foundation

class SpellFilterStatus {
    
    private typealias SpellStatusProperty = (SpellStatus) -> Bool
    
    private static let spellsKey = "spells"
    private static let spellIDKey = "spellID"
    private static let favoriteKey = "favorite"
    private static let preparedKey = "prepared"
    private static let knownKey = "known"
    
    private static let favoriteProperty: SpellStatusProperty = { status in return status.favorite }
    private static let preparedProperty: SpellStatusProperty = { status in return status.prepared }
    private static let knownProperty: SpellStatusProperty = { status in return status.known }
    
    private var favoritesCount = 0
    private var preparedCount = 0
    private var knownCount = 0
    
    private var spellStatusMap: [Int: SpellStatus]
    
    init(map: [Int:SpellStatus]) {
        self.spellStatusMap = map
        self.updateAllListCounts()
    }
    
    convenience init() {
        self.init(map: [:])
    }
    
    init(sion: SION) {
        self.spellStatusMap = [:]
        if let statuses = sion[SpellFilterStatus.spellsKey].array {
            for status in statuses {
                self.spellStatusMap[status[SpellFilterStatus.spellIDKey].int ?? 0] =
                SpellStatus(favorite: status[SpellFilterStatus.favoriteKey].bool ?? false,
                            prepared: status[SpellFilterStatus.preparedKey].bool ?? false,
                            known: status[SpellFilterStatus.knownKey].bool ?? false)
            }
        }
        self.updateAllListCounts()
    }
    
    private func isProperty(_ spell: Spell, property: SpellStatusProperty) -> Bool {
        if let status = self.spellStatusMap[spell.id] {
            return property(status)
        }
        return false
    }
    
    func isFavorite(_ spell: Spell) -> Bool {
        return isProperty(spell, property: SpellFilterStatus.favoriteProperty)
    }
    
    func isPrepared(_ spell: Spell) -> Bool {
        return isProperty(spell, property: SpellFilterStatus.preparedProperty)
    }
    
    func isKnown(_ spell: Spell) -> Bool {
        return isProperty(spell, property: SpellFilterStatus.knownProperty)
    }
    
    func hiddenByFilter(spell: Spell, filterField: StatusFilterField) -> Bool {
        switch filterField {
        case .All:
            return false
        case .Favorites:
            return !isFavorite(spell)
        case .Prepared:
            return !isPrepared(spell)
        case .Known:
            return !isKnown(spell)
        }
    }
    
    func getStatus(id: Int) -> SpellStatus? { return spellStatusMap[id] }
    
    func getStatus(spell: Spell) -> SpellStatus? { return getStatus(id: spell.id) }
    
    private func spellIDsByProperty(property: SpellStatusProperty) -> [Int] {
        return spellStatusMap.filter({property($1)}).map({$0.key})
    }
    
    func favoriteSpellIDs() -> [Int] {
        return spellIDsByProperty(property: SpellFilterStatus.favoriteProperty)
    }
    
    func preparedSpellIDs() -> [Int] {
        return spellIDsByProperty(property: SpellFilterStatus.preparedProperty)
    }
    
    func knownSpellIDs() -> [Int] {
        return spellIDsByProperty(property: SpellFilterStatus.knownProperty)
    }
    
    func listsCount(status: SpellStatus) -> Int {
        return [status.favorite, status.prepared, status.known].filter({ $0 }).count
    }
    
    func listsCount(spell: Spell) -> Int {
        guard let status = spellStatusMap[spell.id] else { return 0 }
        return listsCount(status: status)
    }
    
    func spellsWithOneProperty() -> [Int] {
        return spellStatusMap.filter({ $1.favorite || $1.prepared || $1.known }).map({$0.key})
    }
    
    // Setting whether a spell is ony a given spell list
    private func setProperty(spell: Spell, value: Bool,
                             propSetter: (SpellStatus, Bool) -> Void,
                             listCountUpdater: () -> Void) {
        let id = spell.id
        if let status = spellStatusMap[id] {
            let initialListCount = listsCount(status: status)
            propSetter(status, value)
            let finalListCount = listsCount(status: status)
            if status.noneTrue {
                spellStatusMap.removeValue(forKey: id)
            }
            if finalListCount != initialListCount {
                listCountUpdater()
            }
        } else if value {
            let status = SpellStatus()
            propSetter(status, true)
            spellStatusMap[id] = status
            listCountUpdater()
        }
    }
    
    private func updateFavoritesCount() {
        self.favoritesCount = self.favoriteSpellIDs().count
    }
    
    private func updatePreparedCount() {
        self.preparedCount = self.preparedSpellIDs().count
    }
    
    private func updateKnownCount() {
        self.knownCount = self.knownSpellIDs().count
    }
    
    private func updateAllListCounts() {
        self.updateFavoritesCount()
        self.updatePreparedCount()
        self.updateKnownCount()
    }
    
    // The property setters
    func setFavorite(spell: Spell, favorite: Bool) {
        setProperty(spell: spell, value: favorite,
                    propSetter: { $0.setFavorite($1) },
                    listCountUpdater: self.updateFavoritesCount
        )
    }
    
    func setPrepared(spell: Spell, prepared: Bool) {
        setProperty(spell: spell, value: prepared,
                    propSetter: { $0.setPrepared($1) },
                    listCountUpdater: self.updatePreparedCount
        )
    }
    
    func setKnown(spell: Spell, known: Bool) {
        setProperty(spell: spell, value: known,
                    propSetter: { $0.setKnown($1) },
                    listCountUpdater: self.updateKnownCount
        )
    }
    
    // For toggling spell status properties
    private func toggleProperty(spell: Spell, propGetter: StatusPropertyGetter,
                                propSetter: StatusPropertySetter,
                                listCountUpdater: () -> Void)
    {
        setProperty(spell: spell, value: !isProperty(spell, property: propGetter), propSetter: propSetter, listCountUpdater: listCountUpdater)
    }
    
    func toggleFavorite(_ s: Spell) {
        toggleProperty(spell: s, propGetter: { return $0.favorite },
                       propSetter: { $0.setFavorite($1) },
                       listCountUpdater: self.updateFavoritesCount
        )
    }
    
    func togglePrepared(_ s: Spell) {
        toggleProperty(spell: s, propGetter: { return $0.prepared },
                       propSetter: { $0.setPrepared($1) },
                       listCountUpdater: self.updatePreparedCount
        )
    }
    
    func toggleKnown(_ s: Spell) {
        toggleProperty(spell: s, propGetter: { return $0.known },
                       propSetter: { $0.setKnown($1) },
                       listCountUpdater: self.updateKnownCount
        )
    }

    func toSION() -> SION {
        var sion: SION = [:]
        var spellStatuses: [SION] = []
        for (id, status) in spellStatusMap {
            var statusSION: SION = [:]
            statusSION[SpellFilterStatus.spellIDKey].int = id
            statusSION[SpellFilterStatus.favoriteKey].bool = status.favorite
            statusSION[SpellFilterStatus.preparedKey].bool = status.prepared
            statusSION[SpellFilterStatus.knownKey].bool = status.known
            spellStatuses.append(statusSION)
        }
        sion[SpellFilterStatus.spellsKey].array = spellStatuses
        return sion
    }
    
}
