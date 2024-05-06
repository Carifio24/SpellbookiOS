//
//  SpellListHTMLExporter.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 4/26/24.
//  Copyright © 2024 Jonathan Carifio. All rights reserved.
//

import Foundation

class SpellListHTMLExporter: SpellListExporter {
    
    var expanded: Bool = true
    var title: String? = nil
    var spells: [Spell] = []
    
    init(expanded: Bool) {
        self.expanded = expanded
    }
    
    func titleText() -> String {
        return "<h1>\(title ?? "")</h1>"
    }
    
    func addSpells(spells: [Spell]) {
        self.spells.append(contentsOf: spells)
    }
    
    func spellNameText(_ spell: Spell) -> String {
        return "<h2>\(spell.name)</h2>"
    }
    
    func ordinalSchoolText(_ spell: Spell) -> String {
        return "<h4>\(spell.levelSchoolString())</h4>"
    }
    
    func promptText(prompt: String, text: String, lineBreak: Bool) -> String {
        let line = lineBreak ? "<br>" : ""
        return "<div><strong>\(prompt):</strong>\(line) \(text)</div>"
    }
    
    func promptText(prompt: String, text: String) -> String {
        return promptText(prompt: prompt, text: text, lineBreak: false)
    }
}
