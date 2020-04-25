//
//  RitualConcentrationFilterDelegate.swift
//  Spellbook
//
//  Created by Mac Pro on 4/3/20.
//  Copyright © 2020 Jonathan Carifio. All rights reserved.
//

import UIKit

class YesNoFilterDelegate: NSObject, FilterGridProtocol {
    
    typealias StatusToggler = (CharacterProfile, Bool) -> Void
    typealias StatusGetter = (CharacterProfile, Bool) -> Bool
    
    static let reuseIdentifier = "filterCell"
    private static let defaultWidth: CGFloat = 0.5 * (UIScreen.main.bounds.size.width - 10) - 5
    let main = Controllers.mainController
    let items = YesNo.allCases.map({ $0 })
    let columns: Int
    let rows: Int
    private let gridWidth: CGFloat
    private let columnWidth: CGFloat
    private let rowHeight: CGFloat = FilterView.imageHeight
    private var itemButtonMap: [Bool:ToggleButton] = [:]
    private let statusToggler: StatusToggler
    private let statusGetter: StatusGetter
    private let sectionInsets = UIEdgeInsets(top: 5,
                                     left: 5,
                                     bottom: 5,
                                     right: 5)
    
    init(statusGetter: @escaping StatusGetter, statusToggler: @escaping StatusToggler, gridWidth: CGFloat) {
        self.gridWidth = gridWidth
        self.statusToggler = statusToggler
        self.statusGetter = statusGetter
        
        // We want to determine whether we need 1 row or two
        // Since our only options are "Yes" or "No" for the item text,
        // we can do things a bit more simply that in the more generic FilterGridDelegate
        // as "Yes" will be the longer options
        let label = UILabel()
        label.text = "Yes"
        label.sizeToFit()
        let maxWidth = label.frame.size.width + FilterView.imageWidth
            
        // To find the number of columns, we find the largest solution to
        // n * maxWidth + (n + 1) * horizontalSpacing <= gridWidth
        let horizontalSpacing = self.sectionInsets.left
        columns = Int(floor( (gridWidth - horizontalSpacing) / (maxWidth + horizontalSpacing) ))
        rows = Int(ceil(Double(self.items.count) / Double(columns)))
        
        // Determine the width of each column
        let usableWidth = gridWidth - CGFloat(columns + 1) * horizontalSpacing
        let maxAllowedWidth = usableWidth / CGFloat(columns)
        columnWidth = (maxWidth + maxAllowedWidth) / 2
        
    }
    
    convenience init(statusGetter: @escaping StatusGetter, statusToggler: @escaping StatusToggler) {
        self.init(statusGetter: statusGetter, statusToggler: statusToggler, gridWidth: YesNoFilterDelegate.defaultWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: FilterCell = collectionView.dequeueReusableCell(withReuseIdentifier: YesNoFilterDelegate.reuseIdentifier, for: indexPath) as! FilterCell
        let item = items[indexPath.row]
        let bool = item.bool
        cell.backgroundColor = .clear
        cell.filterView.nameLabel.text = item.displayName
        cell.filterView.filterButton.isUserInteractionEnabled = true
        //cell.filterView.nameLabel.sizeToFit()
        
        cell.filterView.filterButton.set(statusGetter(main.characterProfile, bool))
        cell.filterView.filterButton.setCallback({
            self.statusToggler(self.main.characterProfile, bool)
            self.main.saveCharacterProfile()
          })
        //cell.backgroundColor = UIColor.systemPink
        itemButtonMap[bool] = cell.filterView.filterButton
        return cell
    }
    
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
        //print("There are \(rows) rows, each with height \(rowHeight)")
        let height = CGFloat(rows + 1) * sectionInsets.top + CGFloat(rows) * rowHeight
        //print("The desired height is \(height)")
        return height
    }
    
    func desiredWidth() -> CGFloat {
        let width = CGFloat(columns + 1) * sectionInsets.left + CGFloat(columns) * columnWidth
        return width
    }
    
    func buttonForItem(_ b: Bool) -> ToggleButton? { return itemButtonMap[b] }
    func buttonForItem(_ t: YesNo) -> ToggleButton? { return buttonForItem(t.bool) }
    
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
    
    

}
