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
    
    // Member values
    private(set) var name: String
    private(set) var spellStatuses: [String : SpellStatus]
    
    // Keys for loading/saving
    private static let charNameKey: String = "CharacterName"
    private static let spellsKey: String = "Spells"
    private static let spellNameKey: String = "SpellName"
    private static let favoriteKey: String = "Favorite"
    private static let preparedKey: String = "Prepared"
    private static let knownKey: String = "Known"
    
    init(nameIn: String, spellStatusesIn: [String:SpellStatus]) {
        name = nameIn
        spellStatuses = spellStatusesIn
    }
    
    init(nameIn: String) {
        name = nameIn
        spellStatuses = [:]
    }
    
    convenience init() {
        self.init(nameIn: "")
    }
    
    init(sion: SION) {
        spellStatuses = [:]
        name = sion[SION(CharacterProfile.charNameKey)].string!
        for (k, v) in sion {
            let spellName: String = k.string!
            let fav = v[SION(CharacterProfile.favoriteKey)].bool!
            let prep = v[SION(CharacterProfile.preparedKey)].bool!
            let known = v[SION(CharacterProfile.knownKey)].bool!
            let status = SpellStatus(favIn: fav, prepIn: prep, knownIn: known)
            spellStatuses[spellName] = status
        }
    }
    
    // To SION
    func toSION() -> SION {
        var sion = SION([:])
        sion[SION(CharacterProfile.charNameKey)] = SION(name)
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
        return sion
    }
    
    // As a JSON string
    func toJSONString() -> String {
        return toSION().json
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
    func isFavorite(s: Spell) -> Bool {
        return isProperty(s: s, propGetter: { return $0.favorite })
    }
    
    func isPrepared(s: Spell) -> Bool {
        return isProperty(s: s, propGetter: { return $0.prepared })
    }
    
    func isKnown(s: Spell) -> Bool {
        return isProperty(s: s, propGetter: { return $0.known })
    }
    
    // For getting spell status properties
    private func setProperty(s: Spell, val: Bool, propSetter: StatusPropertySetter) {
        let status: SpellStatus? = spellStatuses[s.name]
        if (status != nil) {
            propSetter(status!, val)
        } else {
            let newStatus = SpellStatus()
            propSetter(newStatus, val)
            spellStatuses[s.name] = newStatus
        }
    }
    
    // The property setters
    func setFavorite(s: Spell, fav: Bool) {
        setProperty(s: s, val: fav, propSetter: { $0.setFavorite(favIn: $1) })
    }
    
    func setPrepared(s: Spell, prep: Bool) {
        setProperty(s: s, val: prep, propSetter: { $0.setPrepared(prepIn: $1) })
    }
    
    func setKnown(s: Spell, known: Bool) {
        setProperty(s: s, val: known, propSetter: { $0.setKnown(knownIn: $1) })
    }
    
    // Save to a file
    func save(filename: URL) {
        do {
            try toJSONString().write(to: filename, atomically: false, encoding: .utf8)
        } catch let e {
            print("\(e)")
        }
    }
}
