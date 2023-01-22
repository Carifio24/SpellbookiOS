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
    switch action {
        
        // Updating sort parameters
        case let action as SortFieldAction:
            return sortFieldReducer(action: action, state: &state)
        case let action as SortReverseAction:
            return sortReverseReducer(action: action, state: &state)
        
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
        
        // Change character profile
        case let action as SwitchProfileAction:
            return updateProfileReducer(action: action, state: &state)
        
        // If we somehow get here, just do nothing
        default:
            return state
    }
}
