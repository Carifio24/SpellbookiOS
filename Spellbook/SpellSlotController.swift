//
//  SpellSlotController.swift
//  Spellbook
//
//  Created by Mac Pro on 8/31/22.
//  Copyright © 2022 Jonathan Carifio. All rights reserved.
//

import UIKit

class SpellSlotController: UIViewController {
    
    let spellSlotStatus: SpellSlotStatus
    
    required init?(coder: NSCoder) {
        self.spellSlotStatus = SpellSlotStatus()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
