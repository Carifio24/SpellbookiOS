//
//  SpellListPDFExporter.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 5/10/25.
//  Copyright © 2025 Jonathan Carifio. All rights reserved.
//

import Foundation

class SpellListPDFExporter: SpellListHTMLExporter {
    func export(path: URL) {
        do {
            try self.string.print(to: path)
        } catch let e {
            print("\(e)")
        }
    }
}
