//
//  SpellStatus.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 4/15/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import Foundation

class SpellStatus {
    
    // Member values
    private(set) var favorite: Bool = false;
    private(set) var prepared: Bool = false;
    private(set) var known: Bool = false;
    
    init(favIn: Bool, prepIn: Bool, knownIn: Bool) {
        favorite = favIn
        prepared = prepIn
        known = knownIn
    }
    
    init() {}
    
    func setFavorite(favIn: Bool) { favorite = favIn }
    func setPrepared(prepIn: Bool) { prepared = prepIn }
    func setKnown(knownIn: Bool) { known = knownIn }
    
}
