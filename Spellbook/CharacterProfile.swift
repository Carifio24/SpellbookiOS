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
typealias Visibilities<T:CaseIterable & Hashable> = EnumMap<T,Bool>
//typealias Visibilities<T:Hashable> = [T:Bool]
typealias EnumInfo = (Any.Type, Bool, (Any) -> Bool, String, String)

class RangeInfo<U:Unit> {
    var minUnit: U
    var maxUnit: U
    var minValue: Int
    var maxValue: Int
    
    init(minUnit: U, maxUnit: U, minValue: Int, maxValue: Int) {
        self.minUnit = minUnit; self.maxUnit = maxUnit; self.minValue = minValue; self.maxValue = maxValue
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
    private static let minSpellLevelKey: String = "MinSpellLevel"
    private static let maxSpellLevelKey: String = "MaxSpellLevel"
    private static let hiddenSourcebooksKey: String = "HiddenSourcebooks"
    private static let hiddenCastersKey: String = "HiddenCasters"
    private static let hiddenSchoolsKey: String = "HiddenSchools"
    private static let hiddenCastingTimeTypesKey: String = "HiddenCastingTimeTypes"
    private static let hiddenDurationTypesKey: String = "HiddenDurationTypes"
    private static let hiddenRangeTypesKey: String = "HiddenRangeTypes"
    private static let versionCodeKey: String = "VersionCode"
    
    // Keys for storing range filter info
    private static let castingTimeRangeKey = "CastingTimeFilters"
    private static let durationRangeKey = "DurationFilters"
    private static let rangeRangeKey = "RangeFilters"
    private static let rangeFilterKeys = [ "MinUnit", "MaxUnit", "MinText", "MaxText" ]
    
    
    // Member values
    private var charName: String
    private var spellStatuses: [String : SpellStatus]
    private var sortField1: SortField
    private var sortField2: SortField
    private var reverse1: Bool
    private var reverse2: Bool
    private var statusFilter: StatusFilterField
    private var minSpellLevel: Int
    private var maxSpellLevel: Int
    private var sourcebookVisibilities: Visibilities<Sourcebook>
    private var casterVisibilities: Visibilities<CasterClass>
    private var schoolVisibilities: Visibilities<School>
    private var castingTimeTypeVisibilities: Visibilities<CastingTimeType>
    private var durationTypeVisibilities: Visibilities<DurationType>
    private var rangeTypeVisibilities: Visibilities<RangeType>
    private var castingTimeRangeInfo: RangeInfo<TimeUnit>
    private var durationRangeInfo: RangeInfo<TimeUnit>
    private var rangeRangeInfo: RangeInfo<LengthUnit>
    
    
    init(name: String, spellStatuses: [String:SpellStatus], sortField1: SortField, sortField2: SortField, reverse1: Bool, reverse2: Bool, statusFilter: StatusFilterField, minSpellLevel: Int, maxSpellLevel: Int, sourcebookVisibilities: Visibilities<Sourcebook>, casterVisibilities: Visibilities<CasterClass>, schoolVisibilities: Visibilities<School>, castingTimeTypeVisibilities: Visibilities<CastingTimeType>, durationTypeVisibilities: Visibilities<DurationType>, rangeTypeVisibilities: Visibilities<RangeType>, castingTimeRangeInfo: RangeInfo<TimeUnit>, durationRangeInfo: RangeInfo<TimeUnit>, rangeRangeInfo: RangeInfo<LengthUnit>) {
        self.charName = name
        self.spellStatuses = spellStatuses
        self.sortField1 = sortField1
        self.sortField2 = sortField2
        self.reverse1 = reverse1
        self.reverse2 = reverse2
        self.statusFilter = statusFilter
        self.minSpellLevel = minSpellLevel
        self.maxSpellLevel = maxSpellLevel
        self.sourcebookVisibilities = sourcebookVisibilities
        self.casterVisibilities = casterVisibilities
        self.schoolVisibilities = schoolVisibilities
        self.castingTimeTypeVisibilities = castingTimeTypeVisibilities
        self.durationTypeVisibilities = durationTypeVisibilities
        self.rangeTypeVisibilities = rangeTypeVisibilities
        self.castingTimeRangeInfo = castingTimeRangeInfo
        self.durationRangeInfo = durationRangeInfo
        self.rangeRangeInfo = rangeRangeInfo
    }
    
    convenience init(name: String, spellStatuses: [String:SpellStatus]) {
        self.init(name: name, spellStatuses: spellStatuses, sortField1: SortField.Name, sortField2: SortField.Name, reverse1: false, reverse2: false, statusFilter: StatusFilterField.All, minSpellLevel: Spellbook.MIN_SPELL_LEVEL, maxSpellLevel: Spellbook.MAX_SPELL_LEVEL, sourcebookVisibilities: CharacterProfile.defaultSourcebookVisibilities, casterVisibilities: CharacterProfile.defaultCasterVisibilities, schoolVisibilities: CharacterProfile.defaultSchoolVisibilities, castingTimeTypeVisibilities: CharacterProfile.defaultCastingTimeTypeVisibilities, durationTypeVisibilities: CharacterProfile.defaultDurationTypeVisibilities, rangeTypeVisibilities: CharacterProfile.defaultRangeTypeVisibilities, castingTimeRangeInfo: CharacterProfile.defaultCastingTimeRangeInfo, durationRangeInfo: CharacterProfile.defaultDurationRangeInfo, rangeRangeInfo: CharacterProfile.defaultRangeRangeInfo)
    }
    
    convenience init(name: String) {
        self.init(name: name, spellStatuses: [:])
    }
    
    convenience init() {
        self.init(name: "")
    }
    
    init(sion: SION) {
        
        //print(sion.toJSON())
        
        spellStatuses = [:]
        charName = sion[CharacterProfile.charNameKey].string!
        for (_, v) in sion[CharacterProfile.spellsKey] {
            let spellName: String = v[CharacterProfile.spellNameKey].string!
            let fav = v[CharacterProfile.favoriteKey].bool!
            let prep = v[CharacterProfile.preparedKey].bool!
            let known = v[CharacterProfile.knownKey].bool!
            let status = SpellStatus(favIn: fav, prepIn: prep, knownIn: known)
            spellStatuses[spellName] = status
        }
        
        // The sorting fields
        let sortStr1: String = sion[CharacterProfile.sort1Key].string ?? SortField.Name.displayName
        let sortStr2: String = sion[CharacterProfile.sort2Key].string ?? SortField.Name.displayName
        sortField1 = SortField.fromName(sortStr1)
        sortField2 = SortField.fromName(sortStr2)
        
        // Visibilities for various quantities
        sourcebookVisibilities = CharacterProfile.mapFromHiddenNames(type: Sourcebook.self, nonTrivialFilter: true, sion: sion, key: CharacterProfile.hiddenSourcebooksKey)
        casterVisibilities = CharacterProfile.mapFromHiddenNames(type: CasterClass.self, nonTrivialFilter: false, sion: sion, key: CharacterProfile.hiddenCastersKey)
        schoolVisibilities = CharacterProfile.mapFromHiddenNames(type: School.self, nonTrivialFilter: false, sion: sion, key: CharacterProfile.hiddenSchoolsKey)
        castingTimeTypeVisibilities = CharacterProfile.mapFromHiddenNames(type: CastingTimeType.self, nonTrivialFilter: false, sion: sion, key: CharacterProfile.hiddenCastingTimeTypesKey)
        durationTypeVisibilities = CharacterProfile.mapFromHiddenNames(type: DurationType.self, nonTrivialFilter: false, sion: sion, key: CharacterProfile.hiddenDurationTypesKey)
        rangeTypeVisibilities = CharacterProfile.mapFromHiddenNames(type: RangeType.self, nonTrivialFilter: false, sion: sion, key: CharacterProfile.hiddenRangeTypesKey)
        
        // Quantity range information
        castingTimeRangeInfo = CharacterProfile.rangeInfoFromSION(sion: sion, key: CharacterProfile.castingTimeRangeKey, rangeType: CastingTimeType.self, unitType: TimeUnit.self)
        durationRangeInfo = CharacterProfile.rangeInfoFromSION(sion: sion, key: CharacterProfile.durationRangeKey, rangeType: DurationType.self, unitType: TimeUnit.self)
        rangeRangeInfo = CharacterProfile.rangeInfoFromSION(sion: sion, key: CharacterProfile.rangeRangeKey, rangeType: RangeType.self, unitType: LengthUnit.self)
        
        // The sorting directions
        reverse1 = sion[CharacterProfile.reverse1Key].bool ?? false
        reverse2 = sion[CharacterProfile.reverse2Key].bool ?? false
        
        // The status filter
        let filterStr = sion[CharacterProfile.statusFilterKey].string ?? StatusFilterField.All.name()
        statusFilter = StatusFilterField.fromName(filterStr)!
        
        // Min and max spell levels
        minSpellLevel = sion[CharacterProfile.minSpellLevelKey].int ?? Spellbook.MIN_SPELL_LEVEL
        maxSpellLevel = sion[CharacterProfile.maxSpellLevelKey].int ?? Spellbook.MAX_SPELL_LEVEL
        
    }
    
    // To SION
    func asSION() -> SION {
        
        // Create the SION document
        var sion = SION([:])
        
        // Set the character name
        sion[SION(CharacterProfile.charNameKey)] = SION(charName)
        
        // Set the spell statuses
        var spellsSION = SION([])
        var idx: Int = 0
        for (spellName, status) in spellStatuses {
            var statusSION = SION([:])
            statusSION[CharacterProfile.spellNameKey] = SION(spellName)
            statusSION[CharacterProfile.favoriteKey] = SION(status.favorite)
            statusSION[CharacterProfile.preparedKey] = SION(status.prepared)
            statusSION[CharacterProfile.knownKey] = SION(status.known)
            spellsSION[idx] = statusSION
            idx += 1
        }
        sion[SION(CharacterProfile.spellsKey)] = spellsSION
        
        // Set the sort fields and whether or not to reverse directions
        sion[CharacterProfile.sort1Key] = SION(sortField1.displayName)
        sion[CharacterProfile.sort2Key] = SION(sortField2.displayName)
        sion[CharacterProfile.reverse1Key] = SION(reverse1)
        sion[CharacterProfile.reverse2Key] = SION(reverse2)
        
        // Which spell list is selected (All, Favorites, Prepared, Known)
        sion[CharacterProfile.statusFilterKey] = SION(statusFilter.name())
        
        // Min and max spell levels
        sion[CharacterProfile.minSpellLevelKey] = SION(minSpellLevel)
        sion[CharacterProfile.maxSpellLevelKey] = SION(maxSpellLevel)
        
        // Put in the arrays of hidden enums
        sion[CharacterProfile.hiddenSourcebooksKey] = stringArrayToSION(getVisibleValueNames(type: Sourcebook.self, b: false))
        sion[CharacterProfile.hiddenCastersKey] = stringArrayToSION(getVisibleValueNames(type: CasterClass.self, b: false))
        sion[CharacterProfile.hiddenSchoolsKey] = stringArrayToSION(getVisibleValueNames(type: School.self, b: false))
        sion[CharacterProfile.hiddenCastingTimeTypesKey] = stringArrayToSION(getVisibleValueNames(type: CastingTimeType.self, b: false))
        sion[CharacterProfile.hiddenDurationTypesKey] = stringArrayToSION(getVisibleValueNames(type: DurationType.self, b: false))
        sion[CharacterProfile.hiddenRangeTypesKey] = stringArrayToSION(getVisibleValueNames(type: RangeType.self, b: false))
        
        // Put in the range filters
        sion[CharacterProfile.castingTimeRangeKey] = rangeInfoToSION(castingTimeRangeInfo)
        sion[CharacterProfile.durationRangeKey] = rangeInfoToSION(durationRangeInfo)
        sion[CharacterProfile.rangeRangeKey] = rangeInfoToSION(rangeRangeInfo)

        // Put in the version code
        sion[CharacterProfile.versionCodeKey] = SION(Constants.VERSION_CODE)
        
        return sion
    }
    
    // As a JSON string
    func asJSONString() -> String {
        return asSION().json
    }
    
    // For converting a RangeInfo<T> to a SION array
    private func rangeInfoToSION<U:Unit>(_ rangeInfo: RangeInfo<U>) -> SION {
        var rangeSION: SION = [:]
        rangeSION[CharacterProfile.rangeFilterKeys[0]] = SION(rangeInfo.minUnit.pluralName())
        rangeSION[CharacterProfile.rangeFilterKeys[1]] = SION(rangeInfo.maxUnit.pluralName())
        rangeSION[CharacterProfile.rangeFilterKeys[2]] = SION(rangeInfo.minValue)
        rangeSION[CharacterProfile.rangeFilterKeys[3]] = SION(rangeInfo.maxValue)
        return rangeSION
    }
    
    // For converting an array of Strings to a SION array
    private func stringArrayToSION(_ stringArray: [String]) -> SION {
        var array: SION = []
        var i: Int = 0
        for name in stringArray {
            array[i] = SION(name)
            i += 1
        }
        return array
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
    func getFirstSortField() -> SortField { return sortField1 }
    func getSecondSortField() -> SortField { return sortField2 }
    func getFirstSortReverse() -> Bool { return reverse1 }
    func getSecondSortReverse() -> Bool { return reverse2 }
    func getMinSpellLevel() -> Int { return minSpellLevel }
    func getMaxSpellLevel() -> Int { return maxSpellLevel }
    
    func favoritesSelected() -> Bool { return (statusFilter == StatusFilterField.Favorites) }
    func preparedSelected() -> Bool { return (statusFilter == StatusFilterField.Prepared) }
    func knownSelected() -> Bool { return (statusFilter == StatusFilterField.Known) }
    
    // Get only the visible values, with the given transformation applied to them
    func getTransformedVisibleValues<E:NameDisplayable, T>(type: E.Type, b: Bool, transform: (E) -> T)-> [T] {
        let visibilityMap = getTypeMap(type)
        if (visibilityMap == nil) { return [] }
        return E.allCases.filter({visibilityMap![$0] == b}).map({transform($0)})
    }
    
    // Get the visible values
    func getVisibleValues<E:NameDisplayable>(type: E.Type, b: Bool) -> [E] {
        return getTransformedVisibleValues(type: type, b: b, transform: { e in return e })
    }
    
    // Get the display names of the visible values
    func getVisibleValueNames<E:NameDisplayable>(type: E.Type, b: Bool) -> [String] {
        return getTransformedVisibleValues(type: type, b: b, transform: { e in return e.displayName })
    }
    
    
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
    
    func setFirstSortField(_ sf: SortField) { sortField1 = sf }
    func setSecondSortField(_ sf: SortField) { sortField2 = sf }
    func setFirstSortReverse(_ r1: Bool) { reverse1 = r1 }
    func setSecondSortReverse(_ r2: Bool) { reverse2 = r2 }
    func setStatusFilter(_ sff: StatusFilterField) { statusFilter = sff }
    func setMinSpellLevel(_ level: Int) { minSpellLevel = level }
    func setMaxSpellLevel(_ level: Int) { maxSpellLevel = level }
    
    // For setting range filter data
    private func setRangeValue<E:QuantityType, U:Unit, V>(_ quantityType: E.Type, _ unitType: U.Type, _ value: V, _ setter: (RangeInfo<U>, V) -> Void) {
        let rangeInfo = getQuantityRangeInfo(E.self, U.self)
        if (rangeInfo == nil) { return }
        setter(rangeInfo!, value)
    }
    
    func setMinValue<E:QuantityType, U:Unit>(quantityType: E.Type, unitType: U.Type, value: Int) {
        setRangeValue(quantityType, unitType, value, { rangeInfo, val in rangeInfo.minValue = val } )
    }
    func setMaxValue<E:QuantityType, U:Unit>(quantityType: E.Type, unitType: U.Type, value: Int) {
        setRangeValue(quantityType, unitType, value, { rangeInfo, val in rangeInfo.maxValue = val } )
    }
    func setMinUnit<E:QuantityType, U:Unit>(quantityType: E.Type, unitType: U.Type, unit: U) {
        setRangeValue(quantityType, unitType, unit, { rangeInfo, val in rangeInfo.minUnit = val } )
    }
    func setMaxUnit<E:QuantityType, U:Unit>(quantityType: E.Type, unitType: U.Type, unit: U) {
        setRangeValue(quantityType, unitType, unit, { rangeInfo, val in rangeInfo.maxUnit = val } )
    }
    
    // Which map to use for a given type
    func getTypeMap<E:CaseIterable & Hashable>(_ t : E.Type) -> Visibilities<E>? {
        let id = ObjectIdentifier(t)
        switch (id) {
        case ObjectIdentifier(Sourcebook.self):
            return sourcebookVisibilities as? Visibilities<E>
        case ObjectIdentifier(CasterClass.self):
            return casterVisibilities as? Visibilities<E>
        case ObjectIdentifier(School.self):
            return schoolVisibilities as? Visibilities<E>
        case ObjectIdentifier(CastingTimeType.self):
            return castingTimeTypeVisibilities as? Visibilities<E>
        case ObjectIdentifier(DurationType.self):
            return durationTypeVisibilities as? Visibilities<E>
        case ObjectIdentifier(RangeType.self):
            return rangeTypeVisibilities as? Visibilities<E>
        default:
            return nil
        }
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
    
    static func getUnitType<E:QuantityType>(_ t : E.Type) -> Any.Type {
        let id = ObjectIdentifier(t)
        switch (id) {
        case ObjectIdentifier(CastingTimeType.self), ObjectIdentifier(DurationType.self):
            return TimeUnit.self
        case ObjectIdentifier(RangeType.self):
            return LengthUnit.self
        default:
            return TimeUnit.self // Should never get here
        }
    }
    
    // Default range info for a given type
    static func getDefaultQuantityRangeInfo<E:NameDisplayable, U:Unit>(_ t : E.Type, _ u : U.Type) -> RangeInfo<U>? {
        let id = ObjectIdentifier(t)
        switch (id) {
        case ObjectIdentifier(CastingTimeType.self):
            return CharacterProfile.defaultCastingTimeRangeInfo as? RangeInfo<U>
        case ObjectIdentifier(DurationType.self):
            return CharacterProfile.defaultDurationRangeInfo as? RangeInfo<U>
        case ObjectIdentifier(RangeType.self):
            return CharacterProfile.defaultRangeRangeInfo as? RangeInfo<U>
        default:
            return nil
        }
    }
    
    // Range info for a given type
    func getQuantityRangeInfo<E:NameDisplayable, U:Unit>(_ t : E.Type, _ u : U.Type) -> RangeInfo<U>? {
        let id = ObjectIdentifier(t)
        switch(id) {
        case ObjectIdentifier(CastingTimeType.self):
            return castingTimeRangeInfo as? RangeInfo<U>
        case ObjectIdentifier(DurationType.self):
            return durationRangeInfo as? RangeInfo<U>
        case ObjectIdentifier(RangeType.self):
            return rangeRangeInfo as? RangeInfo<U>
        default:
            return nil
        }
    }
    
    // Get, set, and toggle the visibility of a certain value
    func getVisibility<E:NameDisplayable>(_ e: E) -> Bool {
        let map = getTypeMap(E.self)
        return map?[e] ?? false
    }
    
    func setVisibility<E:NameDisplayable>(_ e: E, _ b: Bool) {
        let map = getTypeMap(E.self)
        map?[e] = b
    }
    
    func toggleVisibility<E:NameDisplayable>(_ e: E) {
        setVisibility(e, !getVisibility(e))
    }
    
    
    // Whether or not the spanning type is visible
    func getSpanningTypeVisibility<E:QuantityType>(_ type: E.Type) -> Bool {
        return getVisibility(E.spanningType())
    }
    
    // Constructing a map from a list of hidden values
    // Used for JSON decoding
    private static func mapFromHiddenNames<E:NameDisplayable>(type: E.Type, nonTrivialFilter: Bool, sion: SION, key: String) -> Visibilities<E> {
        
        print("The type is \(type)")
        
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
    
    private static func rangeInfoFromSION<T:NameDisplayable, U:Unit>(sion: SION, key: String, rangeType: T.Type, unitType: U.Type) -> RangeInfo<U> {
        
        // Query the appropriate key
        let rangeInfoSION = sion[key].dictionary
        
        // If we don't have the key (more specifically, if its associated value isn't a dictionary), return the default
        let defaultRange = CharacterProfile.getDefaultQuantityRangeInfo(rangeType, unitType)!
        if rangeInfoSION == nil {
            return defaultRange as RangeInfo<U>
        }
        
        // If we do have the key, parse the dictionary
        let minUnitString = rangeInfoSION![SION(CharacterProfile.rangeFilterKeys[0])]!.string ?? defaultRange.minUnit.pluralName()
        let maxUnitString = rangeInfoSION![SION(CharacterProfile.rangeFilterKeys[1])]!.string ?? defaultRange.maxUnit.pluralName()
        let minUnit = (try? U.fromString(minUnitString)) ?? defaultRange.minUnit
        let maxUnit = (try? U.fromString(maxUnitString)) ?? defaultRange.maxUnit
        let minValue = rangeInfoSION![SION(CharacterProfile.rangeFilterKeys[2])]!.int ?? defaultRange.minValue
        let maxValue = rangeInfoSION![SION(CharacterProfile.rangeFilterKeys[3])]!.int ?? defaultRange.maxValue
        
        return RangeInfo(minUnit: minUnit, maxUnit: maxUnit, minValue: minValue, maxValue: maxValue)
        
    }
    
    
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
