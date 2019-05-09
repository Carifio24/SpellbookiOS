//
//  SpellDataCell.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 11/27/18.
//  Copyright © 2018 Jonathan Carifio. All rights reserved.
//

import UIKit

class SpellDataCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var schoolLabel: UILabel!
    
    @IBOutlet var levelLabel: UILabel!
    
    static var screenWidth = UIScreen.main.bounds.width
    
    // The spell for the data cell
    // The label text is updated when Spell is set
    var spell: Spell? {
        didSet {
            //nameLabel.text = spell?.name
            //schoolLabel.text = Spellbook.schoolNames[spell!.school.rawValue]
            //levelLabel.text = String(spell!.level)
            //var s: String = "Setting spell: " + spell!.name + " " + Spellbook.schoolNames[spell!.school.rawValue] + " " + String(spell!.level)
            //print(s)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Initialize the labels
        nameLabel = UILabel()
        schoolLabel = UILabel()
        levelLabel = UILabel()
        
        // Get the screen dimensions
//        let screenSize = UIScreen.main.bounds
//        let screenWidth = Double(screenSize.width)
        //let screenHeight = Double(screenSize.height)
        
        // Assign a fraction of the width to each property
        let schoolFraction = CGFloat(0.35)
        let levelFraction = CGFloat(0.15)
        let nameFraction = 1 - schoolFraction - levelFraction
        
        // Determine the label sizes
        let nameWidth = nameFraction*SpellDataCell.screenWidth
        let schoolWidth = schoolFraction*SpellDataCell.screenWidth
        let levelWidth = levelFraction*SpellDataCell.screenWidth
        let labelHeight = CGFloat(50)
        
        // Set the label sizes
        nameLabel.frame = CGRect(x: 0, y:0, width: nameWidth , height: labelHeight)
        schoolLabel.frame = CGRect(x: nameWidth, y:0, width: schoolWidth, height: labelHeight)
        levelLabel.frame = CGRect(x: nameWidth + schoolWidth, y: 0, width: levelWidth, height: labelHeight)
        levelLabel.textAlignment = NSTextAlignment.center
        schoolLabel.textAlignment = NSTextAlignment.left
        
        // Display the labels
        self.addSubview(nameLabel)
        self.addSubview(schoolLabel)
        self.addSubview(levelLabel)
        
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
}
