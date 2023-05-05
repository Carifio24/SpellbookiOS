//
//  SpellSlotCell.swift
//  Spellbook
//
//  Created by Mac Pro on 3/30/23.
//  Copyright © 2023 Jonathan Carifio. All rights reserved.
//

import UIKit
import SimpleCheckbox
import ReSwift

class SpellSlotCell: UITableViewCell {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var levelLabel: UILabel!
    
    var level: Int = 0 {
        didSet {
            setup()
            resetSubscription()
        }
    }
    
    var checkboxes: [Checkbox] = []
    
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?,
         level: Int) {
        self.level = level
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    func setup() {
        updateLabelText()
        resetCheckboxes()
    }
    
    func updateLabelText() {
        levelLabel.text = "Level \(level):"
    }
    
    func checkedCount() -> Int {
        checkboxes.filter({ box in return box.isChecked }).count
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
            let heightConstraint = checkbox.heightAnchor.constraint(equalToConstant: 30)
            let widthConstraint = checkbox.widthAnchor.constraint(equalToConstant: 30)
            heightConstraint.isActive = true
            widthConstraint.isActive = true
            checkbox.borderStyle = .square
            checkbox.checkmarkStyle = .tick
            checkbox.checkmarkColor = .black
            checkbox.checkedBorderColor = .black
            checkbox.uncheckedBorderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
            checkbox.isChecked = i <= usedSlots
            
            checkbox.valueChanged = { isChecked in
                if (isChecked) {
                    store.dispatch(UseSpellSlotAction(level: self.level))
                } else {
                    store.dispatch(GainSpellSlotAction(level: self.level))
                }
            }
            
            stackView.addArrangedSubview(checkbox)
            checkboxes.append(checkbox)
        }
    }
    
    func resetSubscription() {
        store.unsubscribe(self)
        if (self.level <= 0) {
            return
        }
        store.subscribe(self) {
            $0.select {
                $0.profile?.spellSlotStatus.totalSlots
            }
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

extension SpellSlotCell: StoreSubscriber {
    typealias StoreSubscriberStateType = [Int]?
    
    func newState(state: StoreSubscriberStateType) {
        setup()
    }
}
