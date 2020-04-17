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
    
    static var defaultUnit = second
    
    static internal var names: [TimeUnit:Array<String>] = [
        second: ["second", "seconds", "s", "s."],
        round: ["round", "rounds", "rds", "rds."],
        minute: ["minute", "minutes", "mins", "mins."],
        hour: ["hour", "hours", "hrs", "hrs."],
        day: ["day", "days", "days", "days"],
        year: ["year", "years", "yrs", "yrs."]
    ]
    
    var value: Int { return self.rawValue }
    
    func inSeconds() -> Int { return value }
    
}
