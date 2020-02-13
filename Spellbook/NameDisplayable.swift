//
//  NameDisplayable.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 2/9/20.
//  Copyright © 2020 Jonathan Carifio. All rights reserved.
//

import Foundation

protocol NameDisplayable : CaseIterable, Hashable {
    var displayName: String { get }
}
