//
//  SpellListMarkdownExporter.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 4/25/24.
//  Copyright © 2024 Jonathan Carifio. All rights reserved.
//

import Foundation

class SpellListMarkdownExporter: SpellListExporter {
    
    var expanded: Bool = true
    var title: String? = nil
    private var spells: [Spell] = []
    
    private static func headerString(_ level: Int) -> String {
        return String(repeating: "#", count: level)
    }
    
    func titleText() -> String {
        return "\(SpellListMarkdownExporter.headerString(1)) \(title ?? "")"
    }
    
    func addSpells(spells: [Spell]) {
        self.spells.append(contentsOf: spells)
    }
    
    func spellNameText(_ spell: Spell) -> String {
        return "\(SpellListMarkdownExporter.headerString(2)) \(spell.name)"
    }
    
    func ordinalSchoolText(_ spell: Spell) -> String {
        return "\(SpellListMarkdownExporter.headerString(3)) *\(spell.levelSchoolString()))*"
    }
    
    func promptText(prompt: String, text: String, lineBreak: Bool) -> String {
        let line = lineBreak ? "\n" : ""
        return "* **\(prompt):**\(line) \(text)"
    }
    
    func promptText(prompt: String, text: String) -> String {
        return promptText(prompt: prompt, text: text, lineBreak: false)
    }
}
