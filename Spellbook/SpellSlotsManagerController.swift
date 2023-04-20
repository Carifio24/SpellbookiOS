//
//  SpellSlotsManagerController.swift
//  Spellbook
//
//  Created by Mac Pro on 4/15/23.
//  Copyright © 2023 Jonathan Carifio. All rights reserved.
//

import UIKit

class SpellSlotsManagerController: UIViewController,
                                   UICollectionViewDelegate,
                                   UICollectionViewDataSource {

    @IBOutlet weak var managerGrid: UICollectionView!
    
    fileprivate let sectionInsets = UIEdgeInsets(
                                        top: 5,
                                        left: 5,
                                        bottom: 5,
                                        right: 5)
    
    static let reuseIdentifier = "spellSlotsManagerIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        managerGrid.delegate = self
        managerGrid.dataSource = self
    }
    
    
    // MARK: - Collection View Data Source/Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Spellbook.MAX_SPELL_LEVEL
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: SpellSlotsManagerCell = collectionView.dequeueReusableCell(withReuseIdentifier: SpellSlotsManagerController.reuseIdentifier, for: indexPath) as! SpellSlotsManagerCell
        cell.level = indexPath.row + 1
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
      return sectionInsets
    }

    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
      return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.top
    }

}
