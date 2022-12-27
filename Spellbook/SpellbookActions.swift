//
//  SpellbookActions.swift
//  Spellbook
//
//  Created by Mac Pro on 12/6/22.
//  Copyright © 2022 Jonathan Carifio. All rights reserved.
//

import ReSwift

struct SortFieldAction: Action {
    let sortField: SortField
    let level: Int
}

struct SortReverseAction: Action {
    let reverse: Bool
    let level: Int
}

struct FilterItemAction<T:NameConstructible>: Action {
    let item: T
    let visible: Bool
}

typealias FilterSchoolAction = FilterItemAction<School>
typealias FilterClassAction = FilterItemAction<CasterClass>
typealias FilterSourcebookAction = FilterItemAction<Sourcebook>
typealias FilterCastingTimeTypeAction = FilterItemAction<CastingTimeType>
typealias FilterDurationTypeReducer = FilterItemAction<DurationType>
typealias FilterRangeType = FilterItemAction<RangeType>


struct ValueUpdateAction<T: QuantityType, U: Unit>: Action {
    let value: Int
    let quantityType: T.Type
    let unitType: U.Type
}
typealias MinRangeValueUpdateAction = ValueUpdateAction<RangeType, LengthUnit>
typealias MaxRangeValueUpdateAction = ValueUpdateAction<RangeType, LengthUnit>
typealias MinDurationValueUpdateAction = ValueUpdateAction<DurationType, TimeUnit>
typealias MaxDurationValueUpdateAction = ValueUpdateAction<DurationType, TimeUnit>
typealias MinCastingTimeValueUpdateAction = ValueUpdateAction<CastingTimeType, TimeUnit>
typealias MaxCastingTimeValueUpdateAction = ValueUpdateAction<CastingTimeType, TimeUnit>


struct UnitUpdateAction<T:QuantityType, U: Unit>: Action {
    let unit: U
    let quantityType: T.Type
}
typealias MinRangeUnitUpdateAction = UnitUpdateAction<RangeType, LengthUnit>
typealias MaxRangeUnitUpdateAction = UnitUpdateAction<RangeType, LengthUnit>
typealias MinDurationUnitUpdateAction = UnitUpdateAction<DurationType, TimeUnit>
typealias MaxDurationUnitUpdateAction = UnitUpdateAction<DurationType, TimeUnit>
typealias MinCastingTimeUnitUpdateAction = UnitUpdateAction<CastingTimeType, TimeUnit>
typealias MaxCastingTimeUnitUpdateAction = UnitUpdateAction<CastingTimeType, TimeUnit>


struct SortNeededAction: Action {}
struct FilterNeededAction: Action {}

struct UpdateProfileAction: Action {
    let oldProfile: CharacterProfile
    let newProfile: CharacterProfile
}
