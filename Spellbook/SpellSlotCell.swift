//
//  SpellSlotCell.swift
//  Spellbook
//
//  Created by Mac Pro on 3/30/23.
//  Copyright © 2023 Jonathan Carifio. All rights reserved.
//

import UIKit
import SimpleCheckbox

class SpellSlotCell: UITableViewCell {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var levelLabel: UILabel!
    
    let level: Int = -1
    let totalSlots: Int = 0
    
    func setUpCheckboxes() {
        for _ in 1...totalSlots {
            let checkbox = Checkbox(frame: CGRect(x: 50, y: 50, width: 25, height: 25))
            checkbox.borderStyle = .square
            checkbox.checkedBorderColor = .black
            checkbox.uncheckedBorderColor = .black
            checkbox.checkboxFillColor = .black
        }
    }
}
