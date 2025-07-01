//
//  SpellListExporter.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 5/9/25.
//  Copyright © 2025 Jonathan Carifio. All rights reserved.
//

import Foundation

protocol SpellListExporter {
     
    var title: String { get set }
    var spells: [Spell] { get set }
    var expanded: Bool { get set }
    
    func addTitleText(_ title: String)
    func addSpellNameText(_ name: String)
    func addPromptText(prompt: String, text: String, lineBreak: Bool)
    func addPromptText(prompt: String, text: String)
    func addOrdinalSchoolText(level: Int, school: School, ritual: Bool)
    func addLineBreak()
    
    var data: Data { get }
}

extension SpellListExporter {
    
    func addTextForSpell(spell: Spell) {
        self.addLineBreak()
        self.addSpellNameText(spell.name)
        self.addLineBreak()
        self.addOrdinalSchoolText(level: spell.level, school: spell.school, ritual: spell.ritual)
        if (self.expanded) {
            self.addLineBreak()
            let locationsPrompt = spell.locations.count > 1 ? "Locations" : "Location"
            self.addPromptText(prompt: locationsPrompt, text: spell.sourcebooksString())
            self.addLineBreak()
            self.addPromptText(prompt: "Concentration", text: SerializationUtils.boolYesNo(spell.concentration))
            self.addLineBreak()
            self.addPromptText(prompt: "Casting Time", text: spell.castingTime.string())
            self.addLineBreak()
            self.addPromptText(prompt: "Range", text: spell.castingTime.string())
            self.addLineBreak()
            self.addPromptText(prompt: "Components", text: spell.componentsString())
            self.addLineBreak()
            if (spell.material) {
                self.addPromptText(prompt: "Material", text: spell.materials)
                self.addLineBreak()
            }
            if (spell.royalty) {
                self.addPromptText(prompt: "Royalty", text: spell.royalties)
                self.addLineBreak()
            }
            self.addPromptText(prompt: "Duration", text: spell.duration.string())
            self.addLineBreak()
            self.addPromptText(prompt: "Classes", text: spell.classesString())
            self.addLineBreak()
            if (!spell.tashasExpandedClasses.isEmpty) {
                self.addPromptText(prompt: "TCE Expanded Classes", text: spell.tashasExpandedClassesString())
                self.addLineBreak()
            }
            self.addPromptText(prompt: "Description", text: spell.description, lineBreak: true)
            if (!spell.higherLevel.isEmpty) {
                self.addLineBreak()
                self.addPromptText(prompt: "Higher level", text: spell.higherLevel, lineBreak: true)
            }
        }
        self.addLineBreak()
    }
    
    func export(path: URL) {
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
