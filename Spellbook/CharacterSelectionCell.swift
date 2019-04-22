//
//  CharacterSelectionCell.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 4/22/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import UIKit

class CharacterSelectionCell: UITableViewCell {
    
    var iconView = UIImageView()
    var nameLabel = UILabel()

    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, selected: Bool, characterName: String) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        nameLabel.text = characterName
        
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    

}
