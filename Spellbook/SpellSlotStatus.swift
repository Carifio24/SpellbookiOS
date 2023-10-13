//
//  SpellSlotStatus.swift
//  Spellbook
//
//  Created by Mac Pro on 8/29/22.
//  Copyright © 2022 Jonathan Carifio. All rights reserved.
//

import Foundation

class SpellSlotStatus {
    
    private(set) var totalSlots: [Int]
    private(set) var usedSlots: [Int]
    
    private static let totalSlotsKey = "totalSlots"
    private static let usedSlotsKey = "usedSlotsKey"

    init(totalSlots: [Int], usedSlots: [Int]) {
        self.totalSlots = totalSlots
        self.usedSlots = usedSlots
    }
    
    convenience init() {
        let totalSlots = [Int](repeating: 0, count: Spellbook.MAX_SPELL_LEVEL)
        let usedSlots = [Int](repeating: 0, count: Spellbook.MAX_SPELL_LEVEL)
        self.init(totalSlots: totalSlots, usedSlots: usedSlots)
    }
    
    convenience init(sion: SION) {
        let totalSlots = sion[SpellSlotStatus.totalSlotsKey].array?.map{ intFromSION($0) } ?? [Int](repeating: 0, count: Spellbook.MAX_SPELL_LEVEL)
        let usedSlots = sion[SpellSlotStatus.usedSlotsKey].array?.map{ intFromSION($0) } ?? [Int](repeating: 0, count: Spellbook.MAX_SPELL_LEVEL)
        self.init(totalSlots: totalSlots, usedSlots: usedSlots)
    }
    
    func getTotalSlots(level: Int) -> Int { return totalSlots[level - 1] }
    func getUsedSlots(level: Int) -> Int { return usedSlots[level - 1] }
    func getAvailableSlots(level: Int) -> Int { return totalSlots[level - 1] - usedSlots[level - 1] }
    
    func hasSlots(level: Int) -> Bool { return getTotalSlots(level: level) > 0 }
    func hasAvailableSlots(level: Int) -> Bool { return getAvailableSlots(level: level) > 0 }

    func setTotalSlots(level: Int, slots: Int) {
        totalSlots[level - 1] = slots
        if (slots < usedSlots[level - 1]) {
            usedSlots[level - 1] = slots
        }
    }
    
    func setAvailableSlots(level: Int, slots: Int) {
        let used = totalSlots[level - 1] - slots
        usedSlots[level - 1] = max(0, used)
    }

    func setUsedSlots(level: Int, slots: Int) {
        usedSlots[level - 1] = min(slots, totalSlots[level - 1])
    }

    func regainAllSlots() {
        usedSlots = usedSlots.map { _ in 0 }
    }

    func useSlot(level: Int) {
        usedSlots[level - 1] = min(usedSlots[level - 1] + 1, totalSlots[level - 1])
    }

    func gainSlot(level: Int) {
        usedSlots[level - 1] = max(usedSlots[level - 1] - 1, 0)
    }

    func levelWithCondition(condition: Predicate<Int>, range: ClosedRange<Int>) -> Int {
        for level in range {
            if condition(level) {
                return level
            }
        }
        return 0
    }

    func minLevelWithCondition(condition: Predicate<Int>) -> Int {
        return levelWithCondition(condition: condition, range: Spellbook.MIN_SPELL_LEVEL...Spellbook.MAX_SPELL_LEVEL)
    }

    func maxLevelWithCondition(condition: Predicate<Int>) -> Int {
        return levelWithCondition(condition: condition, range: Spellbook.MAX_SPELL_LEVEL...Spellbook.MIN_SPELL_LEVEL)
    }

    func minLevelWithSlots() -> Int {
        return minLevelWithCondition(condition: self.hasSlots)
    }

    func maxLevelWithSlots() -> Int {
        return maxLevelWithCondition(condition: self.hasSlots)
    }

    func minLevelWithAvailableSlots() -> Int {
        return minLevelWithCondition(condition: self.hasAvailableSlots)
    }

    func maxLevelWithAvailableSlots() -> Int {
        return maxLevelWithCondition(condition: self.hasAvailableSlots)
    }

    func nextAvailableSlotLevel(baseLevel: Int) -> Int {
        return levelWithCondition(condition: self.hasAvailableSlots, range: baseLevel...Spellbook.MAX_SPELL_LEVEL)
    }

    func toSION() -> SION {
        var sion: SION = [:]
        sion[SpellSlotStatus.totalSlotsKey].array = totalSlots.map { SION($0) }
        sion[SpellSlotStatus.usedSlotsKey].array = usedSlots.map { SION($0) }
        return sion
    }

}
