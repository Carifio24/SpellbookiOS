//
//  ExportSpellListState.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 5/5/24.
//  Copyright © 2024 Jonathan Carifio. All rights reserved.
//

import Foundation

struct ExportSpellListState {
    var format: ExportFormat = ExportFormat.PDF
    var list: StatusFilterField = StatusFilterField.All
    var allContent: Bool = true
}
