//
//  SpellSlotsManagerItem.swift
//  Spellbook
//
//  Created by Mac Pro on 4/16/23.
//  Copyright © 2023 Jonathan Carifio. All rights reserved.
//

import UIKit
import ReSwift

class SpellSlotsManagerCell: UICollectionViewCell {

    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var slotsTextField: UITextField!
    
    var slotsTextFieldDelegate: UITextFieldDelegate?
    
    var level: Int = 0 {
        didSet {
            setup()
            setLabelText()
            setTextField()
            resetSubscription()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("From frame")
        setup()
    }
    
    required init?(coder: NSCoder) {
        print("From coder")
        super.init(coder: coder)
    }
    
    private func setup() {
        resetSubscription()
        
        let slots = store.state.profile?.spellSlotStatus.getTotalSlots(level: self.level) ?? 0
        slotsTextField.text = String(slots)
        slotsTextFieldDelegate = NumberFieldDelegate<EditTotalSpellSlotsAction>(
            maxCharacters: 1,
            actionCreator: { (value) in return EditTotalSpellSlotsAction(level: self.level, totalSlots: value) }
        )
        slotsTextField.delegate = slotsTextFieldDelegate
    }
    
    private func setTextField() {
        guard let profile = store.state.profile else { return }
        slotsTextField.text = String(profile.spellSlotStatus.getTotalSlots(level: level))
    }
    
    private func setLabelText() {
        levelLabel.text = "Level \(level):"
    }
    
    private func resetSubscription() {
        store.unsubscribe(self)
        if (self.level <= 0) {
            return
        }
        store.subscribe(self) {
            $0.select {
                $0.profile?.spellSlotStatus.totalSlots[self.level - 1]
            }
        }
    }

}

extension SpellSlotsManagerCell: StoreSubscriber {
    typealias StoreSubscriberStateType = Int?
    
    func newState(state: StoreSubscriberStateType) {
        setTextField()
    }

}
