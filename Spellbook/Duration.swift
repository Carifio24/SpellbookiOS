//
//  Duration.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 8/15/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import Foundation

// An enum class for the various types of Distance
fileprivate enum DistanceType: Int {
    case Special=0, SelfDistance, Touch, Sight, Ranged, Unlimited
}

class Duration : Quantity<DurationType, TimeUnit> {
    
    ///// Specialized constructors
    
    // If no unit is given, assume seconds (if no unit is given, we shouldn't have a string description either)
    convenience init(type: DurationType, secs: Int) {
        super.init(type: type, value: secs, unit: TimeUnit.second)
    }
    
    convenience init() {
        self.init(type: Instantaneous, secs: 0)
    }
    
    ///// Methods
    
    // The time, in seconds
    func timeInSeconds() -> Int { return baseValue() }
    
    // Get a string representation of the Duration
    func string() -> String {
        
        // If we have a string representation, use that
        if (!str.isEmpty) { return str }
        
        switch (type) {
        case Instantaneous, Special:
            return type.name()
        case UntilDispelled:
            return "Until dispelled"
        case Spanning:
            let secs: String = (self.value() == 1) ? type.name() : type.pluralName()
            return value + " " + secs
        default:
            return "" // We'll never get here, as the above cases exhaust the enum
        }
    }
    
    // Create a Duration from its string description
    static func fromString(_ s: String) -> Duration {
        
        // Instantaneous and special
        for type in [Instantaneous, Special] {
            if (s.starts(with: type.name())) {
                return Duration(type: type, value: 0)
            }
            
        }
        
        // Until dispelled
        if (s.starts(with: "Until dispelled")) {
            return Duration(type: UntilDispelled, secs: 0)
        }
        
        // Spanning
        let concentrationPrefix = "Up to"
        let t = s.starts(with:concentrationPrefix) ? String(s[(concentrationPrefix.count-1)..]) : s
        do {
            let tSplit = t.split(" ", 2)
            let value = Int(tSplit[0])
            let unit = TimeUnit.fromString(tSplit[1])
            return Duration(type: Spanning, value: value, unit: unit, str: s)
        } catch let e{
            print("\(e)")
        }
        
    }
    
}
