//
//  SpellDataCell.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 11/27/18.
//  Copyright © 2018 Jonathan Carifio. All rights reserved.
//

import UIKit

class SpellDataCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var schoolLabel: UILabel!
    
    @IBOutlet weak var levelLabel: UILabel!
    
    // The spell for the data cell
    // The label text is updated when Spell is set
    var spell: Spell? {
        didSet {
            nameLabel.text = spell?.name
            schoolLabel.text = Spellbook.schoolNames[spell!.school.rawValue]
            levelLabel.text = String(spell!.level)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Get the screen dimensions
        let screenSize = UIScreen.main.bounds
        let screenWidth = Double(screenSize.width)
        //let screenHeight = Double(screenSize.height)
        
        // Assign a fraction of the width to each property
        let nameFraction = 0.45
        let schoolFraction = 0.35
        let levelFraction = 0.2
        
        // Determine the label sizes
        let nameWidth = Int(nameFraction*screenWidth)
        let schoolWidth = Int(schoolFraction*screenWidth)
        let levelWidth = Int(levelFraction*screenWidth)
        let labelHeight = 50
        
        // Set the label sizes
        nameLabel.frame = CGRect(x: 0, y:0, width: nameWidth , height: labelHeight)
        schoolLabel.frame = CGRect(x: nameWidth, y:0, width: schoolWidth, height: labelHeight)
        levelLabel.frame = CGRect(x: nameWidth + schoolWidth, y: 0, width: levelWidth, height: labelHeight)
        
        // Set the label text
        
        // Display the labels
        self.addSubview(nameLabel)
        self.addSubview(schoolLabel)
        self.addSubview(levelLabel)
        
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    
}
