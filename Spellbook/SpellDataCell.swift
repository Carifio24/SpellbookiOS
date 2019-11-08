//
//  SpellDataCell.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 11/27/18.
//  Copyright © 2018 Jonathan Carifio. All rights reserved.
//

import UIKit

class SpellDataCell: UITableViewCell {
    
    // The labels
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var levelSchoolLabel: UILabel!
    @IBOutlet var sourcebookLabel: UILabel!
    @IBOutlet var favoriteButton: ToggleButton!
    @IBOutlet var preparedButton: ToggleButton!
    @IBOutlet var knownButton: ToggleButton!
    
    //static var screenWidth = UIScreen.main.bounds.width
    
    // The cell height
    static let cellHeight = CGFloat(80)
    static let main: ViewController = (UIApplication.shared.keyWindow?.rootViewController as! SWRevealViewController).frontViewController as! ViewController
    
    // Button dimensions
    // All the button dimensions are static variables mainly so that we can do the size computations once, and thus (the important part) only re-render the button images once
    static let buttonsFraction = CGFloat(0.3)
    static let buttonsWidth = SpellDataCell.buttonsFraction * ViewController.usableWidth
    static let buttonsHorizontalPadding = CGFloat(2)
    static let nButtons = CGFloat(3)
    static let buttonWidth = min((SpellDataCell.buttonsWidth - (nButtons + 1) * buttonsHorizontalPadding) / nButtons, SpellDataCell.cellHeight)
    static let buttonHeight = SpellDataCell.buttonWidth
    
    // The button images
    static let starEmpty = UIImage(named: "star_empty.png")?.withRenderingMode(.alwaysOriginal).resized(width: SpellDataCell.buttonWidth, height: SpellDataCell.buttonHeight)
    static let starFilled = UIImage(named: "star_filled.png")?.withRenderingMode(.alwaysOriginal).resized(width: SpellDataCell.buttonWidth, height: SpellDataCell.buttonHeight)
    static let wandEmpty = UIImage(named: "wand_empty.png")?.withRenderingMode(.alwaysOriginal).resized(width: SpellDataCell.buttonWidth, height: SpellDataCell.buttonHeight)
    static let wandFilled = UIImage(named: "wand_filled.png")?.withRenderingMode(.alwaysOriginal).resized(width: SpellDataCell.buttonWidth, height: SpellDataCell.buttonHeight)
    static let bookEmpty = UIImage(named: "book_empty.png")?.withRenderingMode(.alwaysOriginal).resized(width: SpellDataCell.buttonWidth, height: SpellDataCell.buttonHeight)
    static let bookFilled = UIImage(named: "book_filled.png")?.withRenderingMode(.alwaysOriginal).resized(width: SpellDataCell.buttonWidth, height: SpellDataCell.buttonHeight)
    
    
    // The spell for the data cell
    // The label text is updated when Spell is set
    var spell: Spell? {
        didSet {
            nameLabel.text = spell!.name
            levelSchoolLabel.text = spell!.levelSchoolString()
            sourcebookLabel.text = spell!.sourcebook.code().uppercased()
            setViewDimensions()
            setButtonCallbacks()
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Initialize the labels
        nameLabel = UILabel()
        levelSchoolLabel = UILabel()
        sourcebookLabel = UILabel()
        
        // Initialize the buttons
        favoriteButton = ToggleButton()
        preparedButton = ToggleButton()
        knownButton = ToggleButton()
        
        // Get the screen dimensions
//        let screenSize = UIScreen.main.bounds
//        let screenWidth = Double(screenSize.width)
        //let screenHeight = Double(screenSize.height)
        
        // Set all three labels to have left-aligned text
        nameLabel.textAlignment = NSTextAlignment.left
        levelSchoolLabel.textAlignment = NSTextAlignment.left
        sourcebookLabel.textAlignment = NSTextAlignment.left
        
        // Set font sizes
        nameLabel.font = UIFont.systemFont(ofSize: 17)
        levelSchoolLabel.font = UIFont.italicSystemFont(ofSize: 11)
        sourcebookLabel.font = UIFont.systemFont(ofSize: 11)
        
        // Display the labels and buttons
        let items = [ nameLabel, levelSchoolLabel, sourcebookLabel ]
        for item in items {
            self.addSubview(item!)
        }
        
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    private func setViewDimensions() {
        
        // Label sizes
        let nameLabelHeight = CGFloat(50)
        let lowerLabelsHeight = CGFloat(10)
        
        // Padding
        let middlePadding = CGFloat(5)
        let topPadding = (SpellDataCell.cellHeight - nameLabelHeight - middlePadding - lowerLabelsHeight) / 2
        let lowerLabelsHorizontalPadding = CGFloat(2)
        
        // Assign a fraction of the width to the buttons and the labels
        let labelsFraction = 1 - SpellDataCell.buttonsFraction
        
        // The width of the labels section
        let labelsWidth = labelsFraction * ViewController.usableWidth
        
        // Set the label sizes
        // First, the name label
        // Set its frame, then resize
        // If it's too large afterwards, put it back to the original width
        nameLabel.frame = CGRect(x: 0, y: topPadding, width: labelsWidth , height: nameLabelHeight)
        nameLabel.sizeToFit()
        if (nameLabel.frame.size.width > labelsWidth) {
            nameLabel.frame = CGRect(x: 0, y: topPadding, width: labelsWidth , height: nameLabel.frame.size.height)
        }
        
        // Get the y position for the lower labels based on the resized name label
        let lowerLabelsY = topPadding + nameLabel.frame.size.height + middlePadding
        
        // Set the level and school label's frame, and resize
        levelSchoolLabel.frame = CGRect(x: 0, y: lowerLabelsY, width: labelsWidth, height: lowerLabelsHeight)
        levelSchoolLabel.sizeToFit()
        
        // Get the x position for the sourcebook label based on the resized levelSchoolLabel
        let sourcebookLabelX = levelSchoolLabel.frame.size.width + lowerLabelsHorizontalPadding
        sourcebookLabel.frame = CGRect(x: sourcebookLabelX, y: lowerLabelsY, width: labelsWidth - sourcebookLabelX, height: lowerLabelsHeight)
        
        // The favorite, prepared, known buttons
        let cp = SpellDataCell.main.characterProfile
        favoriteButton = ToggleButton(SpellDataCell.starEmpty!, SpellDataCell.starFilled!, cp.isFavorite(spell!))
        preparedButton = ToggleButton(SpellDataCell.wandEmpty!, SpellDataCell.wandFilled!, cp.isPrepared(spell!))
        knownButton = ToggleButton(SpellDataCell.bookEmpty!, SpellDataCell.bookFilled!, cp.isKnown(spell!))
        
        // Determine the button positions
        let buttonY = topPadding
        let favoriteButtonX = SpellDataCell.buttonsHorizontalPadding + labelsWidth
        let preparedButtonX = favoriteButtonX + SpellDataCell.buttonWidth + SpellDataCell.buttonsHorizontalPadding
        let knownButtonX = preparedButtonX + SpellDataCell.buttonWidth + SpellDataCell.buttonsHorizontalPadding
        
        // Set the button frames
        favoriteButton.frame = CGRect(x: favoriteButtonX, y: buttonY, width: SpellDataCell.buttonWidth, height: SpellDataCell.buttonHeight)
        preparedButton.frame = CGRect(x: preparedButtonX, y: buttonY, width: SpellDataCell.buttonWidth, height: SpellDataCell.buttonHeight)
        knownButton.frame = CGRect(x: knownButtonX, y: buttonY, width: SpellDataCell.buttonWidth, height: SpellDataCell.buttonHeight)
        
        // Display the buttons
        let buttons = [ favoriteButton, preparedButton, knownButton ]
        for button in buttons {
            self.addSubview(button!)
        }
        
    }
    
    private func setButtonCallbacks() {
        
        // Set the callbacks for the buttons
        favoriteButton.setCallback({
            let cp = SpellDataCell.main.characterProfile
            cp.setFavorite(s: self.spell!, fav: !cp.isFavorite(self.spell!))
            SpellDataCell.main.saveCharacterProfile()
            })
        preparedButton.setCallback({
            let cp = SpellDataCell.main.characterProfile
            cp.setPrepared(s: self.spell!, prep: !cp.isPrepared(self.spell!))
            SpellDataCell.main.saveCharacterProfile()
        })
        knownButton.setCallback({
            let cp = SpellDataCell.main.characterProfile
            cp.setKnown(s: self.spell!, known: !cp.isKnown(self.spell!))
            SpellDataCell.main.saveCharacterProfile()
        })
    }
    
}
