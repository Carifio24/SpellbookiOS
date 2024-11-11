//
//  NamedItemHandler.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 11/11/24.
//  Copyright © 2024 Jonathan Carifio. All rights reserved.
//

import Foundation

protocol NamedItemEventDelegate {
    func onUpdateEvent(_ name: String)
    func onDuplicateEvent(_ name: String)
    func onDeleteEvent(_ name: String)
    func onExportEvent(_ name: String)
    func onCopyEvent(_ name: String)
    func onSelectionEvent(_ name: String)
}
