//
//  InfoMenuCell.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 12/19/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import UIKit

class InfoMenuCell: UITableViewCell {
    
    static let horizPadding = CGFloat(5)
    static let vertPadding = CGFloat(2)
    
    @IBOutlet var label: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // The label
        label.frame = CGRect(x: InfoMenuCell.horizPadding, y: InfoMenuCell.vertPadding, width: self.frame.size.width - 2*InfoMenuCell.horizPadding, height: self.frame.size.height - 2*InfoMenuCell.vertPadding)
        self.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    

}
