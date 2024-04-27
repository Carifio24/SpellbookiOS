//
//  SpellListExporter.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 4/24/24.
//  Copyright © 2024 Jonathan Carifio. All rights reserved.
//

import Foundation

protocol SpellListExporter {
    var title: String? { get set }
    var expanded: Bool { get }
    func titleText() -> String
    func addSpells(spells: [Spell])
    func spellNameText(_ spell: Spell) -> String
    func ordinalSchoolText(_ spell: Spell) -> String
    func promptText(prompt: String, text: String) -> String
    func promptText(prompt: String, text: String, lineBreak: Bool) -> String
    func export(stream: OutputStream)
}

extension SpellListExporter {
    func lineBreak() -> String {
        return "\n";
    }
    
    func locationText(_ spell: Spell) -> String {
         return spell.locations.map { $0.key.code.uppercased() + " " + String($0.value) }.joined(separator: ", ")
    }
    
    func textForSpell(spell: Spell) -> String {
        var text = ""
        let line = lineBreak()
        text.append(line)
        text.append(spellNameText(spell))
        text.append(line)
        text.append(spell.levelSchoolString())
        if (expanded) {
            text.append(line)
            text.append(promptText(prompt: "Location", text: locationText(spell)))
            text.append(line)
            text.append(promptText(prompt: "Concentration", text: bool_to_yn(yn: spell.concentration)))
            text.append(line)
            text.append(promptText(prompt: "Casting Time", text: spell.castingTime.string()))
            text.append(line)
            text.append(promptText(prompt: "Range", text: spell.range.string()))
            text.append(line)
            text.append(promptText(prompt: "Components", text: spell.componentsString()))
            text.append(line)
            if !spell.materials.isEmpty {
                text.append(promptText(prompt: "Materials", text: spell.materials))
                text.append(line)
            }
            if !spell.royalty.description.isEmpty {
                text.append(promptText(prompt: "Royalty", text: <#T##String#>))
                text.append(line)
            }
            text.append(promptText(prompt: "Duration", text: spell.duration.string()))
            text.append(line)
            text.append(promptText(prompt: "Classes", text: spell.classesString()))
            text.append(line)
            if !spell.tashasExpandedClasses.isEmpty {
                text.append(promptText(prompt: "TCE Expanded Classes", text: spell.tashasExpandedClassesString()))
                text.append(line)
            }
            text.append(promptText(prompt: "Description", text: spell.description, lineBreak: true))
            if !spell.higherLevel.isEmpty {
                text.append(line)
                text.append(promptText(prompt: "At Higher Levels", text: spell.higherLevel, lineBreak: true))
            }
        }
        text.append(line)
        return text
    }
    
    func export(stream: OutputStream) {
        var text = titleText()
        text.append(lineBreak())
    }
}
