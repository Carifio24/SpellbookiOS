//
//  SpellFilterStatus.swift
//  Spellbook
//
//  Created by Mac Pro on 10/4/22.
//  Copyright © 2022 Jonathan Carifio. All rights reserved.
//

import Foundation
import RxRelay

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
    
    private var spellStatusMap: [Int:SpellStatus]
    let spellFilterFlag: BehaviorRelay<Void> = BehaviorRelay(value: ())
    
    init(map: [Int:SpellStatus]) {
        self.spellStatusMap = map
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
                            prepared: status[SpellFilterStatus.knownKey].bool ?? false,
                            known: status[SpellFilterStatus.preparedKey].bool ?? false)
            }
        }
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
    
    func spellsWithOneProperty() -> [Int] {
        return spellStatusMap.filter({ $1.favorite || $1.prepared || $1.known }).map({$0.key})
    }
    
    // Setting whether a spell is ony a given spell list
    private func setProperty(spell: Spell, value: Bool, propSetter: (SpellStatus, Bool) -> Void) {
        let id = spell.id
        if let status = spellStatusMap[id] {
            propSetter(status, value)
            if status.noneTrue {
                spellStatusMap.removeValue(forKey: id)
            }
        } else if value {
            let status = SpellStatus()
            propSetter(status, true)
            spellStatusMap[id] = status
        }
        spellFilterFlag.accept(())
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
        return SION(arrayLiteral: sion)
    }
    
}
