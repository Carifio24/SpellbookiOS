//
//  SpellListPDFExporter.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 5/10/25.
//  Copyright © 2025 Jonathan Carifio. All rights reserved.
//

import Foundation
import HtmlToPdf

class SpellListPDFExporter: SpellListHTMLExporter {
    override func export(path: URL) async {
        self.addTitleText(title)
        self.addLineBreak()
        self.spells.forEach(self.addTextForSpell)
        do {
            try await self.string.print(to: path)
        } catch let e {
            print("\(e)")
        }
    }
}
