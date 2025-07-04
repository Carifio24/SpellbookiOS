//
//  SpellListMarkdownExporter.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 5/9/25.
//  Copyright © 2025 Jonathan Carifio. All rights reserved.
//

import Foundation

class SpellListMarkdownExporter: SpellListExporter {
    
    private var string: String = ""
    var title = ""
    var spells: [Spell] = []
    var expanded: Bool = true
    
    private static func headerString(level: Int) -> String {
        return String.init(repeating: "#", count: level)
    }
    
    init(expanded: Bool = true) {
        self.expanded = expanded
    }
    
    private func addText(_ text: String) {
        self.string.append(text)
    }
    
    func addLineBreak() {
        self.addText("\n")
    }
    
    func addTitleText(_ title: String) {
        let toAdd = "\(SpellListMarkdownExporter.headerString(level: 1)) \(title)"
        self.addText(toAdd)
    }
    
    func addSpellNameText(_ name: String) {
        let toAdd = "\(SpellListMarkdownExporter.headerString(level: 2)) \(name)"
        self.addText(toAdd)
    }
    
    func addPromptText(prompt: String, text: String, lineBreak: Bool) {
        let line = lineBreak ? "\n" : ""
        let toAdd = "* **\(prompt):**\(line) \(text)"
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
        
        let toAdd = "\(SpellListMarkdownExporter.headerString(level: 3)) *\(description)*"
        self.addText(toAdd)
    }
    
    var data: Data {
        get {
            return Data(self.string.utf8)
        }
    }
    
    func export(path: URL) async {
        self.addTitleText(title)
        self.addLineBreak()
        self.spells.forEach(self.addTextForSpell)
        do {
            try self.data.write(to: path)
        } catch let e {
            print("\(e)")
        }
    }
    
}
