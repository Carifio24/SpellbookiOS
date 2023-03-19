//
//  FilterGridDelegate.swift
//  Spellbook
//
//  Created by Mac Pro on 4/2/20.
//  Copyright © 2020 Jonathan Carifio. All rights reserved.
//

import UIKit
import ReSwift

fileprivate let defaultWidth: CGFloat = UIScreen.main.bounds.size.width - CGFloat(10)

class FilterGridDelegate<T:NameConstructible, A:Action>: NSObject, FilterGridProtocol {
    
    typealias ItemComparator = (T,T) -> Bool
    typealias VisibilityGetter = (T) -> Bool
    typealias ActionCreator = (T) -> A
    
    let reuseIdentifier = "filterCell"
    
    let getter: VisibilityGetter
    let actionCreator: ActionCreator
    
    fileprivate(set) var items: [T]
    private var itemButtonMap: [T:ToggleButton] = [:]
    let columns: Int
    let rows: Int
    private let gridWidth: CGFloat
    private let columnWidth: CGFloat
    fileprivate let rowHeight: CGFloat = FilterView.imageHeight
    fileprivate let sectionInsets = UIEdgeInsets(top: 5,
                                     left: 5,
                                     bottom: 5,
                                     right: 5)
    
    init(gridWidth: CGFloat, getter: @escaping VisibilityGetter, actionCreator: @escaping ActionCreator, sortBy: ItemComparator? = nil) {
        self.getter = getter
        self.actionCreator = actionCreator
        self.gridWidth = gridWidth
        var items = T.allCases.map({ $0 })
        if sortBy != nil {
            items = items.sorted(by: sortBy!)
        }
        self.items = items
        
        // Determine the number of rows and columns of the grid, based on the grid width
        // Since all of our grids have fixed width, this is all that we need
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
        columns = min(maxColumns, items.count)
        rows = Int(ceil(Double(items.count) / Double(columns)))
        
        // Determine the width of each column
        //let usableWidth = gridWidth - CGFloat(columns + 1) * horizontalSpacing
        //let maxAllowedWidth = usableWidth / CGFloat(columns)
        //columnWidth = (maxWidth + maxAllowedWidth) / 2
        //columnWidth = maxAllowedWidth
        columnWidth = maxWidth
    }
    
    convenience init(getter: @escaping VisibilityGetter, actionCreator: @escaping ActionCreator, sortBy:  ItemComparator? = nil) {
        self.init(gridWidth: defaultWidth, getter: getter, actionCreator: actionCreator, sortBy: sortBy)
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
        
        let button = cell.filterView.filterButton!
        button.isUserInteractionEnabled = true
        //cell.filterView.nameLabel.sizeToFit()
        //print("Item is \(item.displayName)")
        //print("Visibility is \(main.characterProfile.getVisibility(item))")
        button.set(getter(item))
        button.setCallback({
            store.dispatch(self.actionCreator(item))
        })
        button.setLongPressCallback({
            if !button.isSet() { button.sendActions(for: .touchUpInside) }
            for (value, btn) in self.itemButtonMap {
                if (value != item && btn.isSet()) {
                    btn.sendActions(for: .touchUpInside)
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
    @objc func selectAll() { store.dispatch(FilterAllAction<T>(visible: true)) }
    @objc func unselectAll() { store.dispatch(FilterAllAction<T>(visible: false)) }
    
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

class FilterGridFeatureDelegate<T:NameConstructible, A:Action> : FilterGridDelegate<T,A> {
    let featuredItems: [T]
    let allItems: [T]
    var featuredRows: Int = 0
    private(set) var showingFeatured: Bool
    
    init(featuredItems: [T], gridWidth: CGFloat, getter: @escaping VisibilityGetter, actionCreator: @escaping ActionCreator, sortBy: ItemComparator? = nil) {
        var allItems = T.allCases.map({$0})
        var featured = featuredItems
        if sortBy != nil {
            allItems.sort(by: sortBy!)
            featured.sort(by: sortBy!)
        }
        self.featuredItems = featured
        self.allItems = allItems
        self.showingFeatured = false
        super.init(gridWidth: gridWidth, getter: getter, actionCreator: actionCreator, sortBy: sortBy)
        self.featuredRows = Int(Float(featuredItems.count / self.columns).rounded(.up))
    }
    
    func useFeatured() { self.items = self.featuredItems; self.showingFeatured = true }
    func useAll() { self.items = self.allItems; self.showingFeatured = false }
    func toggleUseFeatured() { self.showingFeatured ? self.useAll() : self.useFeatured() }
    
    convenience init(featuredItems: [T], getter: @escaping VisibilityGetter, actionCreator: @escaping ActionCreator, sortBy: ItemComparator? = nil) {
        self.init(featuredItems: featuredItems, gridWidth: defaultWidth, getter: getter, actionCreator: actionCreator, sortBy: sortBy)
    }
    
    override func desiredHeight() -> CGFloat {
        //print("There are \(rows) rows, each with height \(rowHeight)")
        let rowsToUse = self.showingFeatured ? self.featuredRows : self.rows
        let height = CGFloat(rowsToUse + 1) * sectionInsets.top + CGFloat(rowsToUse) * rowHeight
        //print("The desired height is \(height)")
        return height
    }
}


class FilterGridRangeDelegate<T:QuantityType, A:Action>: FilterGridDelegate<T,A> {
    
    typealias FlagSetter = (Bool) -> Void
    
    var flagSetter: FlagSetter
    
    init(gridWidth: CGFloat, getter: @escaping VisibilityGetter, actionCreator: @escaping ActionCreator, flagSetter: @escaping FlagSetter) {
        self.flagSetter = flagSetter
        super.init(gridWidth: gridWidth, getter: getter, actionCreator: actionCreator)
    }
    
    convenience init(getter: @escaping VisibilityGetter, actionCreator: @escaping ActionCreator, flagSetter: @escaping FlagSetter) {
        self.init(gridWidth: defaultWidth, getter: getter, actionCreator: actionCreator, flagSetter: flagSetter)
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
