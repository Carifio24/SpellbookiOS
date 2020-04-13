//
//  FilterGridDelegate.swift
//  Spellbook
//
//  Created by Mac Pro on 4/2/20.
//  Copyright © 2020 Jonathan Carifio. All rights reserved.
//

import UIKit

class FilterGridDelegate<T:NameConstructible>: NSObject, UICollectionViewDataSourceDelegate, UICollectionViewDelegateFlowLayout {
    

    let reuseIdentifier = "filterCell"
    
    let items = T.allCases.map({ $0 })
    private var itemButtonMap: [T:ToggleButton] = [:]
    let columns: Int
    let rows: Int
    private let gridWidth: CGFloat
    private let columnWidth: CGFloat
    private let rowHeight: CGFloat = FilterView.imageHeight
    private let main = Controllers.mainController
    private let sectionInsets = UIEdgeInsets(top: 5,
                                     left: 5,
                                     bottom: 5,
                                     right: 5)
    
    init(gridWidth: CGFloat) {
        
        self.gridWidth = gridWidth
        
        // Determine the number of rows and columns of the grid, based on the grid width
        // Since all of our grids have fixed size, this is all that we need
        // But this process could be easily adjusted for a fixed-height grid as well
        var maxWidth: CGFloat = 0
        let label = UILabel()
        for item in items {
            label.text = item.displayName
            label.sizeToFit()
            let width = label.frame.size.width
            if width > maxWidth {
                maxWidth = width
            }
        }
        maxWidth = maxWidth + FilterView.imageWidth
        
        // To find the number of columns, we find the largest solution to
        // n * maxWidth + (n + 1) * horizontalSpacing <= gridWidth
        let horizontalSpacing = sectionInsets.left
        columns = Int(floor( (gridWidth - horizontalSpacing) / (maxWidth + horizontalSpacing) ))
        rows = Int(ceil(Double(items.count) / Double(columns)))
        
        // Determine the width of each column
        let usableWidth = gridWidth - CGFloat(columns + 1) * horizontalSpacing
        columnWidth = usableWidth / CGFloat(columns)
    }
    
    override convenience init() {
        self.init(gridWidth: UIScreen.main.bounds.size.width - CGFloat(10))
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
        cell.filterView.filterButton.isUserInteractionEnabled = true
        //cell.filterView.nameLabel.sizeToFit()
        //print("Item is \(item.displayName)")
        //print("Visibility is \(main.characterProfile.getVisibility(item))")
        cell.filterView.filterButton.set(main.characterProfile.getVisibility(item))
        cell.filterView.filterButton.setCallback({
            self.main.characterProfile.toggleVisibility(item)
            print(self.main.characterProfile.getVisibility(item))
            self.main.saveCharacterProfile()
        })
        cell.filterView.filterButton.setLongPressCallback({
            for (value, button) in self.itemButtonMap {
                if (value != item && button.state()) {
                    button.sendActions(for: .touchUpInside)
                }
            }
        })
        itemButtonMap[item] = cell.filterView.filterButton
        cell.backgroundColor = UIColor.systemPink
        //print("Exiting cellForItemAt: row \(indexPath.row)")
        return cell
    }
    
    func buttonForItem(_ t: T) -> ToggleButton? { return itemButtonMap[t] }
    
    func collectionView(_ collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout,
            sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: columnWidth, height: FilterView.imageHeight)
        
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
    
    func desiredHeight() -> CGFloat {
        print("There are \(rows) rows, each with height \(rowHeight)")
        let height = CGFloat(rows + 1) * sectionInsets.top + CGFloat(rows) * rowHeight
        print("The desired height is \(height)")
        return height
    }
    

//    func collectionView(_ collectionView: UICollectionView,
//        layout collectionViewLayout: UICollectionViewLayout,
//        sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
//        let totalSpace = flowLayout.sectionInset.left
//          + flowLayout.sectionInset.right
//          + (flowLayout.minimumInteritemSpacing * CGFloat(columns - 1))
//        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(columns))
//        let width = 50
//        let height = 30
//        print(size)
//        print(collectionView.frame.size.width)
//        print(collectionView.frame.size.height)
//        print("======")
//        return CGSize(width: width, height: height)
//    }
//
    
    
}
