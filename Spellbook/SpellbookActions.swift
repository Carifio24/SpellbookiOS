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

struct FilterAllAction<T:NameConstructible>: Action {
    let visible: Bool
}

struct StatusFilterAction: Action {
    let statusFilterField: StatusFilterField
}

struct SpellLevelAction: Action {
    let bound: Bound
    let level: Int
    
    static func min(_ level: Int) -> SpellLevelAction {
        return SpellLevelAction(bound: .Min, level: level)
    }
    
    static func max(_ level: Int) -> SpellLevelAction {
        return SpellLevelAction(bound: .Max, level: level)
    }
}

typealias FilterSchoolAction = FilterItemAction<School>
typealias FilterClassAction = FilterItemAction<CasterClass>
typealias FilterSourcebookAction = FilterItemAction<Sourcebook>
typealias FilterCastingTimeTypeAction = FilterItemAction<CastingTimeType>
typealias FilterDurationTypeAction = FilterItemAction<DurationType>
typealias FilterRangeTypeAction = FilterItemAction<RangeType>

typealias FilterAllSchoolsAction = FilterAllAction<School>
typealias FilterAllClassesAction = FilterAllAction<CasterClass>
typealias FilterAllSourcesAction = FilterAllAction<Sourcebook>
typealias FilterAllCastingTimeTypesAction = FilterAllAction<CastingTimeType>
typealias FilterAllDurationTypesAction = FilterAllAction<DurationType>
typealias FilterAllRangeTypesAction = FilterAllAction<RangeType>

struct ToggleItemAction<T:NameConstructible>: Action {
    let item: T
}

typealias ToggleSchoolAction = ToggleItemAction<School>
typealias ToggleClassAction = ToggleItemAction<CasterClass>
typealias ToggleSourcebookAction = ToggleItemAction<Sourcebook>
typealias ToggleCastingTimeTypeAction = ToggleItemAction<CastingTimeType>
typealias ToggleDurationTypeAction = ToggleItemAction<DurationType>
typealias ToggleRangeTypeAction = ToggleItemAction<RangeType>


enum Bound { case Min, Max }

struct ValueUpdateAction<T: QuantityType, U: Unit>: Action {
    let value: Int
    let bound: Bound
    let quantityType: T.Type
    let unitType: U.Type
    
    static func min(value: Int, quantityType: T.Type, unitType: U.Type) -> ValueUpdateAction<T,U> {
        return ValueUpdateAction<T,U>(value: value, bound: .Min, quantityType: quantityType, unitType: unitType)
    }
    
    static func max(value: Int, quantityType: T.Type, unitType: U.Type) -> ValueUpdateAction<T,U> {
        return ValueUpdateAction<T,U>(value: value, bound: .Max, quantityType: quantityType, unitType: unitType)
    }
}
typealias RangeValueUpdateAction = ValueUpdateAction<RangeType, LengthUnit>
typealias DurationValueUpdateAction = ValueUpdateAction<DurationType, TimeUnit>
typealias CastingTimeValueUpdateAction = ValueUpdateAction<CastingTimeType, TimeUnit>


struct UnitUpdateAction<T: QuantityType, U: Unit>: Action {
    let unit: U
    let bound: Bound
    let quantityType: T.Type
    
    static func min(unit: U, quantityType: T.Type) -> UnitUpdateAction<T,U> {
        return UnitUpdateAction<T,U>(unit: unit, bound: .Min, quantityType: quantityType)
    }
    
    static func max(unit: U, quantityType: T.Type) -> UnitUpdateAction<T,U> {
        return UnitUpdateAction<T,U>(unit: unit, bound: .Max, quantityType: quantityType)
    }
}
typealias RangeUnitUpdateAction = UnitUpdateAction<RangeType, LengthUnit>
typealias DurationUnitUpdateAction = UnitUpdateAction<DurationType, TimeUnit>
typealias CastingTimeUnitUpdateAction = UnitUpdateAction<CastingTimeType, TimeUnit>

struct QuantityRangeDefaultAction<T: QuantityType, U: Unit, Q: Quantity<T,U>>: Action {}
typealias CastingTimeDefaultAction = QuantityRangeDefaultAction<CastingTimeType,TimeUnit,CastingTime>
typealias DurationDefaultAction = QuantityRangeDefaultAction<DurationType,TimeUnit,Duration>
typealias RangeDefaultAction = QuantityRangeDefaultAction<RangeType,LengthUnit,Range>


struct SortNeededAction: Action {}
struct FilterNeededAction: Action {}

enum FlagType {
    case Ritual, Concentration, Verbal, Somatic, Material
}

struct SetFlagAction: Action {
    let flag: FlagType
    let tf: Bool
    let value: Bool
    
    static func ritual(_ tf: Bool, to: Bool) -> SetFlagAction { return SetFlagAction(flag: .Ritual, tf: tf, value: to) }
    static func concentration(_ tf: Bool, to: Bool) -> SetFlagAction { return SetFlagAction(flag: .Concentration, tf: tf, value: to) }
    static func verbal(_ tf: Bool, to: Bool) -> SetFlagAction { return SetFlagAction(flag: .Verbal, tf: tf, value: to) }
    static func somatic(_ tf: Bool, to: Bool) -> SetFlagAction { return SetFlagAction(flag: .Somatic, tf: tf, value: to) }
    static func material(_ tf: Bool, to: Bool) -> SetFlagAction { return SetFlagAction(flag: .Material, tf: tf, value: to) }
}

struct ToggleFlagAction: Action {
    let flag: FlagType
    let value: Bool
    
    static func ritual(_ value: Bool) -> ToggleFlagAction { return ToggleFlagAction(flag: .Ritual, value: value) }
    static func concentration(_ value: Bool) -> ToggleFlagAction { return ToggleFlagAction(flag: .Concentration, value: value) }
    static func verbal(_ value: Bool) -> ToggleFlagAction { return ToggleFlagAction(flag: .Verbal, value: value) }
    static func somatic(_ value: Bool) -> ToggleFlagAction { return ToggleFlagAction(flag: .Somatic, value: value) }
    static func material(_ value: Bool) -> ToggleFlagAction { return ToggleFlagAction(flag: .Material, value: value) }
}

struct TogglePropertyAction: Action {
    let spell: Spell
    let property: StatusFilterField
    var markDirty: Bool = true
}

enum FilterOption {
    case ApplyFiltersToLists, ApplyFiltersToSearch, UseTashasExpandedLists
}

struct ToggleFilterOptionAction: Action {
    let option: FilterOption
    
    static func applyFiltersToLists() -> ToggleFilterOptionAction { return ToggleFilterOptionAction(option: .ApplyFiltersToLists) }
    static func applyFiltersToSearch() -> ToggleFilterOptionAction { return ToggleFilterOptionAction(option: .ApplyFiltersToSearch) }
    static func useTashasExpandedLists() -> ToggleFilterOptionAction { return ToggleFilterOptionAction(option: .UseTashasExpandedLists) }
}

struct SetFilterOptionAction: Action {
    let option: FilterOption
    let value: Bool
    
    static func applyFiltersToLists(_ value: Bool) -> SetFilterOptionAction { return SetFilterOptionAction(option: .ApplyFiltersToLists, value: value) }
    static func applyFiltersToSearch(_ value: Bool) -> SetFilterOptionAction { return SetFilterOptionAction(option: .ApplyFiltersToSearch, value: value) }
    static func useTashasExpandedLists(_ value: Bool) -> SetFilterOptionAction { return SetFilterOptionAction(option: .UseTashasExpandedLists, value: value) }
}

struct UpdateSearchQueryAction: Action {
    let searchQuery: String
}

struct SwitchProfileAction: Action {
    //let oldProfile: CharacterProfile
    let newProfile: CharacterProfile
}

struct SwitchProfileByNameAction: Action {
    let name: String
}

struct ClearProfileAction: Action {}

struct CreateProfileAction: Action {
    let profile: CharacterProfile
}

struct DeleteProfileAction: Action {
    let profile: CharacterProfile
}

struct DeleteProfileByNameAction: Action {
    let name: String
}

struct SaveProfileAction: Action {
    let profile: CharacterProfile
}

struct SaveCurrentProfileAction: Action {}

struct SaveSettingsAction: Action {}

struct NameChangeAction: Action {
    let name: String
}

struct UpdateCharacterListAction: Action {}

struct UseSpellSlotAction: Action {
    let level: Int
}

struct GainSpellSlotAction: Action {
    let level: Int
}

struct EditTotalSpellSlotsAction: Action {
    let level: Int
    let totalSlots: Int
}

// TODO: Is there a better way to do this?
struct MarkAllSpellsCleanAction: Action {}
