//
//  FilterGridDelegate.swift
//  Spellbook
//
//  Created by Mac Pro on 4/2/20.
//  Copyright © 2020 Jonathan Carifio. All rights reserved.
//

import UIKit

class FilterGridDataSource<T:NameConstructible>: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private let sectionInsets = UIEdgeInsets(top: 5.0,
                                             left: 2.0,
                                            bottom: 5.0,
                                            right: 2.0)
    
    let items = T.allCases.map({ $0 })
    private var itemButtonMap: [T:UIButton] = [:]
    let reuseIdentifier: String
    private var columns: Int
    
    private let main = Controllers.mainController
    
    init(reuseIdentifier: String, columns: Int = 2) {
        self.reuseIdentifier = reuseIdentifier
        self.columns = columns
    }
    
    // MARK: - Collection View Data Source/Delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: FilterCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FilterCell
        let item = items[indexPath.row]
          cell.backgroundColor = .clear
        cell.filterView.nameLabel.text = item.displayName
        cell.filterView.filterButton.set(main.characterProfile.getVisibility(item))
        cell.filterView.filterButton.setCallback({
              self.main.characterProfile.toggleVisibility(item)
          })
        itemButtonMap[item] = cell.filterView.filterButton
        return cell
    }
    
    func getButtonForItem(_ t: T) -> UIButton? { return itemButtonMap[t] }
    

    func collectionView(_ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
          + flowLayout.sectionInset.right
          + (flowLayout.minimumInteritemSpacing * CGFloat(columns - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(columns))
        let width = 50
        let height = 30
        print(size)
        print(collectionView.frame.size.width)
        print(collectionView.frame.size.height)
        print("======")
        return CGSize(width: width, height: height)
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
    
    
}
