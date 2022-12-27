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

func sortFieldReducer(action: SortFieldAction, state: SpellbookAppState) -> SpellbookAppState {
    if (action.level == 1) {
        state.profile?.setFirstSortField(action.sortField)
    } else if (action.level == 2) {
        state.profile?.setSecondSortField(action.sortField)
    }
    return state
}

func sortReverseReducer(action: SortReverseAction, state: SpellbookAppState) -> SpellbookAppState {
    if (action.level == 1) {
        state.profile?.setFirstSortReverse(action.reverse)
    } else if (action.level == 2) {
        state.profile?.setSecondSortReverse(action.reverse)
    }
    return state
}

func filterItemReducer<T:NameConstructible>(action: FilterItemAction<T>, state: SpellbookAppState) -> SpellbookAppState {
    state.profile?.setVisibility(action.item, action.visible)
    return state
}
//let filterSchoolReducer = filterItemReducer<School>
//let filterClassReducer = filterItemReducer<CasterClass>
//let filterSourcebookItemReducer = filterItemReducer<Sourcebook>
//let filterCastingTimeTypeReducer = filterItemReducer<CastingTimeType>
//let filterDurationTypeReducer = filterItemReducer<DurationType>
//let filterRangeTypeReducer = filterItemReducer<RangeType>

func sortNeededReducer(action: SortNeededAction, state: inout SpellbookAppState) -> SpellbookAppState {
    state.sortNeeded = true
    return state
}

func filterNeededReducer(action: FilterNeededAction, state: inout SpellbookAppState) -> SpellbookAppState {
    state.filterNeeded = true
    return state
}


typealias ValueSetter<T:QuantityType,U:Unit> = (CharacterProfile) -> (T.Type, U.Type, Int) -> Void
fileprivate func valueUpdateReducer<T:QuantityType,U:Unit>(action: ValueUpdateAction<T,U>, state: SpellbookAppState, setter: ValueSetter<T,U>) -> SpellbookAppState {
    if state.profile != nil {
        setter(state.profile!)(action.quantityType, action.unitType, action.value)
    }
    return state
}
fileprivate func minValueUpdateReducer<T:QuantityType,U:Unit>(action: ValueUpdateAction<T,U>, state: SpellbookAppState) -> SpellbookAppState {
    return valueUpdateReducer(action: action, state: state, setter: CharacterProfile.setMinValue)
}
fileprivate func maxValueUpdateReducer<T:QuantityType,U:Unit>(action: ValueUpdateAction<T,U>, state: SpellbookAppState) -> SpellbookAppState {
    return valueUpdateReducer(action: action, state: state, setter: CharacterProfile.setMaxValue)
}
func minRangeValueUpdateReducer(action: MinRangeValueUpdateAction, state: SpellbookAppState) -> SpellbookAppState {
    return minValueUpdateReducer(action: action, state: state)
}
func maxRangeValueUpdateReducer(action: MinRangeValueUpdateAction, state: SpellbookAppState) -> SpellbookAppState {
    return maxValueUpdateReducer(action: action, state: state)
}
func minDurationValueUpdateReducer(action: MinDurationValueUpdateAction, state: SpellbookAppState) -> SpellbookAppState {
    return minValueUpdateReducer(action: action, state: state)
}
func maxDurationValueUpdateReducer(action: MinDurationValueUpdateAction, state: SpellbookAppState) -> SpellbookAppState {
    return maxValueUpdateReducer(action: action, state: state)
}
func minCastingTimeValueUpdateReducer(action: MinCastingTimeValueUpdateAction, state: SpellbookAppState) -> SpellbookAppState {
    return minValueUpdateReducer(action: action, state: state)
}
func maxCastingTimeValueUpdateReducer(action: MinCastingTimeValueUpdateAction, state: SpellbookAppState) -> SpellbookAppState {
    return maxValueUpdateReducer(action: action, state: state)
}


typealias UnitSetter<T:QuantityType,U:Unit> = (CharacterProfile) ->  (T.Type, U.Type, U) -> Void
fileprivate func unitUpdateReducer<T:QuantityType,U:Unit>(action: UnitUpdateAction<T,U>, state: SpellbookAppState, setter: UnitSetter<T,U>) -> SpellbookAppState {
    if state.profile != nil {
        setter(state.profile!)(action.quantityType, type(of: action.unit), action.unit)
    }
    return state
}
fileprivate func minUnitUpdateReducer<T:QuantityType,U:Unit>(action: UnitUpdateAction<T,U>, state: SpellbookAppState) -> SpellbookAppState {
    return unitUpdateReducer(action: action, state: state, setter: CharacterProfile.setMinUnit)
}
fileprivate func maxUnitUpdateReducer<T:QuantityType,U:Unit>(action: UnitUpdateAction<T,U>, state: SpellbookAppState) -> SpellbookAppState {
    return unitUpdateReducer(action: action, state: state, setter: CharacterProfile.setMaxUnit)
}


func minRangeUnitUpdateReducer(action: MinRangeUnitUpdateAction, state: SpellbookAppState) -> SpellbookAppState {
    return minUnitUpdateReducer(action: action, state: state)
}
func maxRangeUnitUpdateReducer(action: MinRangeUnitUpdateAction, state: SpellbookAppState) -> SpellbookAppState {
    return maxUnitUpdateReducer(action: action, state: state)
}
func minDurationUnitUpdateReducer(action: MinDurationUnitUpdateAction, state: SpellbookAppState) -> SpellbookAppState {
    return minUnitUpdateReducer(action: action, state: state)
}
func maxDurationUnitUpdateReducer(action: MinDurationUnitUpdateAction, state: SpellbookAppState) -> SpellbookAppState {
    return maxUnitUpdateReducer(action: action, state: state)
}
func minCastingTimeUnitUpdateReducer(action: MinCastingTimeUnitUpdateAction, state: SpellbookAppState) -> SpellbookAppState {
    return minUnitUpdateReducer(action: action, state: state)
}
func maxCastingTimeUnitUpdateReducer(action: MinCastingTimeUnitUpdateAction, state: SpellbookAppState) -> SpellbookAppState {
    return maxUnitUpdateReducer(action: action, state: state)
}

func updateProfileReducer(action: UpdateProfileAction, state: inout SpellbookAppState) -> SpellbookAppState {
    state.profile = action.newProfile
    return state
}
