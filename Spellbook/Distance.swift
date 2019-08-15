//
//  Distance.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 8/14/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import Foundation

// An enum class for the various types of Distance
fileprivate enum DistanceType: Int {
    case Special=0, SelfDistance, Touch, Sight, Ranged, Unlimited
}

class Distance : Quantity<DistanceType, LengthUnit> {
    
    ///// Specialized constructors
    
    // If no unit is given, assume feet (if no unit is given, we shouldn't have a string description either)
    convenience init(type: DistanceType, length: Int) {
        super.init(type: type, value: length, unit: LengthUnit.foot)
    }
    
    convenience init() {
        self.init(type: SelfDistance, length: 0)
    }
    
    ///// Methods
    
    // The length, in feet
    func lengthInFeet() -> Int { return baseValue() }
    
    // Get a string representation of the Distance
    func string() -> String {
        
        // If we have a string representation, use that
        if (!str.isEmpty) { return str }
        
        switch (type) {
        case Touch, Special, Unlimited, Sight:
            return type.name()
        case SelfDistance:
            if (self.value > 0) {
                return type.name() + "(" + self.value + " foot radius)"
            }
        case Ranged:
            let ft: String = (self.value() == 1) ? type.name() : type.pluralName()
            return value + " " + ft
        default:
            return "" // We'll never get here, as the above cases exhaust the enum
        }
    }
    
    // Create a Distance from its string description
    static func fromString(_ s: String) -> Distance {
        
        // The "special" types - basically, ones other than Ranged and Self
        for type in [Touch, Special, Sight, Unlimited] {
            if (s.starts(with: type.name())) {
                return Distance(type: type, value: 0, unit: LengthUnit.foot, str: s)
            }
        }
        
        // Parse Self and Ranged Distances
        if (s.starts(with: SelfDistance.name())) {
            let sSplit = s.split(" ", 2)
            if (sSplit.count == 1) {
                return Distance(type: SelfDistance)
            } else {
                var distStr = sSplit[1]
                if ( !(distStr.starts(with: "(") && distStr.ends(with: ")")) ) {
                    throw Error("Error parsing radius of spell with Distance Self")
                }
                distStr = String(distStr[1..distStr.count-2])
                let distSplit = distStr.split(" ")
                let length = Int(distSplit[0])
                let unit = LengthUnit.fromString(distSplit[1])
                return Distance(type: SelfDistance, length: length, unit: unit, str: s)
            }
            do {
                let sSplit = s.split(" ")
                let length = Int(sSplit[0])
                let unit = LengthUnit.fromString(sSplit[1])
                return Distance(type: Ranged, length: length, unit: unit, str: s)
            } catch let e {
                print("\(e)")
            }
        }
    }
}
