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
    
    var level: Int = 0 {
        didSet {
            updateLabelText()
            resetCheckboxes()
        }
    }
    
    var checkboxes: [Checkbox] = []
    
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?,
         level: Int) {
        self.level = level
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        updateLabelText()
        setUpCheckboxes()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    func updateLabelText() {
        levelLabel.text = "Level \(level):"
    }
    
    func setUpCheckboxes() {
        if (level <= 0) { return }
        guard let profile = store.state.profile else { return }
        let status = profile.spellSlotStatus
        let usedSlots = status.getUsedSlots(level: level)
        if (status.getTotalSlots(level: level) == 0) {
            return
        }
        for i in 1...status.getTotalSlots(level: level) {
            let checkbox = Checkbox(frame: CGRect(x: 50, y: 50, width: 25, height: 25))
            checkbox.borderStyle = .square
            checkbox.checkedBorderColor = .black
            checkbox.uncheckedBorderColor = .black
            checkbox.checkboxFillColor = .black
            checkbox.isChecked = i <= usedSlots
            stackView.addArrangedSubview(checkbox)
            checkboxes.append(checkbox)
        }
    }
    
    func emptyCheckboxes() {
        checkboxes.forEach({checkbox in
            stackView.removeArrangedSubview(checkbox)
        })
        checkboxes = []
    }
    
    func resetCheckboxes() {
        emptyCheckboxes()
        setUpCheckboxes()
    }
}

