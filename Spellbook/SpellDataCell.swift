//
//  SpellDataCell.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 11/27/18.
//  Copyright © 2018 Jonathan Carifio. All rights reserved.
//

import UIKit

class SpellDataCell: UITableViewCell {
    
    // The labels
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var levelSchoolLabel: UILabel!
    @IBOutlet weak var sourcebookLabel: UILabel!
    @IBOutlet weak var favoriteButton: ToggleButton!
    @IBOutlet weak var knownButton: ToggleButton!
    @IBOutlet weak var preparedButton: ToggleButton!
    
    // A variable to hold the spell
    var spell: Spell = Spell()
    
}
