//
//  SpellSlotsManagerDelegate.swift
//  Spellbook
//
//  Created by Mac Pro on 4/22/23.
//  Copyright © 2023 Jonathan Carifio. All rights reserved.
//

import UIKit

class SpellSlotsManagerDelegate: NSObject, UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout {
    
    fileprivate static let sectionInsets = UIEdgeInsets(
                                        top: 5,
                                        left: 5,
                                        bottom: 5,
                                        right: 5)
    
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
        return SpellSlotsManagerDelegate.sectionInsets
    }

    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return SpellSlotsManagerDelegate.sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return SpellSlotsManagerDelegate.sectionInsets.top
    }

    func collectionView(_ collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout,
            sizeForItemAt indexPath: IndexPath) -> CGSize {
        let insets = SpellSlotsManagerDelegate.sectionInsets
        let cellWidth = collectionView.frame.width / 3 - insets.left - insets.right
        return CGSize(width: cellWidth, height: 50)
    }

}
