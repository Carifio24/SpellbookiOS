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
    guard let status = state.profile?.sortFilterStatus else { return state }
    if (action.level == 1) {
        status.firstSortField = action.sortField
    } else if (action.level == 2) {
        status.secondSortField = action.sortField
    }
    return state
}

func sortReverseReducer(action: SortReverseAction, state: SpellbookAppState) -> SpellbookAppState {
    guard let status = state.profile?.sortFilterStatus else { return state }
    if (action.level == 1) {
        status.firstSortReverse = action.reverse
    } else if (action.level == 2) {
        status.secondSortReverse = action.reverse
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
fileprivate func valueUpdateReducer<T:QuantityType,U:Unit>(action: ValueUpdateAction<T,U>, state: SpellbookAppState) -> SpellbookAppState {
    guard let profile = state.profile else { return state }
    if (action.bound == .Min) {
        profile.setMinValue(quantityType: action.quantityType, unitType: action.unitType, value: action.value)
    } else {
        profile.setMaxValue(quantityType: action.quantityType, unitType: action.unitType, value: action.value)
    }
    return state
}
func rangeValueUpdateReducer(action: RangeValueUpdateAction, state: SpellbookAppState) -> SpellbookAppState {
    return valueUpdateReducer(action: action, state: state)
}
func durationValueUpdateReducer(action: DurationValueUpdateAction, state: SpellbookAppState) -> SpellbookAppState {
    return valueUpdateReducer(action: action, state: state)
}
func castingTimeValueUpdateReducer(action: CastingTimeValueUpdateAction, state: SpellbookAppState) -> SpellbookAppState {
    return valueUpdateReducer(action: action, state: state)
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


//func minRangeUnitUpdateReducer(action: MinRangeUnitUpdateAction, state: SpellbookAppState) -> SpellbookAppState {
//    return minUnitUpdateReducer(action: action, state: state)
//}
//func maxRangeUnitUpdateReducer(action: MinRangeUnitUpdateAction, state: SpellbookAppState) -> SpellbookAppState {
//    return maxUnitUpdateReducer(action: action, state: state)
//}
//func minDurationUnitUpdateReducer(action: MinDurationUnitUpdateAction, state: SpellbookAppState) -> SpellbookAppState {
//    return minUnitUpdateReducer(action: action, state: state)
//}
//func maxDurationUnitUpdateReducer(action: MinDurationUnitUpdateAction, state: SpellbookAppState) -> SpellbookAppState {
//    return maxUnitUpdateReducer(action: action, state: state)
//}
//func minCastingTimeUnitUpdateReducer(action: MinCastingTimeUnitUpdateAction, state: SpellbookAppState) -> SpellbookAppState {
//    return minUnitUpdateReducer(action: action, state: state)
//}
//func maxCastingTimeUnitUpdateReducer(action: MinCastingTimeUnitUpdateAction, state: SpellbookAppState) -> SpellbookAppState {
//    return maxUnitUpdateReducer(action: action, state: state)
//}

func updateProfileReducer(action: SwitchProfileAction, state: inout SpellbookAppState) -> SpellbookAppState {
    state.profile = action.newProfile
    return state
}
