//
//  ConfirmNextAvailableCastController.swift
//  Spellbook
//
//  Created by Mac Pro on 10/23/23.
//  Copyright © 2023 Jonathan Carifio. All rights reserved.
//

import UIKit

class ConfirmNextAvailableCastController: UIViewController {
    
    @IBOutlet weak var availableCastMessage: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    var spell: Spell?
    var level: Int = 0
    
    // TODO: What's a better way to do this?
    var toastController: UIViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // We should never be here without an assigned profile
        let name = store.state.profile?.name ?? ""
        let baseLevel = spell?.level ?? 0
        
        availableCastMessage.text = "\(name) has no slots of level \(baseLevel) remaining. Would you like to use a slot of level \(level)?"
        
        noButton.addTarget(self, action: #selector(noButtonPressed), for: UIControl.Event.touchUpInside)
        yesButton.addTarget(self, action: #selector(yesButtonPressed), for: UIControl.Event.touchUpInside)

        // Do any additional setup after loading the view.
    }
    
    @objc func noButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func yesButtonPressed() {
        self.dismiss(animated: true, completion: { () -> Void in
            
            if self.level == 0 {
                return
            }
            if let spell = self.spell {
                store.dispatch(CastSpellAction(level: self.level))
                
                let message = "\(spell.name) was cast at level \(self.level)"
                let controller = self.toastController ?? (self.parent ?? self)
                Toast.makeToast(message, controller: controller)
            }
        })
    }
    
}


