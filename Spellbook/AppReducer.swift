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
        case let action as SortFieldAction:
            return sortFieldReducer(action: action, state: state)
        case let action as SortReverseAction:
            return sortReverseReducer(action: action, state: state)
        case let action as FilterSchoolAction:
            return filterItemReducer(action: action, state: state)
        case let action as FilterClassAction:
            return filterItemReducer(action: action, state: state)
        case let action as FilterSourcebookAction:
            return filterItemReducer(action: action, state: state)
        case let action as FilterCastingTimeTypeAction:
            return filterItemReducer(action: action, state: state)
        case let action as FilterDurationTypeAction:
            return filterItemReducer(action: action, state: state)
        case let action as FilterRangeTypeAction:
            return filterItemReducer(action: action, state: state)
        case let action as SwitchProfileAction:
            return updateProfileReducer(action: action, state: &state)
        default:
            return state
    }
}
