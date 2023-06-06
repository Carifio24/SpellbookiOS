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
typealias Filter<T> = (T) -> Bool
typealias Visibilities<T:NameDisplayable & CaseIterable & Hashable> = EnumMap<T,Bool>
//typealias Visibilities<T:Hashable> = [T:Bool]
//typealias EnumInfo<T:NameDisplayable> = ((T) -> Bool, String, String)
typealias EnumInfo = (Any.Type, Bool, (Any) -> Bool, String, String)

class RangeInfo<U:Unit> : NSCopying {
    var minUnit: U
    var maxUnit: U
    var minValue: Int
    var maxValue: Int
    
    init(minUnit: U, maxUnit: U, minValue: Int, maxValue: Int) {
        self.minUnit = minUnit; self.maxUnit = maxUnit; self.minValue = minValue; self.maxValue = maxValue
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return RangeInfo<U>(minUnit: minUnit, maxUnit: maxUnit, minValue: minValue, maxValue: maxValue)
    }
    
    func copy() -> RangeInfo<U> {
        return copy(with: nil) as! RangeInfo<U>
    }
    
    
}

class CharacterProfile {
    
    private static func defaultFilterMap<E:Hashable>(type: E.Type, filter: Filter<E> = { _ in return true }) -> Visibilities<E> {
        let enumMap = Visibilities<E> { e in return filter(e) }
        return enumMap
    }
    
//    private static func defaultFilterMap<E:CaseIterable & Hashable>(type: E.Type, filter: Filter<E> = { _ in return true }) -> Visibilities<E> {
//        var map: Visibilities<E> = [:]
//        for e in E.allCases {
//            map[e] = filter(e)
//        }
//        return map
//    }
    
    
    private static let enumInfo: [ ObjectIdentifier : EnumInfo ] = [
        ObjectIdentifier(Sourcebook.self) : (Sourcebook.self, true, { return $0 is Sourcebook && ($0 as! Sourcebook) == Sourcebook.PlayersHandbook }, "HiddenSourcebooks", ""),
        ObjectIdentifier(CasterClass.self) : (CasterClass.self, false, { _ in return true }, "HiddenCasters", ""),
        ObjectIdentifier(School.self) : (School.self, false, { _ in return true }, "HiddenSchools", ""),
        ObjectIdentifier(CastingTimeType.self) : (CastingTimeType.self, false, { _ in return true }, "HiddenCastingTimeTypes", "CastingTimeFilters"),
        ObjectIdentifier(Duration.self) : (Duration.self, false, { _ in return true }, "HiddenDurationTypes", "DurationFilters"),
        ObjectIdentifier(RangeType.self) : (RangeType.self, false, { _ in return true }, "HiddenRangeTypes", "RangeFilters")
    ]
    private static let keyToIDMap: [ String : ObjectIdentifier ] = {
        var map: [ String : ObjectIdentifier ] = [:]
        for (id, tpl) in enumInfo {
            map[tpl.4] = id
        }
        return map
    }()
    
    // Default visibility maps
    private static let defaultSourcebookVisibilities = defaultFilterMap(type: Sourcebook.self, filter: { return $0 == Sourcebook.PlayersHandbook })
    private static let defaultCasterVisibilities = defaultFilterMap(type: CasterClass.self)
    private static let defaultSchoolVisibilities = defaultFilterMap(type: School.self)
    private static let defaultCastingTimeTypeVisibilities = defaultFilterMap(type: CastingTimeType.self)
    private static let defaultDurationTypeVisibilities = defaultFilterMap(type: DurationType.self)
    private static let defaultRangeTypeVisibilities = defaultFilterMap(type: RangeType.self)
    
    // Default quantity range filter info
    // Format is (Quantity.Type, Unit.Type, minUnit, maxUnit, minValue, maxValue)
//    private static let defaultCastingTimeFilters = (CastingTime.self, TimeUnit.self, TimeUnit.second, TimeUnit.hour, 0, 24)
//    private static let defaultDurationFilters = (Duration.self, TimeUnit.self, TimeUnit.second, TimeUnit.day, 0, 30)
//    private static let defaulRangeFilters = (Range.self, LengthUnit.self, LengthUnit.foot, LengthUnit.mile, 0, 1)
    
    private static let defaultCastingTimeRangeInfo = RangeInfo<TimeUnit>(minUnit: TimeUnit.second, maxUnit: TimeUnit.hour, minValue: 0, maxValue: 24)
    private static let defaultDurationRangeInfo = RangeInfo<TimeUnit>(minUnit: TimeUnit.second, maxUnit: TimeUnit.day, minValue: 0, maxValue: 30)
    private static let defaultRangeRangeInfo = RangeInfo<LengthUnit>(minUnit: LengthUnit.foot, maxUnit: LengthUnit.mile, minValue: 0, maxValue: 1)
    
    // Keys for loading/saving
    static let nameKey: String = "CharacterName"
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
    private static let minSpellLevelKey: String = "MinSpellLevel"
    private static let maxSpellLevelKey: String = "MaxSpellLevel"
    private static let hiddenSourcebooksKey: String = "HiddenSourcebooks"
    private static let hiddenCastersKey: String = "HiddenCasters"
    private static let hiddenSchoolsKey: String = "HiddenSchools"
    private static let hiddenCastingTimeTypesKey: String = "HiddenCastingTimeTypes"
    private static let hiddenDurationTypesKey: String = "HiddenDurationTypes"
    private static let hiddenRangeTypesKey: String = "HiddenRangeTypes"
    private static let ritualKey: String = "Ritual"
    private static let notRitualKey: String = "NotRitual"
    private static let concentrationKey: String = "Concentration"
    private static let notConcentrationKey: String = "NotConcentration"
    private static let verbalKey: String = "Verbal"
    private static let notVerbalKey: String = "NotVerbal"
    private static let somaticKey: String = "Somatic"
    private static let notSomaticKey: String = "NotSomatic"
    private static let materialKey: String = "Material"
    private static let notMaterialKey: String = "NotMaterial"
    private static let versionCodeKey: String = "VersionCode"
    private static let applyFiltersToListsKey: String = "ApplyFiltersToLists"
    private static let applyFiltersToSearchKey: String = "ApplyFiltersToSearch"
    private static let useTCEExpandedListsKey: String = "UseTCEExpandedLists"
    
    // Keys for storing range filter info
    private static let castingTimeRangeKey = "CastingTimeFilters"
    private static let durationRangeKey = "DurationFilters"
    private static let rangeRangeKey = "RangeFilters"
    private static let rangeFilterKeys = [ "MinUnit", "MaxUnit", "MinText", "MaxText" ]
    
    // Keys for member values
    private static let spellFilterStatusKey = "SpellFilterStatus"
    private static let sortFilterStatusKey = "SortFilterStatus"
    private static let spellSlotStatusKey = "SpellSlotStatus"
    
    // Member values
    private(set) var name: String
    private(set) var sortFilterStatus: SortFilterStatus
    let spellFilterStatus: SpellFilterStatus
    let spellSlotStatus: SpellSlotStatus

    
    init(name: String, sortFilterStatus: SortFilterStatus, spellFilterStatus: SpellFilterStatus, spellSlotStatus: SpellSlotStatus) {
        self.name = name
        self.sortFilterStatus = sortFilterStatus
        self.spellFilterStatus = spellFilterStatus
        self.spellSlotStatus = spellSlotStatus
    }
    
    convenience init(name: String, spellFilterStatus: SpellFilterStatus) {
        self.init(name: name,
                  sortFilterStatus: SortFilterStatus(),
                  spellFilterStatus: spellFilterStatus,
                  spellSlotStatus:  SpellSlotStatus())
    }
    
    convenience init(name: String) {
        self.init(name: name, spellFilterStatus: SpellFilterStatus())
    }
    
    convenience init() {
        self.init(name: "")
    }
    
    convenience init(sion: SION) throws {
        let name = try sion[CharacterProfile.nameKey].string ?! SpellbookError.BadCharacterProfileError
        self.init(name: name,
                  sortFilterStatus: SortFilterStatus(sion: sion[CharacterProfile.sortFilterStatusKey]),
                  spellFilterStatus: SpellFilterStatus(sion: sion[CharacterProfile.spellFilterStatusKey]),
                  spellSlotStatus: SpellSlotStatus(sion: sion[CharacterProfile.spellSlotStatusKey]))
    }
    
    static func fromLegacySION(sion: SION) -> CharacterProfile {
        
        //print("Initializing character from:")
        //print(sion.toJSON())
        
        let sortFilterStatus = SortFilterStatus()
        let spellSlotStatus = SpellSlotStatus()
        
        let scagEnding = " (SCAG)"
        var spellStatusesByName: [String:SpellStatus] = [:]
        let name = sion[CharacterProfile.nameKey].string!
        for (_, v) in sion[CharacterProfile.spellsKey] {
            var spellName: String = v[CharacterProfile.spellNameKey].string!
            if Spellbook.SCAG_CANTRIPS.contains(spellName) {
                spellName += scagEnding
            }
            let fav = v[CharacterProfile.favoriteKey].bool!
            let prep = v[CharacterProfile.preparedKey].bool!
            let known = v[CharacterProfile.knownKey].bool!
            let status = SpellStatus(favorite: fav, prepared: prep, known: known)
            spellStatusesByName[spellName] = status
        }
        let spellStatuses = CharacterProfile.convertStatusMap(oldMap: spellStatusesByName)
        let spellFilterStatus = SpellFilterStatus(map: spellStatuses)
        
        // The sorting fields
        let sortStr1 = sion[CharacterProfile.sort1Key].string ?? SortField.Name.displayName
        let sortStr2 = sion[CharacterProfile.sort2Key].string ?? SortField.Name.displayName
        sortFilterStatus.firstSortField = SortField.fromName(sortStr1)
        sortFilterStatus.secondSortField = SortField.fromName(sortStr2)
        
        // Visibilities for various quantities
        let sourcebookVisibilities = CharacterProfile.mapFromHiddenNames(type: Sourcebook.self, nonTrivialFilter: true, sion: sion, key: CharacterProfile.hiddenSourcebooksKey)
        for sb in Sourcebook.allCases { sortFilterStatus.setSourceVisibility(sb, visible: sourcebookVisibilities[sb]) }
        let casterVisibilities = CharacterProfile.mapFromHiddenNames(type: CasterClass.self, nonTrivialFilter: false, sion: sion, key: CharacterProfile.hiddenCastersKey)
        for cc in CasterClass.allCases { sortFilterStatus.setClassVisibility(cc, visible: casterVisibilities[cc]) }
        let schoolVisibilities = CharacterProfile.mapFromHiddenNames(type: School.self, nonTrivialFilter: false, sion: sion, key: CharacterProfile.hiddenSchoolsKey)
        for school in School.allCases { sortFilterStatus.setSchoolVisibility(school, visible: schoolVisibilities[school]) }
        let castingTimeTypeVisibilities = CharacterProfile.mapFromHiddenNames(type: CastingTimeType.self, nonTrivialFilter: false, sion: sion, key: CharacterProfile.hiddenCastingTimeTypesKey)
        for ctt in CastingTimeType.allCases { sortFilterStatus.setCastingTimeTypeVisibility(ctt, visible: castingTimeTypeVisibilities[ctt]) }
        let durationTypeVisibilities = CharacterProfile.mapFromHiddenNames(type: DurationType.self, nonTrivialFilter: false, sion: sion, key: CharacterProfile.hiddenDurationTypesKey)
        for dt in DurationType.allCases { sortFilterStatus.setDurationTypeVisibility(dt, visible: durationTypeVisibilities[dt]) }
        let rangeTypeVisibilities = CharacterProfile.mapFromHiddenNames(type: RangeType.self, nonTrivialFilter: false, sion: sion, key: CharacterProfile.hiddenRangeTypesKey)
        for rt in RangeType.allCases { sortFilterStatus.setRangeTypeVisibility(rt, visible: rangeTypeVisibilities[rt]) }
        
        // Handle sourcebook visibilities (for loading from old profiles)
        let booksSION = sion[CharacterProfile.booksFilterKey]
        if booksSION.type != SION.ContentType.error {
            for (k, v) in booksSION {
                let sbCode = k.string
                let tf = v.bool
                if (sbCode == nil) || (tf == nil) { continue }
                let sb = Sourcebook.fromCode(sbCode!)
                if (sb != nil) {
                    sourcebookVisibilities[sb!] = tf!
                }
            }
        }
        
        // Quantity range information
        sortFilterStatus.setCastingTimeBoundsFromLegacySION(sion: sion[CharacterProfile.castingTimeRangeKey])
        sortFilterStatus.setDurationBoundsFromLegacySION(sion: sion[CharacterProfile.durationRangeKey])
        sortFilterStatus.setRangeBoundsFromLegacySION(sion: sion[CharacterProfile.rangeRangeKey])
        
        // The sorting directions
        sortFilterStatus.firstSortReverse = sion[CharacterProfile.reverse1Key].bool ?? false
        sortFilterStatus.secondSortReverse = sion[CharacterProfile.reverse2Key].bool ?? false
        
        // The status filter
        let filterStr = sion[CharacterProfile.statusFilterKey].string ?? StatusFilterField.All.name()
        sortFilterStatus.statusFilterField = StatusFilterField.fromName(filterStr)!
        
        // Min and max spell levels
        sortFilterStatus.minSpellLevel = sion[CharacterProfile.minSpellLevelKey].int ?? Spellbook.MIN_SPELL_LEVEL
        sortFilterStatus.maxSpellLevel = sion[CharacterProfile.maxSpellLevelKey].int ?? Spellbook.MAX_SPELL_LEVEL

        // Ritual and concentration filters
        sortFilterStatus.setRitualFilter(true, to: sion[CharacterProfile.ritualKey].bool ?? true)
        sortFilterStatus.setRitualFilter(false, to: sion[CharacterProfile.notRitualKey].bool ?? true)
        sortFilterStatus.setConcentrationFilter(true, to: sion[CharacterProfile.concentrationKey].bool ?? true)
        sortFilterStatus.setConcentrationFilter(false, to: sion[CharacterProfile.notConcentrationKey].bool ?? true)
        
        // Component filters
        sortFilterStatus.setVerbalFilter(true, to: sion[CharacterProfile.verbalKey].bool ?? true)
        sortFilterStatus.setVerbalFilter(false, to: sion[CharacterProfile.notVerbalKey].bool ?? true)
        sortFilterStatus.setSomaticFilter(true, to: sion[CharacterProfile.somaticKey].bool ?? true)
        sortFilterStatus.setSomaticFilter(false, to: sion[CharacterProfile.notSomaticKey].bool ?? true)
        sortFilterStatus.setMaterialFilter(true, to: sion[CharacterProfile.materialKey].bool ?? true)
        sortFilterStatus.setMaterialFilter(false, to: sion[CharacterProfile.notMaterialKey].bool ?? true)
        
        // Filter options
        sortFilterStatus.applyFiltersToLists = sion[CharacterProfile.applyFiltersToListsKey].bool ?? false
        sortFilterStatus.applyFiltersToSearch = sion[CharacterProfile.applyFiltersToSearchKey].bool ?? false
        sortFilterStatus.useTashasExpandedLists = sion[CharacterProfile.useTCEExpandedListsKey].bool ?? false
        
        // Any version-specific options
        let versionCode: String? = sion[CharacterProfile.versionCodeKey].string ?? nil
        var version: Version? = nil
        if (versionCode != nil) {
            //versionCode!.replacingOccurrences(of: "_", with: ".")
            let array = versionCode!.split(separator: "_")
            let versionString = array[1...array.count-1].joined(separator: ".")
            version = Version.fromString(versionString)
        }
        let v2_10_0 = Version(major: 2, minor: 10, patch: 0)
        let v2_11_0 = Version(major: 2, minor: 11, patch: 0)
        let v2_12_0 = Version(major: 2, minor: 12, patch: 0)
        let v2_13_0 = Version(major: 2, minor: 13, patch: 0)
        if (version == nil || version! == v2_10_0) {
            let new_v211 = [
                Sourcebook.ExplorersGTW,
                Sourcebook.RimeOTFrostmaiden,
                Sourcebook.LostLabKwalish,
                Sourcebook.AcquisitionsInc
            ]
            for sb in new_v211 {
                sortFilterStatus.setSourceVisibility(sb, visible: false)
            }
        }
        if (version == nil || version! >= v2_10_0 && version! <= v2_11_0) {
            sortFilterStatus.setSourceVisibility(Sourcebook.FizbansTOD, visible: false)
        }
        if (version == nil || version! >= v2_10_0 && version! <= v2_12_0) {
            sortFilterStatus.setSourceVisibility(Sourcebook.StrixhavenCOC, visible: false)
        }
        if (version == nil || version! >= v2_10_0 && version! <= v2_13_0) {
            sortFilterStatus.setSourceVisibility(Sourcebook.AstralAG, visible: false)
        }
        
        return CharacterProfile(name: name, sortFilterStatus: sortFilterStatus, spellFilterStatus: spellFilterStatus, spellSlotStatus: spellSlotStatus)
        
    }
    
    // To SION
    func toSION() -> SION {
        var sion: SION = [:]
        sion[CharacterProfile.nameKey].string = name
        sion[CharacterProfile.spellSlotStatusKey] = spellSlotStatus.toSION()
        sion[CharacterProfile.spellFilterStatusKey] = spellFilterStatus.toSION()
        sion[CharacterProfile.sortFilterStatusKey] = sortFilterStatus.toSION()
        return sion
    }
    
    // As a JSON string
    func toJSONString() -> String {
        return toSION().json
    }

    // For converting a RangeInfo<T> to a SION array
    func rangeInfoToSION<U:Unit>(_ rangeInfo: RangeInfo<U>) -> SION {
        var rangeSION: SION = [:]
        rangeSION[CharacterProfile.rangeFilterKeys[0]] = SION(rangeInfo.minUnit.pluralName)
        rangeSION[CharacterProfile.rangeFilterKeys[1]] = SION(rangeInfo.maxUnit.pluralName)
        rangeSION[CharacterProfile.rangeFilterKeys[2]] = SION(rangeInfo.minValue)
        rangeSION[CharacterProfile.rangeFilterKeys[3]] = SION(rangeInfo.maxValue)
        return rangeSION
    }
    
    // Which default map to use for a given type
        static func getDefaultTypeMap<E:CaseIterable & Hashable>(_ t : E.Type) -> Visibilities<E>? {
            let id = ObjectIdentifier(t)
            switch (id) {
            case ObjectIdentifier(Sourcebook.self):
                return CharacterProfile.defaultSourcebookVisibilities as? Visibilities<E>
            case ObjectIdentifier(CasterClass.self):
                return CharacterProfile.defaultCasterVisibilities as? Visibilities<E>
            case ObjectIdentifier(School.self):
                return CharacterProfile.defaultSchoolVisibilities as? Visibilities<E>
            case ObjectIdentifier(CastingTimeType.self):
                return CharacterProfile.defaultCastingTimeTypeVisibilities as? Visibilities<E>
            case ObjectIdentifier(DurationType.self):
                return CharacterProfile.defaultDurationTypeVisibilities as? Visibilities<E>
            case ObjectIdentifier(RangeType.self):
                return CharacterProfile.defaultRangeTypeVisibilities as? Visibilities<E>
            default:
                return nil
            }
        }
    
    // Constructing a map from a list of hidden values
    // Used for JSON decoding
    private static func mapFromHiddenNames<E:NameConstructible>(type: E.Type, nonTrivialFilter: Bool, sion: SION, key: String) -> Visibilities<E> {
        
        // The default map
        var map = CharacterProfile.getDefaultTypeMap(E.self)!.copy()
        
        // Query the appropriate key
        let sionArray = sion[key].array
        
        // If we have the key, do what we need to
        if (sionArray != nil) {
            
            // If the filter is nontrivial, and we have the key, we want to start everything as true
            if nonTrivialFilter {
                map = Visibilities<E> { _ in return true }
            }
            
            // Make modifications to the map, hiding any values whose names are present in the array
            for v in sionArray! {
                let name = v.string!
                let value = E.fromName(name)
                map[value] = false
            }
        }
        return map
    }

    
    // Save to a file
    func save(filename: URL) -> Bool {
        do {
            //print(asJSONString())
            try toJSONString().write(to: filename, atomically: false, encoding: .utf8)
            return true
        } catch let e {
            print("\(e)")
            return false
        }
    }
    
    private static func convertStatusMap(oldMap: [String: SpellStatus]) -> [Int: SpellStatus] {
        let scagCantrips: Set = ["Booming Blade", "Green-Flame Blade", "Lightning Lure", "Sword Burst"]
        let spells = store.state.spellList
        var idMap: [String: Int] = [:]
        for spell in spells {
            idMap[spell.name] = spell.id
        }
        
        var newMap: [Int: SpellStatus] = [:]
        for (name, status) in oldMap {
            var nameToUse = name
            if scagCantrips.contains(name) {
                nameToUse = nameToUse + " (SCAG)"
            }
            if let id = idMap[nameToUse] {
                newMap[id] = status
            }
        }
        return newMap
    }
}

