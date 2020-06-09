//
//  FilterGridDelegate.swift
//  Spellbook
//
//  Created by Mac Pro on 4/2/20.
//  Copyright © 2020 Jonathan Carifio. All rights reserved.
//

import UIKit

class FilterGridDelegate<T:NameConstructible>: NSObject, FilterGridProtocol {
    
    let reuseIdentifier = "filterCell"
    
    let items = T.allCases.map({ $0 })
    private var itemButtonMap: [T:ToggleButton] = [:]
    let columns: Int
    let rows: Int
    var centered: Bool
    private let gridWidth: CGFloat
    private let columnWidth: CGFloat
    private let rowHeight: CGFloat = FilterView.imageHeight
    private let unfilledRowWidth: CGFloat
    private let main = Controllers.mainController
    private let sectionInsets = UIEdgeInsets(top: 5,
                                     left: 5,
                                     bottom: 5,
                                     right: 5)
    
    
    init(gridWidth: CGFloat, centered: Bool = false) {
        
        self.gridWidth = gridWidth
        self.centered = centered
        
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
        let maxColumns = Int(floor( (gridWidth - horizontalSpacing) / (maxWidth + horizontalSpacing) ))
        columns = max(min(maxColumns, items.count), 1)
        rows = Int(ceil(Double(items.count) / Double(columns)))
        
        // Determine the width of each column
        //let usableWidth = gridWidth - CGFloat(columns + 1) * horizontalSpacing
        //let maxAllowedWidth = usableWidth / CGFloat(columns)
        //columnWidth = (maxWidth + maxAllowedWidth) / 2
        //columnWidth = maxAllowedWidth
        columnWidth = maxWidth
        
        if (centered) {
            let unfilledCount = rows * columns - items.count
            unfilledRowWidth = maxWidth * CGFloat(unfilledCount) / CGFloat(columns)
        } else {
            unfilledRowWidth = columnWidth
        }
        
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
            self.main.saveCharacterProfile()
        })
        cell.filterView.filterButton.setLongPressCallback({
            if !cell.filterView.filterButton.isSet() { cell.filterView.filterButton.sendActions(for: .touchUpInside) }
            for (value, button) in self.itemButtonMap {
                if (value != item && button.isSet()) {
                    button.sendActions(for: .touchUpInside)
                }
            }
        })
        itemButtonMap[item] = cell.filterView.filterButton
        //cell.backgroundColor = UIColor.systemPink
        //print("Exiting cellForItemAt: row \(indexPath.row)")
        return cell
    }
    
    func buttonForItem(_ t: T) -> ToggleButton? { return itemButtonMap[t] }
    func buttons() -> [ToggleButton] { return Array(itemButtonMap.values) }
    
    func setAll(_ tf: Bool) {
        for (_, button) in itemButtonMap {
            if button.isSet() != tf {
                button.sendActions(for: .touchUpInside)
            }
        }
    }
    @objc func selectAll() { setAll(true) }
    @objc func unselectAll() { setAll(false) }
    
    func collectionView(_ collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout,
            sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // If we're using centering and are on the last row (and it isn't filled), use the unfilled row width
        // Otherwise, just the standard column width
        var width = columnWidth
        if (centered) {
            let unfilledWidthNeeded = indexPath.row * columns > items.count
            if (unfilledWidthNeeded) {
                width = unfilledRowWidth
            }
        }
        return CGSize(width: width, height: FilterView.imageHeight)
        
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
        //print("There are \(rows) rows, each with height \(rowHeight)")
        let height = CGFloat(rows + 1) * sectionInsets.top + CGFloat(rows) * rowHeight
        //print("The desired height is \(height)")
        return height
    }
    
    func desiredWidth() -> CGFloat {
        let width = CGFloat(columns + 1) * sectionInsets.left + CGFloat(columns) * columnWidth
        return width
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

class FilterGridRangeDelegate<T:QuantityType>: FilterGridDelegate<T> {
    
    typealias FlagSetter = (Bool) -> Void
    
    var flagSetter: FlagSetter
    
    init(gridWidth: CGFloat, flagSetter: @escaping FlagSetter) {
        self.flagSetter = flagSetter
        super.init(gridWidth: gridWidth)
    }
    
    convenience init(flagSetter: @escaping FlagSetter) {
        self.init(gridWidth: UIScreen.main.bounds.size.width - CGFloat(10), flagSetter: flagSetter)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! FilterCell
        if items[indexPath.row] == T.spanningType {
            let spanningButton = cell.filterView.filterButton!
            let oldCallback = spanningButton.getCallback()
            flagSetter(spanningButton.isSet())
            spanningButton.setCallback({
                oldCallback()
                self.flagSetter(spanningButton.isSet())
            })
        }
        return cell
    }
    
    
}
