//
//  SideMenuCell.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 12/19/18.
//  Copyright © 2018 Jonathan Carifio. All rights reserved.
//

import UIKit

class SideMenuCell: UITableViewCell {
    
    static let cellWidth = CGFloat(150)
    static let cellHeight = CGFloat(40)
    
    // Extreme padding amounts
    static let leftPadding = CGFloat(3)
    static let topPadding = CGFloat(3)
    
    @IBOutlet var optionLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.clear
        optionLabel = UILabel()
        optionLabel.frame = CGRect(x: SideMenuCell.leftPadding, y: SideMenuCell.topPadding, width: SideMenuCell.cellWidth, height: SideMenuCell.cellHeight)
        optionLabel.backgroundColor = UIColor.clear
        self.addSubview(optionLabel)
        
        // Get the view dimensions
//        let viewRect =
//        let viewWidth = viewRect.size.width
//        let viewHeight = viewRect.size.height
        
        
        
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }

}
