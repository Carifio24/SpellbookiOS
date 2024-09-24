//
//  SpellFilter.swift
//  Spellbook
//
//  Created by Mac Pro on 1/21/23.
//  Copyright © 2023 Jonathan Carifio. All rights reserved.
//

import Foundation

// Filters
let sourcebookFilter: SpellFilter<Sourcebook> = { $0.isIn(sourcebook: $1) }
let casterClassesFilter: SpellFilter<CasterClass> = { $0.usableByClass($1) }
let schoolFilter: SpellFilter<School> = { $0.school == $1 }
let castingTimeTypeFilter: SpellFilter<CastingTimeType> = { $0.castingTime.type == $1 }
let durationTypeFilter: SpellFilter<DurationType> = { $0.duration.type == $1 }
let rangeTypeFilter: SpellFilter<RangeType> = { $0.range.type == $1 }

internal func filterThroughArray<E:CaseIterable>(spell: Spell, values: [E], filter: (Spell,E) -> Bool) -> Bool {
    for e in values {
        if filter(spell, e) {
            return false
        }
    }
    return true
}

internal func filterAgainstBounds<Q:Comparable,U:Unit>(spell s: Spell, bounds: (Quantity<Q,U>,Quantity<Q,U>)?, quantityGetter: (Spell) -> Quantity<Q,U>) -> Bool {
    
    // If the bounds are nil, this check should be skipped
    if (bounds == nil) { return false }
    
    // Get the quantity
    // If it isn't of the spanning type, return false
    let quantity = quantityGetter(s)
    if quantity.isTypeSpanning() {
        return ( (quantity < bounds!.0) || (quantity > bounds!.1) )
    } else {
        return false
    }
    
}

// Determine whether or not a single row should be filtered
func filterSpell(spell: Spell, sortFilterStatus: SortFilterStatus, spellFilterStatus: SpellFilterStatus, visibleSources: [Sourcebook], visibleClasses: [CasterClass], visibleSchools: [School], visibleCastingTimeTypes: [CastingTimeType], visibleDurationTypes: [DurationType], visibleRangeTypes: [RangeType], castingTimeBounds: (CastingTime,CastingTime), durationBounds: (Duration,Duration), rangeBounds: (Range,Range), isText: Bool, text: String) -> Bool {
    let spellName = spell.name.lowercased()
    let searchText = text.lowercased()
    
    // If we aren't going to filter when searching, and there's search text,
    // we only need to check whether the spell name contains the search text
    if (!sortFilterStatus.applyFiltersToSearch && isText) {
        return spellName.contains(searchText);
    }

    // If we aren't going to filter spell lists, and the current filter isn't ALL
    // just check if the spell is on the list
    // (and that it respects any search text)
    if (!sortFilterStatus.applyFiltersToLists && sortFilterStatus.isStatusSet()) {
        var hide = spellFilterStatus.hiddenByFilter(spell: spell, filterField: sortFilterStatus.statusFilterField);
        if (isText) {
            hide = hide || !spellName.contains(searchText);
        }
        return !hide;
    }
    
    // Run through the various filtering fields
    
    // Level
    let level = spell.level
    if (level > sortFilterStatus.maxSpellLevel) || (level < sortFilterStatus.minSpellLevel) { return false }
    
    // Sourcebooks
    if filterThroughArray(spell: spell, values: visibleSources, filter: sourcebookFilter) { return false }
    
    // Classes
    if filterThroughArray(spell: spell, values: visibleClasses, filter: casterClassesFilter) { return false }
    
    // Schools
    if filterThroughArray(spell: spell, values: visibleSchools, filter: schoolFilter) { return false }
    
    // Casting time types
    if filterThroughArray(spell: spell, values: visibleCastingTimeTypes, filter: castingTimeTypeFilter) { return false }
    
    // Duration types
    if filterThroughArray(spell: spell, values: visibleDurationTypes, filter: durationTypeFilter) { return false }
    
    // Range types
    if filterThroughArray(spell: spell, values: visibleRangeTypes, filter: rangeTypeFilter) { return false }
    
    // Casting time bounds
    if filterAgainstBounds(spell: spell, bounds: castingTimeBounds, quantityGetter: { $0.castingTime }) { return false }
    
    // Duration bounds
    if filterAgainstBounds(spell: spell, bounds: durationBounds, quantityGetter: { $0.duration }) { return false }
    
    // Range bounds
    if filterAgainstBounds(spell: spell, bounds: rangeBounds, quantityGetter: { $0.range }) { return false }
    
    // The rest of the filtering conditions
    var toHide = (sortFilterStatus.favoritesSelected() && !spellFilterStatus.isFavorite(spell))
    toHide = toHide || (sortFilterStatus.knownSelected() && !spellFilterStatus.isKnown(spell))
    toHide = toHide || (sortFilterStatus.preparedSelected() && !spellFilterStatus.isPrepared(spell))
    toHide = toHide || !sortFilterStatus.getRitualFilter(spell.ritual)
    toHide = toHide || !sortFilterStatus.getConcentrationFilter(spell.concentration)
    toHide = toHide || !sortFilterStatus.getVerbalFilter(spell.verbal)
    toHide = toHide || !sortFilterStatus.getSomaticFilter(spell.somatic)
    toHide = toHide || !sortFilterStatus.getMaterialFilter(spell.material)
    toHide = toHide || !sortFilterStatus.getRoyaltyFilter(spell.royalty)
    toHide = toHide || (isText && !spellName.contains(text))
    return !toHide
}

func createFilter(state: SpellbookAppState) -> (Spell) -> Bool {
    
    // Testing
    //print("Favorites selected: \(main?.characterProfile.favoritesSelected())")
    //print("Known selected: \(main?.characterProfile.knownSelected())")
    //print("Prepared selected: \(main?.characterProfile.preparedSelected())")
    
    // First, we filter the data
    let searchText = state.searchQuery ?? ""
    let isText = !searchText.isEmpty
    
    guard let cp = state.profile else {
        return { spell in return false }
    }
    let sortFilterStatus = cp.sortFilterStatus
    let spellFilterStatus = cp.spellFilterStatus
    let visibleSources = sortFilterStatus.getVisibleSources(true)
    let visibleClasses = sortFilterStatus.getVisibleClasses(true)
    let visibleSchools = sortFilterStatus.getVisibleSchools(true)
    let visibleCastingTimeTypes = sortFilterStatus.getVisibleCastingTimeTypes(true)
    let visibleDurationTypes = sortFilterStatus.getVisibleDurationTypes(true)
    let visibleRangeTypes = sortFilterStatus.getVisibleRangeTypes(true)
    let castingTimeBounds = (sortFilterStatus.minCastingTime, sortFilterStatus.maxCastingTime)
    let durationBounds = (sortFilterStatus.minDuration, sortFilterStatus.maxDuration)
    let rangeBounds = (sortFilterStatus.minRange, sortFilterStatus.maxRange)
    
    return { spell in return filterSpell(spell: spell, sortFilterStatus: sortFilterStatus, spellFilterStatus: spellFilterStatus, visibleSources: visibleSources, visibleClasses: visibleClasses, visibleSchools: visibleSchools, visibleCastingTimeTypes: visibleCastingTimeTypes, visibleDurationTypes: visibleDurationTypes, visibleRangeTypes: visibleRangeTypes, castingTimeBounds: castingTimeBounds, durationBounds: durationBounds, rangeBounds: rangeBounds, isText: isText, text: searchText) }
    
}

func filteredSpellList(state: SpellbookAppState) -> [Spell] {

    let spellList = SpellbookAppState.allSpells
    var keptIDs = Set<Int>()
    var filteredSpellList: [Spell] = []
    let filter = createFilter(state: state)
    let hideDuplicates = state.profile?.sortFilterStatus.hideDuplicateSpells ?? true

    //
    for spell in spellList {
        if !filter(spell) {
            filteredSpellList.append(spell)
            if hideDuplicates {
                keptIDs.insert(spell.id)
            }
        }
    }

    // I'd rather avoid a second pass, but since linked spells won't necessarily
    // have the same data, we can't generally know whether we need to filter a spell
    // as a duplicate on the first pass
    if hideDuplicates {
        let prefer2024Spells = state.profile?.sortFilterStatus.prefer2024Spells ?? true
        let rulesetToIgnore = prefer2024Spells ? Ruleset.Rules2014 : Ruleset.Rules2024
        let duplicatesFilter = { (spell: Spell) in
            if spell.ruleset == rulesetToIgnore {
                return false
            }
            guard let linkedID = Spellbook.linkedSpellID(for: spell) else { return false }
            return !keptIDs.contains(linkedID)
        }
        filteredSpellList = filteredSpellList.filter(duplicatesFilter)
    }

    return filteredSpellList
}
