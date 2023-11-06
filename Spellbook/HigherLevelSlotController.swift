//
//  HigherLevelSlotController.swift
//  Spellbook
//
//  Created by Mac Pro on 10/14/23.
//  Copyright © 2023 Jonathan Carifio. All rights reserved.
//

import UIKit

import ReSwift

class HigherLevelSlotController: UIViewController {
    
    @IBOutlet weak var slotLevelChooser: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var castButton: UIButton!
    
    var spell: Spell?
    var textDelegate: TextFieldChooserDelegate<GenericSpellbookAction, Int>?
    
    // TODO: What's a better way to do this?
    var toastController: UIViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: UIControl.Event.touchUpInside)
        castButton.addTarget(self, action: #selector(castButtonPressed), for: UIControl.Event.touchUpInside)
        
        guard let spell = self.spell else { return }
        guard let profile = store.state.profile else { return }
        let status = profile.spellSlotStatus
        let baseLevel = spell.level
        let maxLevel = status.maxLevelWithSlots()
        let range = baseLevel...maxLevel
        
        let initialLevel = status.minLevelWithCondition(condition: { level in
            return status.hasAvailableSlots(level: level) && level >= baseLevel
        })

        // TODO: It's kind of gross to need to use this dummy type
        // It feels like a refactor of the delegate is necessary
        self.textDelegate = TextFieldChooserDelegate<GenericSpellbookAction, Int>(
            items: Array(range),
            title: "Select Slot Level",
            itemProvider: { () in return initialLevel },
            nameGetter: ordinal,
            textSetter: ordinal,
            nameConstructor: { valueFrom(ordinal: $0) ?? 0 },
            itemFilter: { level in return status.hasAvailableSlots(level: level) }
        )

        slotLevelChooser.text = ordinal(number: initialLevel)
        slotLevelChooser.delegate = self.textDelegate!
    }
    
    @objc func cancelButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func castButtonPressed() {
        guard let spell = self.spell else { return }
        if let text = slotLevelChooser.text {
            if let level = valueFrom(ordinal: text) {
                store.dispatch(CastSpellAction(level: level))
                let message = "\(spell.name) was cast at level \(level)"
                let controller = self.toastController ?? (self.parent ?? self)
                Toast.makeToast(message, controller: controller)
            }
        }

        self.dismiss(animated: true, completion: nil)
    }

}
