//
//  SideMenuCell.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 3/13/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import UIKit

class SideMenuCell: UITableViewCell {
        
    // Cell size
    static let cellWidth = CGFloat(300)
    static let cellHeight = CGFloat(40)
    
    // Sizes of elements
    static let iconHeight = CGFloat(0.9 * cellHeight)
    static let iconWidth = cellHeight
    static let labelWidth = cellWidth - iconWidth
    
    // Label font size
    static let fontSize = CGFloat(14)
    static let font = UIFont.systemFont(ofSize: fontSize)
    
    // Extreme padding amounts
    static let leftPadding = CGFloat(3)
    static let topPadding = CGFloat(3)
    static let rightIconPadding = CGFloat(10)
    
    // Selected/not selected images
    static let isSelectedStar =  "star_filled.png"
    static let notSelectedStar = "star_empty.png"
    
    var isSelectedImage: UIImage
    var notSelectedImage: UIImage
    
    let iconView = UIImageView()
    let optionLabel = UILabel()
    
    
    // Selected or not
    var cellSelected: Bool = false {
        didSet {
            updateIcon()
        }
    }
    
    
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, selected: Bool,
         isSelectedImageFile: String, notSelectedImageFile: String) {
        
        if notSelectedImageFile == "" {
            notSelectedImage = UIImage()
        } else {
            notSelectedImage = UIImage(named: notSelectedImageFile)!.withRenderingMode(.alwaysOriginal)
        }
        
        if isSelectedImageFile == "" {
            isSelectedImage = UIImage()
        } else {
            isSelectedImage = UIImage(named: isSelectedImageFile)!.withRenderingMode(.alwaysOriginal)
        }
        
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.clear
        
        cellSelected = selected
        iconView.frame = CGRect(x: SideMenuCell.leftPadding, y: SideMenuCell.topPadding, width: SideMenuCell.iconWidth, height: SideMenuCell.iconHeight)
        if selected {
            iconView.image = isSelectedImage
        } else {
            iconView.image = notSelectedImage
        }
        iconView.backgroundColor = UIColor.clear
        self.addSubview(iconView)
        
        optionLabel.frame = CGRect(x: SideMenuCell.leftPadding + SideMenuCell.iconWidth + SideMenuCell.rightIconPadding, y: SideMenuCell.topPadding, width: SideMenuCell.labelWidth, height: SideMenuCell.cellHeight)
        optionLabel.font = SideMenuCell.font
        optionLabel.backgroundColor = UIColor.red
        self.addSubview(optionLabel)
    }
    
    convenience init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, selected: Bool) {
        self.init(style: style, reuseIdentifier: reuseIdentifier, selected: selected, isSelectedImageFile: SideMenuCell.isSelectedStar, notSelectedImageFile: SideMenuCell.notSelectedStar)
    }
    
    func toggleSelected() {
        cellSelected = !cellSelected
    }
    
    func updateIcon() {
        if cellSelected {
            iconView.image = isSelectedImage
        } else {
            iconView.image = notSelectedImage
        }
    }
    
    required init?(coder decoder: NSCoder) {
        
        isSelectedImage = UIImage(named: SideMenuCell.isSelectedStar)!.withRenderingMode(.alwaysOriginal)
        
        notSelectedImage = UIImage(named: SideMenuCell.notSelectedStar)!.withRenderingMode(.alwaysOriginal)
        
        super.init(coder: decoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
