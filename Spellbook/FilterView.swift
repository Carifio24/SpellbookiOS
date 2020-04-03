//
//  FilterCell.swift
//  Spellbook
//
//  Created by Mac Pro on 3/27/20.
//  Copyright © 2020 Jonathan Carifio. All rights reserved.
//

import UIKit

class FilterView: UIView {
    
    static let imageHeight = CGFloat(20)
    static let imageWidth = CGFloat(20)
    private static let starEmpty = UIImage(named: "star_empty.png")?.withRenderingMode(.alwaysOriginal).resized(width: FilterView.imageWidth, height: FilterView.imageHeight)
    private static let starFilledGray = UIImage(named: "star.png")?.withRenderingMode(.alwaysOriginal).resized(width: FilterView.imageWidth, height: FilterView.imageHeight)
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var filterButton: ToggleButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        
        // Load the XIB
        Bundle.main.loadNibNamed("FilterView", owner: self, options: nil)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(contentView)
        contentView.frame = self.bounds
        
        // Set the button images
        filterButton.setTrueImage(image: FilterView.starFilledGray!)
        filterButton.setFalseImage(image: FilterView.starEmpty!)
        
    }
    
}
