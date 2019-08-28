//
//  TimeUnit.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 8/14/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import Foundation

enum TimeUnit : Int, Unit {
    
    case second=1, round=6, minute=60, hour=3600, day=86400, year=31536000
    
    static private let names: [TimeUnit:Array<String>] = [
        second: ["second", "seconds", "s", "s."],
        round: ["round", "rounds", "rd", "rd."],
        minute: ["minute", "minutes", "min", "min."],
        hour: ["hour", "hours", "hrs", "hrs."],
        day: ["day", "days", "dy", "dy."],
        year: ["year", "years", "yr", "yr."]
    ]
    
    func name() -> String {
        return TimeUnit.names[self]![0]
    }
    
    func pluralName() -> String {
        return TimeUnit.names[self]![1]
    }
    
    func abbreviation() -> String {
        return TimeUnit.names[self]![2]
    }
    
    func value() -> Int {
        return self.rawValue
    }
    
    func inSeconds() -> Int { return value() }
    
    // Create a TimeUnit instance from a String
    static func fromString(_ s: String) throws -> TimeUnit {
        let t = s.lowercased()
        for (unit, arr) in names {
            for name in arr {
                if (t == name) {
                    return unit
                }
            }
        }
        print(s)
        throw SpellbookError.UnitStringError
    }
    
}
