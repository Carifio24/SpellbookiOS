//
//  Distance.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 8/14/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import Foundation

// An enum class for the various types of Distance
enum RangeType: Int, Comparable, QuantityType {
    case Special=0, SelfDistance, Touch, Sight, Ranged, Unlimited
    
    internal static let displayNameMap: [RangeType:String] = [
        Special : "Special",
        SelfDistance : "Self",
        Touch : "Touch",
        Sight : "Sight",
        Ranged : "Ranged",
        Unlimited : "Unlimited"
    ]
    
    func isSpanningType() -> Bool {
        return self == .Ranged
    }
}

class Range : Quantity<RangeType, LengthUnit> {
    
    ///// Specialized constructors
    
    // If no unit is given, assume feet (if no unit is given, we shouldn't have a string description either)
    convenience init(type: RangeType, length: Int) {
        self.init(type: type, value: length, unit: LengthUnit.foot)
    }
    
    convenience init() {
        self.init(type: RangeType.SelfDistance, length: 0)
    }
    
    ///// Methods
    
    // The length, in feet
    func lengthInFeet() -> Int { return baseValue() }
    
    // Get a string representation of the Distance
    func string() -> String {
        
        // If we have a string representation, use that
        if (!str.isEmpty) { return str }
        
        switch (type) {
        case DistanceType.Touch, DistanceType.Special, DistanceType.Unlimited, DistanceType.Sight:
            return type.displayName
        case DistanceType.SelfDistance:
            if (self.value > 0) {
                return type.displayName + "(" + String(value) + " foot radius)"
            }
        case DistanceType.Ranged:
            let ft: String = (value == 1) ? unit.singularName() : unit.pluralName()
            return String(value) + " " + ft
            
        }
        return "" // We'll never get here, as the above cases exhaust the enum
    }
    
    // Create a Distance from its string description
    static func fromString(_ s: String) throws -> Range {
        
        // The "special" types - basically, ones other than Ranged and Self
        for type in [RangeType.Touch, RangeType.Special, RangeType.Sight, RangeType.Unlimited] {
            if (s.starts(with: type.displayName)) {
                return Range(type: type, value: 0, unit: LengthUnit.foot, str: s)
            }
        }
        
        // Parse Self and Ranged Distances
        if (s.starts(with: RangeType.SelfDistance.displayName)) {
            let sSplit = s.split(separator: " ", maxSplits: 1)
            if (sSplit.count == 1) {
                return Range(type: RangeType.SelfDistance, length: 0)
            } else {
                var distStr = String(sSplit[1])
                if ( !(distStr.hasPrefix("(") && distStr.hasSuffix(")")) ) {
                    throw SpellbookError.SelfRadiusError
                }
                let end = distStr.count - 2
                distStr = String(distStr[1...end])
                let distSplit = distStr.split(separator: " ")
                let length = Int(distSplit[0])
                let unit = try LengthUnit.fromString(String(distSplit[1]))
                return Range(type: RangeType.SelfDistance, value: length!, unit: unit, str: s)
            }
        }
        do {
            let sSplit = s.split(separator: " ")
            let length = Int(sSplit[0])
            let unit = try LengthUnit.fromString(String(sSplit[1]))
            return Range(type: RangeType.Ranged, value: length!, unit: unit, str: s)
        } catch let e {
            print("\(e)")
        }
        return Range()
    }
}
