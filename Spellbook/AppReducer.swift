//
//  AppReducer.swift
//  Spellbook
//
//  Created by Mac Pro on 12/6/22.
//  Copyright © 2022 Jonathan Carifio. All rights reserved.
//

import ReSwift

func appReducer(action: Action, state: SpellbookAppState?) -> SpellbookAppState {
    var state = state ?? SpellbookAppState()

    state = specificActionReducer(action: action, state: &state)
    let saveProfile = shouldSave(action: action)

    // This will run on any action that updates the profile
    if (saveProfile) {
        if let profile = state.profile {
            SerializationUtils.saveCharacterProfile(profile: profile)
        }
    }

    return state
}

func shouldSave(action: Action) -> Bool {
    switch action {
    case _ as DeleteProfileByNameAction:
        return false
    case _ as DeleteProfileAction:
        return false
    case _ as UpdateCharacterListAction:
        return false
    case _ as SaveSettingsAction:
        return false
    case _ as ClearProfileAction:
        return false
    default:
        return true
    }
}

func specificActionReducer(action: Action, state: inout SpellbookAppState) -> SpellbookAppState {
    switch action {
        
    // Updating sort parameters
    case let action as SortFieldAction:
        return sortFieldReducer(action: action, state: &state)
    case let action as SortReverseAction:
        return sortReverseReducer(action: action, state: &state)
    
    // Update status filter
    case let action as StatusFilterAction:
        return statusFilterReducer(action: action, state: &state)
    
    // Spell level range
    case let action as SpellLevelAction:
        return spellLevelReducer(action: action, state: &state)
    
    // Visibility setting
    case let action as FilterSchoolAction:
        return filterSchoolReducer(action: action, state: &state)
    case let action as FilterClassAction:
        return filterClassReducer(action: action, state: &state)
    case let action as FilterSourcebookAction:
        return filterSourceReducer(action: action, state: &state)
    case let action as FilterCastingTimeTypeAction:
        return filterCastingTimeTypeReducer(action: action, state: &state)
    case let action as FilterDurationTypeAction:
        return filterDurationTypeReducer(action: action, state: &state)
    case let action as FilterRangeTypeAction:
        return filterRangeTypeReducer(action: action, state: &state)

    // All-but-one visibility setting
    case let action as FilterAllSchoolsButAction:
        return filterAllSchoolsButReducer(action: action, state: &state)
    case let action as FilterAllClassesButAction:
        return filterAllClassesButReducer(action: action, state: &state)
    case let action as FilterAllSourcebooksButAction:
        return filterAllSourcesButReducer(action: action, state: &state)
    case let action as FilterAllCastingTimeTypesButAction:
        return filterAllCastingTimeTypesButReducer(action: action, state: &state)
    case let action as FilterAllDurationTypesButAction:
        return filterAllDurationTypesButReducer(action: action, state: &state)
    case let action as FilterAllRangeTypesButAction:
        return filterAllRangeTypesButReducer(action: action, state: &state)
    
    // Visibility toggling
    case let action as ToggleSchoolAction:
        return toggleSchoolReducer(action: action, state: &state)
    case let action as ToggleClassAction:
        return toggleClassReducer(action: action, state: &state)
    case let action as ToggleSourcebookAction:
        return toggleSourceReducer(action: action, state: &state)
    case let action as ToggleCastingTimeTypeAction:
        return toggleCastingTimeTypeReducer(action: action, state: &state)
    case let action as ToggleDurationTypeAction:
        return toggleDurationTypeReducer(action: action, state: &state)
    case let action as ToggleRangeTypeAction:
        return toggleRangeTypeReducer(action: action, state: &state)

    // Select/unselect all functionality
    case let action as FilterAllSchoolsAction:
        return filterAllSchoolsReducer(action: action, state: &state)
    case let action as FilterAllClassesAction:
        return filterAllClassesReducer(action: action, state: &state)
    case let action as FilterAllSourcesAction:
        return filterAllSourcesReducer(action: action, state: &state)
    case let action as FilterAllCastingTimeTypesAction:
        return filterAllCastingTimeTypesReducer(action: action, state: &state)
    case let action as FilterAllDurationTypesAction:
        return filterAllDurationTypesReducer(action: action, state: &state)
    case let action as FilterAllRangeTypesAction:
        return filterAllRangeTypesReducer(action: action, state: &state)

    // Updating range values and units
    case let action as CastingTimeValueUpdateAction:
        return castingTimeValueUpdateReducer(action: action, state: &state)
    case let action as CastingTimeUnitUpdateAction:
        return castingTimeUnitUpdateReducer(action: action, state: &state)
    case let action as DurationValueUpdateAction:
        return durationValueUpdateReducer(action: action, state: &state)
    case let action as DurationUnitUpdateAction:
        return durationUnitUpdateReducer(action: action, state: &state)
    case let action as RangeValueUpdateAction:
        return rangeValueUpdateReducer(action: action, state: &state)
    case let action as RangeUnitUpdateAction:
        return rangeUnitUpdateReducer(action: action, state: &state)
    
    // Updating filter flags
    case let action as SetFlagAction:
        return setFlagFilterReducer(action: action, state: &state)
    case let action as ToggleFlagAction:
        return toggleFlagFilterReducer(action: action, state: &state)
    
    // Toggling whether a spell is on a list or not
    case let action as TogglePropertyAction:
        return togglePropertyReducer(action: action, state: &state)
    
    // Toggling one of the overall filter options
    // (e.g. apply filters to search/lists, and use TCE lists)
    case let action as ToggleFilterOptionAction:
        return toggleFilterOptionReducer(action: action, state: &state)
    
    // Search
    case let action as UpdateSearchQueryAction:
        return updateSearchQueryReducer(action: action, state: &state)
    
    // Change character profile
    case let action as SwitchProfileAction:
        return updateProfileReducer(action: action, state: &state)

    // Set current profile to nil
    case let action as ClearProfileAction:
        return clearProfileReducer(action: action, state: &state)
    
    // Generic sorting and filtering
    case let action as SortNeededAction:
        return sortNeededReducer(action: action, state: &state)
    case let action as FilterNeededAction:
        return filterNeededReducer(action: action, state: &state)
    
    // Update the character list
    case let action as UpdateCharacterListAction:
        return updateCharacterListReducer(action: action, state: &state)
        
    // Using & gaining spell slots
    case let action as UseSpellSlotAction:
        return useSpellSlotReducer(action: action, state: state)
    case let action as GainSpellSlotAction:
        return gainSpellSlotReducer(action: action, state: state)
    case let action as EditTotalSpellSlotsAction:
        return editTotalSpellSlotsReducer(action: action, state: state)
    case let action as RegainAllSlotsAction:
        return regainAllSlotsReducer(action: action, state: state)
    
    // Marking spells dirty
    case let action as MarkAllSpellsCleanAction:
        return markAllSpellsCleanReducer(action: action, state: &state)
        
    case let action as SaveSettingsAction:
        return saveSettingsReducer(action: action, state: &state)

    case let action as CastSpellAction:
        return castSpellReducer(action: action, state: state)

    // If we somehow get here, just do nothing
    default:
        return state
    }
}
