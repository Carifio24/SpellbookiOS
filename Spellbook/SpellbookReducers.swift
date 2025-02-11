//
//  SpellbookReducers.swift
//  Spellbook
//
//  Created by Mac Pro on 12/7/22.
//  Copyright © 2022 Jonathan Carifio. All rights reserved.
//

import ReSwift

func identityReducer(action: Action, state: SpellbookAppState) -> SpellbookAppState {
    return state
}

func sortFieldReducer(action: SortFieldAction, state: inout SpellbookAppState) -> SpellbookAppState {
    guard let status = state.profile?.sortFilterStatus else { return state }
    if (action.level == 1) {
        status.firstSortField = action.sortField
    } else if (action.level == 2) {
        status.secondSortField = action.sortField
    }
    state.sortSpells()
    return state
}

func sortReverseReducer(action: SortReverseAction, state: inout SpellbookAppState) -> SpellbookAppState {
    guard let status = state.profile?.sortFilterStatus else { return state }
    if (action.level == 1) {
        status.firstSortReverse = action.reverse
    } else if (action.level == 2) {
        status.secondSortReverse = action.reverse
    }
    state.sortSpells()
    return state
}

func statusFilterReducer(action: StatusFilterAction, state: inout SpellbookAppState) -> SpellbookAppState {
    guard let status = state.profile?.sortFilterStatus else { return state }
    status.statusFilterField = action.statusFilterField
    state.filterAndSortSpells()
    return state
}

func spellLevelReducer(action: SpellLevelAction, state: inout SpellbookAppState) -> SpellbookAppState {
    guard let status = state.profile?.sortFilterStatus else { return state }
    if (action.bound == .Min) {
        status.minSpellLevel = action.level
    } else {
        status.maxSpellLevel = action.level
    }
    state.filterAndSortSpells()
    return state
}

typealias VisibilitySetter<T:NameConstructible> = (SortFilterStatus) -> (T, Bool) -> ()
fileprivate func filterItemReducer<T:NameConstructible>(
    action: FilterItemAction<T>,
    state: inout SpellbookAppState,
    visibilitySetter: VisibilitySetter<T>
) -> SpellbookAppState {
    guard let status = store.state.profile?.sortFilterStatus else { return state }
    visibilitySetter(status)(action.item, action.visible)
    state.filterAndSortSpells()
    return state
}
func filterSchoolReducer(action: FilterItemAction<School>, state: inout SpellbookAppState) -> SpellbookAppState {
    return filterItemReducer(action: action, state: &state, visibilitySetter: SortFilterStatus.setSchoolVisibility)
}
func filterSourceReducer(action: FilterItemAction<Sourcebook>, state: inout SpellbookAppState) -> SpellbookAppState {
    return filterItemReducer(action: action, state: &state, visibilitySetter: SortFilterStatus.setSourceVisibility)
}
func filterClassReducer(action: FilterItemAction<CasterClass>, state: inout SpellbookAppState) -> SpellbookAppState {
    return filterItemReducer(action: action, state: &state, visibilitySetter: SortFilterStatus.setClassVisibility)
}
func filterCastingTimeTypeReducer(action: FilterItemAction<CastingTimeType>, state: inout SpellbookAppState) -> SpellbookAppState {
    return filterItemReducer(action: action, state: &state, visibilitySetter: SortFilterStatus.setCastingTimeTypeVisibility)
}
func filterDurationTypeReducer(action: FilterItemAction<DurationType>, state: inout SpellbookAppState) -> SpellbookAppState {
    return filterItemReducer(action: action, state: &state, visibilitySetter: SortFilterStatus.setDurationTypeVisibility)
}
func filterRangeTypeReducer(action: FilterItemAction<RangeType>, state: inout SpellbookAppState) -> SpellbookAppState {
    return filterItemReducer(action: action, state: &state, visibilitySetter: SortFilterStatus.setRangeTypeVisibility)
}

fileprivate func filterAllButReducer<T:NameConstructible>(
    action: FilterAllButAction<T>,
    state: inout SpellbookAppState,
    visibilitySetter: VisibilitySetter<T>
) -> SpellbookAppState {
    guard let status = store.state.profile?.sortFilterStatus else { return state }
    for item in T.allCases {
        if (item != action.item) {
            visibilitySetter(status)(item, action.visible)
        }
    }
    state.filterAndSortSpells()
    return state
}

func filterAllSchoolsButReducer(action: FilterAllButAction<School>, state: inout SpellbookAppState) -> SpellbookAppState {
    return filterAllButReducer(action: action, state: &state, visibilitySetter: SortFilterStatus.setSchoolVisibility)
}

func filterAllSourcesButReducer(action: FilterAllButAction<Sourcebook>, state: inout SpellbookAppState) -> SpellbookAppState {
    return filterAllButReducer(action: action, state: &state, visibilitySetter: SortFilterStatus.setSourceVisibility)
}

func filterAllClassesButReducer(action: FilterAllButAction<CasterClass>, state: inout SpellbookAppState) -> SpellbookAppState {
    return filterAllButReducer(action: action, state: &state, visibilitySetter: SortFilterStatus.setClassVisibility)
}

func filterAllCastingTimeTypesButReducer(action: FilterAllButAction<CastingTimeType>, state: inout SpellbookAppState) -> SpellbookAppState {
    return filterAllButReducer(action: action, state: &state, visibilitySetter: SortFilterStatus.setCastingTimeTypeVisibility)
}

func filterAllDurationTypesButReducer(action: FilterAllButAction<DurationType>, state: inout SpellbookAppState) -> SpellbookAppState {
    return filterAllButReducer(action: action, state: &state, visibilitySetter: SortFilterStatus.setDurationTypeVisibility)
}

func filterAllRangeTypesButReducer(action: FilterAllButAction<RangeType>, state: inout SpellbookAppState) -> SpellbookAppState {
    return filterAllButReducer(action: action, state: &state, visibilitySetter: SortFilterStatus.setRangeTypeVisibility)
}

typealias VisibilityToggler<T:NameConstructible> = (SortFilterStatus) -> (T) -> ()
fileprivate func toggleItemReducer<T:NameConstructible>(
    action: ToggleItemAction<T>,
    state: inout SpellbookAppState,
    visibilityToggler: VisibilityToggler<T>
) -> SpellbookAppState {
    guard let status = store.state.profile?.sortFilterStatus else { return state }
    visibilityToggler(status)(action.item)
    state.filterAndSortSpells()
    return state
}
func toggleSchoolReducer(action: ToggleItemAction<School>, state: inout SpellbookAppState) -> SpellbookAppState {
    return toggleItemReducer(action: action, state: &state, visibilityToggler: SortFilterStatus.toggleSchoolVisibility)
}
func toggleSourceReducer(action: ToggleItemAction<Sourcebook>, state: inout SpellbookAppState) -> SpellbookAppState {
    return toggleItemReducer(action: action, state: &state, visibilityToggler: SortFilterStatus.toggleSourceVisibility)
}
func toggleClassReducer(action: ToggleItemAction<CasterClass>, state: inout SpellbookAppState) -> SpellbookAppState {
    return toggleItemReducer(action: action, state: &state, visibilityToggler: SortFilterStatus.toggleClassVisibility)
}
func toggleCastingTimeTypeReducer(action: ToggleItemAction<CastingTimeType>, state: inout SpellbookAppState) -> SpellbookAppState {
    return toggleItemReducer(action: action, state: &state, visibilityToggler: SortFilterStatus.toggleCastingTimeTypeVisibility)
}
func toggleDurationTypeReducer(action: ToggleItemAction<DurationType>, state: inout SpellbookAppState) -> SpellbookAppState {
    return toggleItemReducer(action: action, state: &state, visibilityToggler: SortFilterStatus.toggleDurationTypeVisibility)
}
func toggleRangeTypeReducer(action: ToggleItemAction<RangeType>, state: inout SpellbookAppState) -> SpellbookAppState {
    return toggleItemReducer(action: action, state: &state, visibilityToggler: SortFilterStatus.toggleRangeTypeVisibility)
}

func filterAllReducer<T:NameConstructible & CaseIterable>(setter: (SortFilterStatus) -> (T, Bool) -> Void, action: FilterAllAction<T>, state: inout SpellbookAppState) -> SpellbookAppState {
    guard let status = state.profile?.sortFilterStatus else { return state }
    T.allCases.forEach({item in setter(status)(item, action.visible)})
    state.filterAndSortSpells()
    return state
}

func filterAllSchoolsReducer(action: FilterAllSchoolsAction, state: inout SpellbookAppState) -> SpellbookAppState {
    return filterAllReducer(setter: SortFilterStatus.setSchoolVisibility, action: action, state: &state)
}

func filterAllClassesReducer(action: FilterAllClassesAction, state: inout SpellbookAppState) -> SpellbookAppState {
    return filterAllReducer(setter: SortFilterStatus.setClassVisibility, action: action, state: &state)
}

func filterAllSourcesReducer(action: FilterAllSourcesAction, state: inout SpellbookAppState) -> SpellbookAppState {
    return filterAllReducer(setter: SortFilterStatus.setSourceVisibility, action: action, state: &state)
}

func filterAllCastingTimeTypesReducer(action: FilterAllCastingTimeTypesAction, state: inout SpellbookAppState) -> SpellbookAppState {
    return filterAllReducer(setter: SortFilterStatus.setCastingTimeTypeVisibility, action: action, state: &state)
}

func filterAllDurationTypesReducer(action: FilterAllDurationTypesAction, state: inout SpellbookAppState) -> SpellbookAppState {
    return filterAllReducer(setter: SortFilterStatus.setDurationTypeVisibility, action: action, state: &state)
}

func filterAllRangeTypesReducer(action: FilterAllRangeTypesAction, state: inout SpellbookAppState) -> SpellbookAppState {
    return filterAllReducer(setter: SortFilterStatus.setRangeTypeVisibility, action: action, state: &state)
}


func sortNeededReducer(action: SortNeededAction, state: inout SpellbookAppState) -> SpellbookAppState {
    state.sortSpells()
    return state
}

func filterNeededReducer(action: FilterNeededAction, state: inout SpellbookAppState) -> SpellbookAppState {
    state.filterAndSortSpells()
    return state
}


typealias ValueSetter = (SortFilterStatus) -> (Int) -> Void
fileprivate func valueUpdateReducer<T:QuantityType,U:Unit>(action: ValueUpdateAction<T,U>, state: inout SpellbookAppState, minSetter: ValueSetter, maxSetter: ValueSetter) -> SpellbookAppState {
    guard let profile = state.profile else { return state }
    let status = profile.sortFilterStatus
    if (action.bound == .Min) {
        minSetter(status)(action.value)
    } else {
        maxSetter(status)(action.value)
    }
    state.filterAndSortSpells()
    return state
}
func rangeValueUpdateReducer(action: RangeValueUpdateAction, state: inout SpellbookAppState) -> SpellbookAppState {
    return valueUpdateReducer(action: action, state: &state, minSetter: SortFilterStatus.setMinRangeValue, maxSetter: SortFilterStatus.setMaxRangeValue)
}
func durationValueUpdateReducer(action: DurationValueUpdateAction, state: inout SpellbookAppState) -> SpellbookAppState {
    return valueUpdateReducer(action: action, state: &state, minSetter: SortFilterStatus.setMinDurationValue, maxSetter: SortFilterStatus.setMaxDurationValue)
}
func castingTimeValueUpdateReducer(action: CastingTimeValueUpdateAction, state: inout SpellbookAppState) -> SpellbookAppState {
    return valueUpdateReducer(action: action, state: &state, minSetter: SortFilterStatus.setMinCastingTimeValue, maxSetter: SortFilterStatus.setMaxCastingTimeValue)
}


typealias UnitSetter<U:Unit> = (SortFilterStatus) ->  (U) -> Void
fileprivate func unitUpdateReducer<T:QuantityType,U:Unit>(action: UnitUpdateAction<T,U>, state: inout SpellbookAppState, minSetter: UnitSetter<U>, maxSetter: UnitSetter<U>) -> SpellbookAppState {
    guard let status = state.profile?.sortFilterStatus else { return state }
    if (action.bound == .Min) {
        minSetter(status)(action.unit)
    } else {
        maxSetter(status)(action.unit)
    }
    state.filterAndSortSpells()
    return state
}
func rangeUnitUpdateReducer(action: RangeUnitUpdateAction, state: inout SpellbookAppState) -> SpellbookAppState {
    return unitUpdateReducer(action: action, state: &state, minSetter: SortFilterStatus.setMinRangeUnit, maxSetter: SortFilterStatus.setMaxRangeUnit)
}
func durationUnitUpdateReducer(action: DurationUnitUpdateAction, state: inout SpellbookAppState) -> SpellbookAppState {
    return unitUpdateReducer(action: action, state: &state, minSetter: SortFilterStatus.setMinDurationUnit, maxSetter: SortFilterStatus.setMaxDurationUnit)
}
func castingTimeUnitUpdateReducer(action: CastingTimeUnitUpdateAction, state: inout SpellbookAppState) -> SpellbookAppState {
    return unitUpdateReducer(action: action, state: &state, minSetter: SortFilterStatus.setMinCastingTimeUnit, maxSetter: SortFilterStatus.setMaxCastingTimeUnit)
}

func defaultRangeReducer<T: QuantityType, U: Unit, Q: Quantity<T,U>>(action: QuantityRangeDefaultAction<T,U,Q>, state: inout SpellbookAppState, type: Q.Type) -> SpellbookAppState {
    guard let status = state.profile?.sortFilterStatus else { return state }
    status.setBoundsToDefault(type)
    state.filterAndSortSpells()
    return state
}
func defaultCastingTimeRangeReducer(action: CastingTimeDefaultAction, state: inout SpellbookAppState) -> SpellbookAppState {
    return defaultRangeReducer(action: action, state: &state, type: CastingTime.self)
}
func defaultDurationRangeReducer(action: DurationDefaultAction, state: inout SpellbookAppState) -> SpellbookAppState {
    return defaultRangeReducer(action: action, state: &state, type: Duration.self)
}
func defaultRangeRangeReducer(action: RangeDefaultAction, state: inout SpellbookAppState) -> SpellbookAppState {
    return defaultRangeReducer(action: action, state: &state, type: Range.self)
}

func setFlagFilterReducer(action: SetFlagAction, state: inout SpellbookAppState) -> SpellbookAppState {
    guard let status = state.profile?.sortFilterStatus else { return state }
    switch (action.flag) {
        case .Ritual:
            status.setRitualFilter(action.tf, to: action.value)
            break
        case .Concentration:
            status.setConcentrationFilter(action.tf, to: action.value)
            break
        case .Verbal:
            status.setVerbalFilter(action.tf, to: action.value)
            break
        case .Somatic:
            status.setSomaticFilter(action.tf, to: action.value)
            break
        case .Material:
            status.setMaterialFilter(action.tf, to: action.value)
            break
        case .Royalty:
            status.setRoyaltyFilter(action.tf, to: action.value)
            break
    }
    state.filterAndSortSpells()
    return state
}


func toggleFlagFilterReducer(action: ToggleFlagAction, state: inout SpellbookAppState) -> SpellbookAppState {
    guard let status = state.profile?.sortFilterStatus else { return state }
    switch (action.flag) {
        case .Ritual:
            status.toggleRitualFilter(action.value)
            break
        case .Concentration:
            status.toggleConcentrationFilter(action.value)
            break
        case .Verbal:
            status.toggleVerbalFilter(action.value)
            break
        case .Somatic:
            status.toggleSomaticFilter(action.value)
            break
        case .Material:
            status.toggleMaterialFilter(action.value)
            break
        case .Royalty:
            status.toggleRoyaltyFilter(action.value)
            break
    }
    state.filterAndSortSpells()
    return state
}

func togglePropertyReducer(action: TogglePropertyAction, state: inout SpellbookAppState) -> SpellbookAppState {
    guard let profile = state.profile else { return state }
    let status = profile.spellFilterStatus
    switch action.property {
        case .All:
            return state
        case .Favorites:
            status.toggleFavorite(action.spell)
            break
        case .Known:
            status.toggleKnown(action.spell)
            break
        case .Prepared:
            status.togglePrepared(action.spell)
            break
    }
    if (
        profile.sortFilterStatus.statusFilterField == StatusFilterField.All
            &&
        profile.sortFilterStatus.statusFilterField == action.property
    ) {
        state.filterAndSortSpells()
    }
    state.dirtySpellIDs = state.dirtySpellIDs + [action.spell.id]
    return state
}

func toggleFilterOptionReducer(action: ToggleFilterOptionAction, state: inout SpellbookAppState) -> SpellbookAppState {
    guard let status = state.profile?.sortFilterStatus else { return state }
    switch (action.option) {
        case .ApplyFiltersToLists:
            status.applyFiltersToLists = !status.applyFiltersToLists
            break
        case .ApplyFiltersToSearch:
            status.applyFiltersToSearch = !status.applyFiltersToSearch
            break
        case .UseTashasExpandedLists:
            status.useTashasExpandedLists = !status.useTashasExpandedLists
            break
        case .HideDuplicateSpells:
            status.hideDuplicateSpells = !status.hideDuplicateSpells
            break
        case .Prefer2024Spells:
            status.prefer2024Spells = !status.prefer2024Spells
            break
    }
    state.filterAndSortSpells()
    return state
}

func updateSearchQueryReducer(action: UpdateSearchQueryAction, state: inout SpellbookAppState) -> SpellbookAppState {
    state.searchQuery = action.searchQuery
    if state.profile?.sortFilterStatus != nil {
        state.filterAndSortSpells()
    }
    return state
}

func updateProfileReducer(action: SwitchProfileAction, state: inout SpellbookAppState) -> SpellbookAppState {
    state.profile = action.newProfile
    state.settings.setCharacterName(name: action.newProfile.name)
    SerializationUtils.saveSettings(state.settings)
    state.filterAndSortSpells()
    return state
}

func clearProfileReducer(action: ClearProfileAction, state: inout SpellbookAppState) -> SpellbookAppState {
    state.profile = nil
    state.settings.setCharacterName(name: nil)
    SerializationUtils.saveSettings(state.settings)
    return state
}

func updateCharacterListReducer(action: UpdateCharacterListAction, state: inout SpellbookAppState) -> SpellbookAppState {
    state.profileNameList = SerializationUtils.characterNameList()
    return state
}

func useSpellSlotReducer(action: UseSpellSlotAction, state: SpellbookAppState) -> SpellbookAppState {
    guard let profile = state.profile else { return state }
    let status = profile.spellSlotStatus
    status.useSlot(level: action.level)
    return state
}

func gainSpellSlotReducer(action: GainSpellSlotAction, state: SpellbookAppState) -> SpellbookAppState {
    guard let profile = state.profile else { return state }
    let status = profile.spellSlotStatus
    status.gainSlot(level: action.level)
    return state
}

func editTotalSpellSlotsReducer(action: EditTotalSpellSlotsAction, state: SpellbookAppState) -> SpellbookAppState {
    guard let profile = state.profile else { return state }
    let status = profile.spellSlotStatus
    status.setTotalSlots(level: action.level, slots: action.totalSlots)
    return state
}

func regainAllSlotsReducer(action: RegainAllSlotsAction, state: SpellbookAppState) -> SpellbookAppState {
    guard let profile = state.profile else { return state }
    let status = profile.spellSlotStatus
    status.regainAllSlots()
    return state
}

func markAllSpellsCleanReducer(action: MarkAllSpellsCleanAction, state: inout SpellbookAppState) -> SpellbookAppState {
    state.dirtySpellIDs = []
    return state
}

func saveSettingsReducer(action: SaveSettingsAction, state: inout SpellbookAppState) -> SpellbookAppState {
    SerializationUtils.saveSettings(state.settings)
    return state
}

func castSpellReducer(action: CastSpellAction, state: SpellbookAppState) -> SpellbookAppState {
    guard let profile = state.profile else { return state }
    let status = profile.spellSlotStatus
    status.useSlot(level: action.level)
    return state
}
