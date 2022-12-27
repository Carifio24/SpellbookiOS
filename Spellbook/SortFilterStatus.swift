//
//  SortFilterStatus.swift
//  Spellbook
//
//  Created by Mac Pro on 10/5/22.
//  Copyright © 2022 Jonathan Carifio. All rights reserved.
//

import Foundation
import RxRelay
import RxSwift

class SortFilterStatus {
    
    // Keys for loading/saving
    private static let sort1Key = "SortField1";
    private static let sort2Key = "SortField2";
    private static let classFilterKey = "FilterClass";
    private static let reverse1Key = "Reverse1";
    private static let reverse2Key = "Reverse2";
    private static let booksFilterKey = "BookFilters";
    private static let statusFilterKey = "StatusFilter";
    private static let quantityRangesKey = "QuantityRanges";
    private static let ritualKey = "Ritual";
    private static let notRitualKey = "NotRitual";
    private static let concentrationKey = "Concentration";
    private static let notConcentrationKey = "NotConcentration";
    private static let minSpellLevelKey = "MinSpellLevel";
    private static let maxSpellLevelKey = "MaxSpellLevel";
    private static let componentsFiltersKey = "ComponentsFilters";
    private static let notComponentsFiltersKey = "NotComponentsFilters";
    private static let useTCEExpandedListsKey = "UseTCEExpandedLists";
    private static let applyFiltersToSpellListsKey = "ApplyFiltersToSpellLists";
    private static let applyFiltersToSearchKey = "ApplyFiltersToSearch";

    private static let sourcebooksKey = "Sourcebooks";
    private static let schoolsKey = "Schools";
    private static let classesKey = "Classes";
    private static let castingTimeTypesKey = "CastingTimeTypes";
    private static let durationTypesKey = "DurationTypes";
    private static let rangeTypesKey = "RangeTypes";
    private static let castingTimeBoundsKey = "CastingTimeBounds";
    private static let durationBoundsKey = "DurationBounds";
    private static let rangeBoundsKey = "RangeBounds";
    private static let minUnitKey = "MinUnit";
    private static let maxUnitKey = "MaxUnit";
    private static let minValueKey = "MinValue";
    private static let maxValueKey = "MaxValue";
    
    private static let VERBAL_INDEX = 0
    private static let SOMATIC_INDEX = 1
    private static let MATERIAL_INDEX = 2
    
    private var name: String? = nil
    
    var firstSortField = SortField.Name
    var secondSortField = SortField.Name
    var firstSortReverse = false
    var secondSortReverse = false
    
    var statusFilterField = StatusFilterField.All
    
    var minSpellLevel = Spellbook.MIN_SPELL_LEVEL
    var maxSpellLevel = Spellbook.MAX_SPELL_LEVEL
    
    var applyFiltersToLists = false
    var applyFiltersToSearch = false
    var useTashasExpandedLists = false
    
    private var yesRitual = true
    private var noRitual = true
    private var yesConcentration = true
    private var noConcentration = true
    
    private var yesComponents = [true, true, true]
    private var noComponents = [true, true, true]
    
    private var visibleSources = Sourcebook.coreSourcebooks
    private var visibleClasses = CasterClass.allCases
    private var visibleSchools = School.allCases
    
    private var visibleCastingTimeTypes = CastingTimeType.allCases
    var minCastingTimeValue = 0
    var maxCastingTimeValue = 24
    var minCastingTimeUnit = TimeUnit.second
    var maxCastingTimeUnit = TimeUnit.hour
    
    private var visibleDurationTypes = DurationType.allCases
    var minDurationValue = 0
    var maxDurationValue = 30
    var minDurationUnit = TimeUnit.second
    var maxDurationUnit = TimeUnit.day
    
    private var visibleRangeTypes = RangeType.allCases
    var minRangeValue = 0
    var maxRangeValue = 1
    var minRangeUnit = LengthUnit.foot
    var maxRangeUnit = LengthUnit.mile
    
    private let disposeBag = DisposeBag()
    private let visibilityFlag = BehaviorRelay(value: ())
    let sortFlag = BehaviorRelay(value: ())
    let filterFlag = BehaviorRelay(value: ())
    
    private static func getVisibleValues<T: Equatable>(visible: Bool, visibleValues: [T], allValues: [T]) -> [T] {
        return visible ? visibleValues : complement(items: visibleValues, allItems: allValues)
    }
    
    // Getting visible filter values
    
    private static func getVisibleValues<T: Equatable & CaseIterable & RawRepresentable>(visible: Bool, visibleValues: [T]) -> [T] {
        return visible ? visibleValues : complement(items: visibleValues)
    }
    
    func getVisibleSources(_ visible: Bool) -> [Sourcebook] {
        return SortFilterStatus.getVisibleValues(visible: visible, visibleValues: visibleSources)
    }
    
    func getVisibleSchools(_ visible: Bool) -> [School] {
        return SortFilterStatus.getVisibleValues(visible: visible, visibleValues: visibleSchools)
}
    
    func getVisibleClasses(_ visible: Bool) -> [CasterClass] {
        return SortFilterStatus.getVisibleValues(visible: visible, visibleValues: visibleClasses)
    }
    
    func getVisibleCastingTimeTypes(_ visible: Bool) -> [CastingTimeType] {
        return SortFilterStatus.getVisibleValues(visible: visible, visibleValues: visibleCastingTimeTypes)
    }
    
    func getVisibleDurationTypes(_ visible: Bool) -> [DurationType] {
        return SortFilterStatus.getVisibleValues(visible: visible, visibleValues: visibleDurationTypes)
    }
    
    func getVisibleRangeTypes(_ visible: Bool) -> [RangeType] {
        return SortFilterStatus.getVisibleValues(visible: visible, visibleValues: visibleRangeTypes)
    }
    
    // Component filters
    private func getComponentFilter(_ b: Bool, index: Int) -> Bool {
        return b ? yesComponents[index] : noComponents[index]
    }
    
    func getVerbalFilter(_ b: Bool) -> Bool {
        return getComponentFilter(b, index: SortFilterStatus.VERBAL_INDEX)
    }
    
    func getSomaticFilter(_ b: Bool) -> Bool {
        return getComponentFilter(b, index: SortFilterStatus.SOMATIC_INDEX)
    }
    
    func getMaterialFilter(_ b: Bool) -> Bool {
        return getComponentFilter(b, index: SortFilterStatus.MATERIAL_INDEX)
    }
    
    private func getVisibility<T: Equatable>(item: T, collection: [T]) -> Bool {
        return collection.contains(item)
    }
    
    func getVisibility(_ source: Sourcebook) -> Bool {
        return getVisibility(item: source, collection: visibleSources)
    }
    
    func getVisibility(_ school: School) -> Bool {
        return getVisibility(item: school, collection: visibleSchools)
    }
    
    func getVisibility(_ casterClass: CasterClass) -> Bool {
        return getVisibility(item: casterClass, collection: visibleClasses)
    }
    
    func getVisibility(_ castingTimeType: CastingTimeType) -> Bool {
        return getVisibility(item: castingTimeType, collection: visibleCastingTimeTypes)
    }
    
    func getVisibility(_ durationType: DurationType) -> Bool {
        return getVisibility(item: durationType, collection: visibleDurationTypes)
    }
    
    func getVisibility(_ rangeType: RangeType) -> Bool {
        return getVisibility(item: rangeType, collection: visibleRangeTypes)
    }
    
    func setVisibility<T: Equatable>(item: T, collection: inout [T], value: Bool) {
        if (value) {
            collection.removeAll(where: { $0 == item })
        } else {
            collection.append(item)
        }
        visibilityFlag.accept(())
    }
    
    func setVisibility(_ source: Sourcebook, value: Bool) {
        setVisibility(item: source, collection: &visibleSources, value: value)
    }
    
    func setVisibility(_ school: School, value: Bool) {
        setVisibility(item: school, collection: &visibleSchools, value: value)
    }
    
    func setVisibility(_ casterClass: CasterClass, value: Bool) {
        setVisibility(item: casterClass, collection: &visibleClasses, value: value)
    }
    
    func setVisibility(_ castingTimeType: CastingTimeType, value: Bool) {
        setVisibility(item: castingTimeType, collection: &visibleCastingTimeTypes, value: value)
    }
    
    func setVisibility(_ durationType: DurationType, value: Bool) {
        setVisibility(item: durationType, collection: &visibleDurationTypes, value: value)
    }
    
    func setVisibility(_ rangeType: RangeType, value: Bool) {
        setVisibility(item: rangeType, collection: &visibleRangeTypes, value: value)
    }
    
    func toggleVisibility(_ source: Sourcebook) {
        setVisibility(source, value: !getVisibility(source))
    }
    func toggleVisibility(_ school: School) {
        setVisibility(school, value: !getVisibility(school))
    }
    func toggleVisibility(_ casterClass: CasterClass) {
        setVisibility(casterClass, value: !getVisibility(casterClass))
    }
    func toggleVisibility(_ castingTimeType: CastingTimeType) {
        setVisibility(castingTimeType, value: !getVisibility(castingTimeType))
    }
    func toggleVisibility(_ durationType: DurationType) {
        setVisibility(durationType, value: !getVisibility(durationType))
    }
    func toggleVisibility(_ rangeType: RangeType) {
        setVisibility(rangeType, value: !getVisibility(rangeType))
    }
    
    private func boundsToSION<U: Unit>(minValue: Int, minUnit: U, maxValue: Int, maxUnit: U) -> SION {
        var sion: SION = [:]
        sion[SortFilterStatus.minValueKey].int = minValue
        sion[SortFilterStatus.minUnitKey].string = minUnit.singularName
        sion[SortFilterStatus.maxValueKey].int = maxValue
        sion[SortFilterStatus.maxUnitKey].string = maxUnit.singularName
        return sion
    }
    
    typealias BoundSetter<U> = (Int, U, Int, U) -> Void
    func setCastingTimeBounds(minValue: Int, minUnit:TimeUnit,
                              maxValue: Int, maxUnit: TimeUnit) {
        self.minCastingTimeValue = minValue
        self.minCastingTimeUnit = minUnit
        self.maxCastingTimeValue = maxValue
        self.maxCastingTimeUnit = maxUnit
    }
    func setDurationBounds(minValue: Int, minUnit: TimeUnit,
                           maxValue: Int, maxUnit: TimeUnit) {
        self.minDurationValue = minValue
        self.minDurationUnit = minUnit
        self.maxDurationValue = maxValue
        self.maxDurationUnit = maxUnit
    }
    func setRangeBounds(minValue: Int, minUnit: LengthUnit,
                        maxValue: Int, maxUnit: LengthUnit) {
        self.minRangeValue = minValue
        self.minRangeUnit = minUnit
        self.maxRangeValue = maxValue
        self.maxRangeUnit = maxUnit
    }
    private func setBoundsFromSION<U: Unit>(sion: SION, setter: BoundSetter<U>) {
        let minValue = sion[SortFilterStatus.minValueKey].int ?? 0
        let minUnit = (try? U.fromString(sion[SortFilterStatus.minUnitKey].string!)) ?? U.defaultUnit
        let maxValue = sion[SortFilterStatus.maxValueKey].int ?? 1
        let maxUnit = (try? U.fromString(sion[SortFilterStatus.maxUnitKey].string!)) ?? U.defaultUnit
        setter(minValue, minUnit, maxValue, maxUnit)
    }

    
    func toSION() -> SION {
        var sion: SION = [:]
        
        sion[SortFilterStatus.sort1Key].string = firstSortField.displayName
        sion[SortFilterStatus.sort2Key].string = secondSortField.displayName
        sion[SortFilterStatus.reverse1Key].bool = firstSortReverse
        sion[SortFilterStatus.reverse2Key].bool = secondSortReverse
    
        sion[SortFilterStatus.minSpellLevelKey].int = minSpellLevel
        sion[SortFilterStatus.maxSpellLevelKey].int = maxSpellLevel
        
        sion[SortFilterStatus.applyFiltersToSearchKey].bool = applyFiltersToSearch
        sion[SortFilterStatus.applyFiltersToSpellListsKey].bool = applyFiltersToLists
        sion[SortFilterStatus.useTCEExpandedListsKey].bool = useTashasExpandedLists
        
        sion[SortFilterStatus.ritualKey].bool = yesRitual
        sion[SortFilterStatus.notRitualKey].bool = noRitual
        sion[SortFilterStatus.concentrationKey].bool = yesConcentration
        sion[SortFilterStatus.notConcentrationKey].bool = noConcentration
        
        sion[SortFilterStatus.componentsFiltersKey].array = yesComponents.map { SION($0) }
        sion[SortFilterStatus.notComponentsFiltersKey].array = noComponents.map { SION($0) }
        
        sion[SortFilterStatus.sourcebooksKey].array = visibleSources.map { SION($0.code) }
        sion[SortFilterStatus.classesKey].array = visibleClasses.map { SION($0.displayName) }
        sion[SortFilterStatus.schoolsKey].array = visibleSchools.map { SION($0.displayName) }
        sion[SortFilterStatus.castingTimeTypesKey].array = visibleCastingTimeTypes.map { SION($0.displayName) }
        sion[SortFilterStatus.durationTypesKey].array = visibleDurationTypes.map { SION($0.displayName) }
        sion[SortFilterStatus.rangeTypesKey].array = visibleRangeTypes.map { SION($0.displayName) }
        
        sion[SortFilterStatus.castingTimeBoundsKey] = boundsToSION(minValue: minCastingTimeValue, minUnit: minCastingTimeUnit, maxValue: maxCastingTimeValue, maxUnit: maxCastingTimeUnit)
        sion[SortFilterStatus.durationBoundsKey] = boundsToSION(minValue: minDurationValue, minUnit: minDurationUnit, maxValue: maxDurationValue, maxUnit: maxDurationUnit)
        sion[SortFilterStatus.rangeBoundsKey] = boundsToSION(minValue: minRangeValue, minUnit: minRangeUnit, maxValue: maxRangeValue, maxUnit: maxRangeUnit)
        
        return sion
    }
    
    init(sion: SION) {
        if let name = sion[SortFilterStatus.sort1Key].string {
            firstSortField = SortField.fromName(name)
        } else {
            firstSortField = SortField.Name
        }
        if let name = sion[SortFilterStatus.sort2Key].string {
            secondSortField = SortField.fromName(name)
        } else {
            secondSortField = SortField.Name
        }
        firstSortField = SortField.fromName(sion[SortFilterStatus.sort1Key].string ?? SortField.Name.displayName)
        secondSortField = SortField.fromName(sion[SortFilterStatus.sort2Key].string ?? SortField.Name.displayName)
        firstSortReverse = sion[SortFilterStatus.reverse1Key].bool ?? false
        secondSortReverse = sion[SortFilterStatus.reverse2Key].bool ?? false
        
        minSpellLevel = intFromSION(sion[SortFilterStatus.minSpellLevelKey], defaultValue: Spellbook.MIN_SPELL_LEVEL)
        maxSpellLevel = intFromSION(sion[SortFilterStatus.maxSpellLevelKey], defaultValue: Spellbook.MAX_SPELL_LEVEL)
        
        applyFiltersToSearch = sion[SortFilterStatus.applyFiltersToSearchKey].bool ?? false
        applyFiltersToLists = sion[SortFilterStatus.applyFiltersToSpellListsKey].bool ?? false
        useTashasExpandedLists = sion[SortFilterStatus.useTCEExpandedListsKey].bool ?? false
        
        yesRitual = sion[SortFilterStatus.ritualKey].bool ?? true
        noRitual = sion[SortFilterStatus.notRitualKey].bool ?? true
        yesConcentration = sion[SortFilterStatus.concentrationKey].bool ?? true
        noConcentration = sion[SortFilterStatus.notConcentrationKey].bool ?? true
        
        yesComponents = sion[SortFilterStatus.componentsFiltersKey].array?.map{ $0.bool ?? true } ?? [true, true, true]
        noComponents = sion[SortFilterStatus.notComponentsFiltersKey].array?.map{ $0.bool ?? true } ?? [true, true, true]
        
        let sourcebookArray = sion[SortFilterStatus.sourcebooksKey]
        visibleSources = arrayFromSION(sion: sourcebookArray, creator: { Sourcebook.fromCode($0.string) }, defaultArray: Sourcebook.allCases)
        
        let casterArray = sion[SortFilterStatus.classesKey]
        visibleClasses = arrayFromSION(sion: casterArray, creator: { CasterClass.fromName($0.string!) }, defaultArray: CasterClass.allCases)
        
        let schoolArray = sion[SortFilterStatus.schoolsKey]
        visibleSchools = arrayFromSION(sion: schoolArray, creator: { School.fromName($0.string!) }, defaultArray: School.allCases)
        
        let cttArray = sion[SortFilterStatus.castingTimeTypesKey]
        visibleCastingTimeTypes = arrayFromSION(sion: cttArray, creator: { CastingTimeType.fromName($0.string!) }, defaultArray: CastingTimeType.allCases)
        
        let dtArray = sion[SortFilterStatus.durationTypesKey]
        visibleDurationTypes = arrayFromSION(sion: dtArray, creator: { DurationType.fromName($0.string!) }, defaultArray: DurationType.allCases)
        
        let rtArray = sion[SortFilterStatus.rangeTypesKey]
        visibleRangeTypes = arrayFromSION(sion: rtArray, creator: { RangeType.fromName($0.string!) }, defaultArray: RangeType.allCases)
        
        setBoundsFromSION(sion: sion[SortFilterStatus.castingTimeBoundsKey], setter: self.setCastingTimeBounds)
        setBoundsFromSION(sion: sion[SortFilterStatus.durationTypesKey], setter: self.setDurationBounds)
        setBoundsFromSION(sion: sion[SortFilterStatus.rangeTypesKey], setter: self.setRangeBounds)
        
    }
}
