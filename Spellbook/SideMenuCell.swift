//
//  SideMenuCell.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 12/19/18.
//  Copyright © 2018 Jonathan Carifio. All rights reserved.
//

import UIKit

class SideMenuCell: UITableViewCell {
    
    static let cellWidth = CGFloat(100)
    static let cellHeight = CGFloat(100)
    
    @IBOutlet var optionLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.clear
        optionLabel = UILabel()
        optionLabel.frame = CGRect(x:0, y: 0, width: SideMenuCell.cellWidth, height: SideMenuCell.cellHeight)
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
