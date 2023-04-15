//
//  SpellSlotStatus.swift
//  Spellbook
//
//  Created by Mac Pro on 8/29/22.
//  Copyright © 2022 Jonathan Carifio. All rights reserved.
//

import Foundation

class SpellSlotStatus {
    
    private var totalSlots: [Int]
    private var usedSlots: [Int]
    
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
    
    func refillAllSlots() {
        usedSlots = usedSlots.map { _ in 0 }
    }
    
    func useSlot(level: Int) {
        usedSlots[level - 1] = min(usedSlots[level - 1] + 1, totalSlots[level - 1])
    }
    
    func gainSlot(level: Int) {
        usedSlots[level - 1] = max(usedSlots[level - 1] - 1, 0)
    }
    
    func maxLevelWithSlots() -> Int {
        for level in Spellbook.MAX_SPELL_LEVEL...1 {
            if (self.getTotalSlots(level: level) > 0) {
                return level
            }
        }
        return 0
    }
    
    func toSION() -> SION {
        var sion: SION = [:]
        sion[SpellSlotStatus.totalSlotsKey].array = totalSlots.map{ SION($0) }
        sion[SpellSlotStatus.usedSlotsKey].array = usedSlots.map{ SION($0) }
        return sion
    }
    
}
