//
//  Duration.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 8/15/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import Foundation

// An enum class for the various types of Distance
enum DurationType: Int, Comparable, QuantityType {
    
    case Special=0, Instantaneous, Spanning, UntilDispelled
    
    static var spanningType: DurationType = Spanning
    static var defaultValue: Int = 0
    
    internal static var displayNameMap = EnumMap<DurationType,String> { e in
        switch (e) {
        case .Special:
            return "Special"
        case .Instantaneous:
            return "Instantaneous"
        case .Spanning:
            return "Finite duration"
        case .UntilDispelled:
            return "Until dispelled"
        }
    }
    
}

class Duration : Quantity<DurationType, TimeUnit> {

    ///// Methods
    
    // The time, in seconds
    func timeInSeconds() -> Int { return baseValue() }
    
    // Get a string representation of the Duration
    func string() -> String {
        
        // If we have a string representation, use that
        if (!str.isEmpty) { return str }
        
        switch (type) {
        case DurationType.Instantaneous, DurationType.Special:
            return type.displayName
        case DurationType.UntilDispelled:
            return "Until dispelled"
        case DurationType.Spanning:
            let secs: String = (value == 1) ? unit.singularName : unit.pluralName
            return secs + " s"
        }
        return "" // We'll never get here, as the above cases exhaust the enum
    }
    
    // Create a Duration from its string description
    static func fromString(_ s: String) throws -> Duration {
        
        // Instantaneous and special
        for type in [DurationType.Instantaneous, DurationType.Special] {
            if (s.starts(with: type.displayName)) {
                return Duration(type: type, value: 0)
            }
            
        }
        
        // Until dispelled
        if (s.starts(with: "Until dispelled")) {
            return Duration(type: DurationType.UntilDispelled, value: 0)
        }
        
        // Spanning
        let concentrationPrefix = "Up to "
        let start = concentrationPrefix.count
        let t = s.starts(with: concentrationPrefix) ? String(s[start...]) : s
        do {
            let tSplit = t.split(separator: " ", maxSplits: 1)
            let value = Int(tSplit[0])
            //print("t is \(t)")
            //print("tSplit[1] is \(String(tSplit[1]))")
            let unit = try TimeUnit.fromString(String(tSplit[1]))
            return Duration(type: DurationType.Spanning, value: value!, unit: unit, str: s)
        } catch let e {
            print("\(e)")
        }
        return Duration()
    }
    
}
