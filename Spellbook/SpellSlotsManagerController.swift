//
//  SpellSlotsManagerController.swift
//  Spellbook
//
//  Created by Mac Pro on 4/15/23.
//  Copyright © 2023 Jonathan Carifio. All rights reserved.
//

import UIKit

class SpellSlotsManagerController: UIViewController {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var managerGrid: UICollectionView!
    
    static let reuseIdentifier = "spellSlotsManagerIdentifier"
    private var delegate = SpellSlotsManagerDelegate()
    private var cellWidth: CGFloat = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        managerGrid.delegate = self.delegate
        managerGrid.dataSource = self.delegate
        closeButton.addTarget(self, action: #selector(closeAndSave), for: .touchUpInside)
    }
    
    @objc func closeAndSave() {
        store.dispatch(SaveCurrentProfileAction())
        self.dismiss(animated: true, completion: nil)
    }
    
}
