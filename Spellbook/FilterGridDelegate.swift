//
//  FilterGridDelegate.swift
//  Spellbook
//
//  Created by Mac Pro on 4/2/20.
//  Copyright © 2020 Jonathan Carifio. All rights reserved.
//

import UIKit

class FilterGridDelegate<T:NameConstructible>: NSObject, UICollectionViewDataSourceDelegate, UICollectionViewDelegateFlowLayout {
    
    
    let items = T.allCases.map({ $0 })
    let reuseIdentifier = "filterCell"
    private var itemButtonMap: [T:UIButton] = [:]
    let columns: Int
    let rows: Int
    private let gridWidth: CGFloat
    let columnWidth: CGFloat
    //private let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    private let sectionInsets = UIEdgeInsets(top: 5,
                                     left: 5,
                                     bottom: 5,
                                     right: 5)
    
    private let main = Controllers.mainController
    
    init(gridWidth: CGFloat) {
        
        self.gridWidth = gridWidth
        
        // Determine the number of rows and columns
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
        
        print("The total width is \(gridWidth)")
        print("maxWidth is \(maxWidth)")
        print("horizontalSpacing is \(horizontalSpacing)")
        print("Hence, there are \(columns) columns")
        
        // Determine the width of each column
        let usableWidth = gridWidth - CGFloat(columns + 1) * horizontalSpacing
        columnWidth = usableWidth / CGFloat(columns)
        
        print("and columnWidth is \(columnWidth)")
        print("========")
    }
    
    override convenience init() {
        self.init(gridWidth: UIScreen.main.bounds.size.width - CGFloat(10))
    }
    
    
    // MARK: - Collection View Data Source/Delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("In cellForItemAt: row \(indexPath.row)")
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
        itemButtonMap[item] = cell.filterView.filterButton
        cell.backgroundColor = UIColor.systemPink
        //print("Exiting cellForItemAt: row \(indexPath.row)")
        return cell
    }
    
    func buttonForItem(_ t: T) -> UIButton? { return itemButtonMap[t] }
    
    func collectionView(_ collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout,
            sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        print("Width is \(columnWidth)")
        print("Height is \(FilterView.imageHeight)")
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
