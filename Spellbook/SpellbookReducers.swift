//
//  SpellbookReducers.swift
//  Spellbook
//
//  Created by Mac Pro on 12/7/22.
//  Copyright © 2022 Jonathan Carifio. All rights reserved.
//

import ReSwift

func identityReducer(action: Action, state: SpellbookAppState?) -> SpellbookAppState {
    return state ?? SpellbookAppState()
}

func sortFieldReducer(action: SortFieldAction, state: SpellbookAppState?) -> SpellbookAppState {
    let state = state ?? SpellbookAppState()
    if (action.level == 1) {
        state.profile?.setFirstSortField(action.sortField)
    }
    else if (action.level == 2) {
        state.profile?.setSecondSortField(action.sortField)
    }
    return state
}

func sortReverseReducer(action: SortReverseAction, state: SpellbookAppState?) -> SpellbookAppState {
    let state = state ?? SpellbookAppState()
    if (action.level == 1) {
        state.profile?.setFirstSortReverse(action.reverse)
    }
    else if (action.level == 2) {
        state.profile?.setSecondSortReverse(action.reverse)
    }
    return state
}

fileprivate func filterReduce<T:NameConstructible>(action: FilterItemAction<T>, state: SpellbookAppState?, type: T.Type) {
    state?.profile?.setVisibility(action.item, action.visible)
}

func filterItemReducer(action: Action, state: SpellbookAppState?) -> SpellbookAppState {
    if let filterItemAction = action as? FilterItemAction<T> {
        filterReduce(action: filterItemAction, state: state, type: type(of: filterItemAction.item))
    }
    return state
}

//let filterSchoolReducer = filterItemReducer<School>
//let filterClassReducer = filterItemReducer<CasterClass>
//let filterSourcebookItemReducer = filterItemReducer<Sourcebook>
//let filterCastingTimeTypeReducer = filterItemReducer<CastingTimeType>
//let filterDurationTypeReducer = filterItemReducer<DurationType>
//let filterRangeTypeReducer = filterItemReducer<RangeType>

func sortNeededReducer(action: SortNeededAction, state: SpellbookAppState?) -> SpellbookAppState {
    var state = state ?? SpellbookAppState()
    state.sortNeeded = true
    return state
}

func filterNeededReducer(action: FilterNeededAction, state: SpellbookAppState?) -> SpellbookAppState {
    var state = state ?? SpellbookAppState()
    state.filterNeeded = true
    return state
}

func rangeValueUpdate(action: Action, state: SpellbookAppState?) -> SpellbookAppState {
    let state = state ?? SpellbookAppState()
    if let minAction = action as? MinRangeValueUpdateAction {
        state.profile?.setMinValue(quantityType: minAction.quantityType, unitType: minAction.unitType, value: minAction.value)
    }
    return state
}

func rangeUnitUpdate(action: Action, state: SpellbookAppState?) -> SpellbookAppState {
    let state = state ?? SpellbookAppState()
    if let minAction = action as? MinRangeUnitUpdateAction {
        state.profile?.setMinUnit(quantityType: minAction.quantityType, unitType: type(of: minAction.unit), unit: minAction.unit)
    }
    return state
}

func updateProfileReducer(action: Action, state: SpellbookAppState?) -> SpellbookAppState {
    var state = state ?? SpellbookAppState()
    if let updateProfileAction = action as? UpdateProfileAction {
        state.profile = updateProfileAction.newProfile
    }
    return state
}
