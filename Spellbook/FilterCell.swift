//
//  FilterCell.swift
//  Spellbook
//
//  Created by Mac Pro on 4/2/20.
//  Copyright © 2020 Jonathan Carifio. All rights reserved.
//

import UIKit

class FilterCell: UICollectionViewCell {

    @IBOutlet weak var filterView: FilterView!
    
//    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        filterView.frame = self.bounds
//        return layoutAttributes
//    }
    
//    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        setNeedsLayout()
//        layoutIfNeeded()
//        //print("Calling preferred layout attributes")
//        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
//        var frame = layoutAttributes.frame
//        frame.size.height = ceil(size.height)
//        frame.size.width = filterView.filterButton.frame.size.width + filterView.nameLabel.frame.size.width
//        layoutAttributes.frame = frame
//        //print(filterView.nameLabel.frame.size.width)
//        //print("Item name is \(filterView.nameLabel.text!)")
//        //print(layoutAttributes.frame.size)
//        return layoutAttributes
//    }
    
    
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

        // Some basic checks
        guard isUserInteractionEnabled else { return nil }
        guard !isHidden else { return nil }
        guard alpha >= 0.01 else { return nil }
        guard self.point(inside: point, with: event) else { return nil }

        // Add one of these blocks for each button in our collection view cell we want to actually work
        if self.filterView.filterButton.point(inside: convert(point, to: self.filterView.filterButton), with: event) {
            return self.filterView.filterButton
        }

        return super.hitTest(point, with: event)
    }
    
}
