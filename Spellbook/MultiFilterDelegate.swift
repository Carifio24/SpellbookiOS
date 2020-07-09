//
//  MultiFilterDelegate.swift
//  Spellbook
//
//  Created by Mac Pro on 6/30/20.
//  Copyright © 2020 Jonathan Carifio. All rights reserved.
//

import UIKit

class MultiFilterDelegate: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let reuseIdentifier = "filterItem"
    let gridWidth: CGFloat
    let centered: Bool
    let columns: Int
    let rows: Int
    private let columnWidth: CGFloat
    private let unfilledRowWidth: CGFloat
    
    let filters: [UICollectionView]
    
    private let sectionInsets = UIEdgeInsets(top: 5,
                                            left: 5,
                                            bottom: 5,
                                            right: 5)
    
    init(gridWidth: CGFloat, filters: [UICollectionView], centered: Bool = false) {
        
        self.gridWidth = gridWidth
        self.centered = centered
        self.filters = filters
        
        var maxWidth: CGFloat = 0
        for filter in filters {
            let delegate = filter.delegate as! FilterGridProtocol
            let width = delegate.desiredWidth()
            if width > maxWidth {
                maxWidth = width
            }
        }
        columnWidth = maxWidth
        
        // To find the number of columns, we find the largest solution to
        // n * maxWidth + (n + 1) * horizontalSpacing <= gridWidth
        let horizontalSpacing = sectionInsets.left
        let maxColumns = Int(floor( (gridWidth - horizontalSpacing) / (maxWidth + horizontalSpacing) ))
        columns = max(min(maxColumns, filters.count), 1)
        rows = Int(ceil(Double(filters.count) / Double(columns)))
        
        if (centered) {
            let unfilledCount = rows * columns - filters.count
            unfilledRowWidth = maxWidth * CGFloat(unfilledCount) / CGFloat(columns)
        } else {
            unfilledRowWidth = columnWidth
        }
        
    }
    
    // MARK: - Collection View Data Source/Delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: FilterCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FilterCollectionCell
        let filter = filters[indexPath.row]
        cell.backgroundColor = .clear
        cell.filterCollectionView.collectionView = filter
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout,
            sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // If we're using centering and are on the last row (and it isn't filled), use the unfilled row width
        // Otherwise, just the standard column width
        var width = columnWidth
        if (centered) {
            let unfilledWidthNeeded = indexPath.row * columns > filters.count
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

}
