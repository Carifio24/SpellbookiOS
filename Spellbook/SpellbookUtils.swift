//
//  SpellbookUtils.swift
//  Spellbook
//
//  Created by Mac Pro on 5/28/23.
//  Copyright © 2023 Jonathan Carifio. All rights reserved.
//

import Foundation

func complement<T>(items: [T], allItems: [T]) -> [T] where T: Equatable {
    return allItems.filter { !items.contains($0) }
}


