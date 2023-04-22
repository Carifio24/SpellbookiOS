//
//  SpellSlotsManagerController.swift
//  Spellbook
//
//  Created by Mac Pro on 4/15/23.
//  Copyright © 2023 Jonathan Carifio. All rights reserved.
//

import UIKit

class SpellSlotsManagerController: UIViewController {

    @IBOutlet weak var managerGrid: UICollectionView!
    
    static let reuseIdentifier = "spellSlotsManagerIdentifier"
    private var delegate = SpellSlotsManagerDelegate()
    private var cellWidth: CGFloat = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(self.delegate)
        managerGrid.delegate = self.delegate
        managerGrid.dataSource = self.delegate
    }
    
}
