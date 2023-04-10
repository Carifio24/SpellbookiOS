//
//  SpellSlotCell.swift
//  Spellbook
//
//  Created by Mac Pro on 3/30/23.
//  Copyright © 2023 Jonathan Carifio. All rights reserved.
//

import UIKit

class SpellSlotCell: UITableViewCell {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var levelLabel: UILabel!
    
    let level: Int = -1
    let totalSlots: Int = 0
    
    func setUpCheckboxes() {
        for _ in 1...totalSlots {
            let checkbox = UISwitch()
            if #available(iOS 14.0, *) {
                checkbox.preferredStyle = UISwitch.Style.checkbox
            } else {
                checkbox.preferredStyle = UISwitch.Style.checkbox
            }
        }
    }
}
