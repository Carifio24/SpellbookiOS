//
//  CastingTime.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 2/10/20.
//  Copyright © 2020 Jonathan Carifio. All rights reserved.
//

import Foundation

enum CastingTimeType: Int, Comparable, QuantityType {
    case Action=0, BonusAction, Reaction, Time
    
    private static let parseNameMap = [
        Action : "action",
        BonusAction : "bonus action",
        Reaction : "reaction",
        Time : "time"
    ]
    
    internal static let displayNameMap: EnumMap<CastingTimeType,String> {
        switch (self) {
            case .Action:
                return "1 action"
            case .BonusAction
                return "1 bonus action"
            case .Reaction:
                return "1 reaction"
            case .Time:
                return "Other"
        }
    }
    
    fileprivate static let actionTypes = [ Action, BonusAction, Reaction ]
    
    fileprivate var parseName: String {
        return CastingTimeType.parseNameMap[self]!
    }
    
    func isSpanningType() -> Bool {
        return self == .Time
    }
}


class CastingTime : Quantity<CastingTimeType, TimeUnit> {
    
    // Number of seconds in one round
    private static let SECONDS_PER_ROUND = 6
    
    ///// Specialized constructors
    
    // If no unit is given, assume seconds (if no unit is given, we shouldn't have a string description either)
    convenience init(type: CastingTimeType, secs: Int) {
        self.init(type: type, value: secs, unit: TimeUnit.second)
    }
    
    convenience init() {
        self.init(type: CastingTimeType.Action, secs: CastingTime.SECONDS_PER_ROUND)
    }
    
    ///// Methods
    
    // The time, in seconds
    func timeInSeconds() -> Int { return baseValue() }
    
    // Get a string representation of the CastingTime
    func string() -> String {
        
        // If we have a string representation, use that
        if (!str.isEmpty) { return str }
        
        if (type == CastingTimeType.Time) {
            let unitStr = (value == 1) ? unit.singularName() : unit.pluralName()
            return String(describing: value) + " " + unitStr
        } else {
            var typeStr = " " + type.parseName
            if (value != 1) {
                typeStr += "s"
            }
            return String(describing: value) + typeStr
        }
    }
    
    // Create a CastingTime from its string description
    static func fromString(_ s: String) throws -> CastingTime {
        
        do {
            let sSplit = s.split(separator: " ", maxSplits: 1)
            let value = Int(sSplit[0])!
            let typeStr = String(sSplit[1])
            
            // If the type is one of the action types
            var type: CastingTimeType? = nil
            for ctt in CastingTimeType.actionTypes {
                if typeStr.starts(with: ctt.parseName) {
                    type = ctt
                    break
                }
            }
            if (type != nil) {
                let inRounds = value * SECONDS_PER_ROUND
                return CastingTime(type: type!, value: inRounds, unit: TimeUnit.second, str: s)
            }
            
            // Otherwise, get the time unit
            let unit = try TimeUnit.fromString(typeStr)
            return CastingTime(type: CastingTimeType.Time, value: value, unit: unit, str: s)
        } catch let e {
            print(e.localizedDescription)
        }
        return CastingTime()
        
    }
    
}
