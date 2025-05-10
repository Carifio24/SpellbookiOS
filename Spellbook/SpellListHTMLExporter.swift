//
//  SpellListHTMLExporter.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 5/10/25.
//  Copyright © 2025 Jonathan Carifio. All rights reserved.
//

import Foundation

class SpellListHTMLExporter: SpellListExporter {
    private var string: String = ""
    var title = ""
    var spells: [Spell] = []
    var expanded: Bool = true
    
    init(expanded: Bool = true) {
        self.expanded = expanded
    }
    
    private func addText(_ text: String) {
        self.string.append(text)
    }
    
    func addLineBreak() {}
    
    func addTitleText(_ title: String) {
        self.addText("<h1>\(title)</h1>")
    }
    
    func addSpellNameText(_ name: String) {
        self.addText("<h2>\(name)</h2>")
    }
    
    func addPromptText(prompt: String, text: String, lineBreak: Bool) {
        let line = lineBreak ? "<br>" : ""
        let toAdd = "<div><strong>\(prompt):</strong>\(line) \(text)</div>"
        self.addText(toAdd)
    }
    
    func addPromptText(prompt: String, text: String) {
        self.addPromptText(prompt: prompt, text: text, lineBreak: false)
    }
    
    func addOrdinalSchoolText(level: Int, school: School, ritual: Bool) {
                var description: String = ""
        if (level == 0) {
            description.append("\(school.displayName) cantrip")
        } else {
            let ordinalString = ordinal(number: level)
            description.append("\(ordinalString)-level \(school.displayName.lowercased())")
        }
        if ritual {
            description.append(" (ritual)")
        }
        
        let toAdd = "<h4>\(description)</h4>"
        self.addText(toAdd)
    }
    
    var data: Data {
        get {
            return Data(self.string.utf8)
        }
    }
}
