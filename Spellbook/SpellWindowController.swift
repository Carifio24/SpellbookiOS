//
//  SpellWindowController.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 11/30/18.
//  Copyright © 2018 Jonathan Carifio. All rights reserved.
//

import UIKit

class SpellWindowController: UIViewController {
    
    // The main controller
    let main = (UIApplication.shared.keyWindow!.rootViewController as! SWRevealViewController).frontViewController as! ViewController
    
    // Font sizes
    static let nameSize = CGFloat(30)
    static let fontSize = CGFloat(15)
    static let schoolLevelFontSize = CGFloat(19)
    
    // Favorite/not favorite images
    static let isFavoriteImage = UIImage(named: "star_filled.png")?.withRenderingMode(.alwaysOriginal)
    static let notFavoriteImage = UIImage(named: "star_empty.png")?.withRenderingMode(.alwaysOriginal)
    static let isPreparedImage = UIImage(named: "wand_filled.png")?.withRenderingMode(.alwaysOriginal)
    static let notPreparedImage = UIImage(named: "wand_empty.png")?.withRenderingMode(.alwaysOriginal)
    static let isKnownImage = UIImage(named: "book_filled.png")?.withRenderingMode(.alwaysOriginal)
    static let notKnownImage = UIImage(named: "book_empty.png")?.withRenderingMode(.alwaysOriginal)
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var spellNameLabel: UILabel!
    @IBOutlet var spellTextLabel: UITextView!
    @IBOutlet var favoriteButton: UIButton!
    @IBOutlet var preparedButton: UIButton!
    @IBOutlet var knownButton: UIButton!
    
    // The name label size
    let nameLabelHeight = CGFloat(55)
    
    // How much of the horizontal width goes to the name label
    // The rest is for the favoriting button
    let nameLabelFraction = CGFloat(0.87)
    
    // Extreme padding amounts
    let maxHorizPadding = CGFloat(5)
    let maxTopPadding = CGFloat(25)
    let maxBotPadding = CGFloat(3)
    let minHorizPadding = CGFloat(1)
    let minTopPadding = CGFloat(20)
    let minBotPadding = CGFloat(1)
    
    // Padding amounts
    let leftPaddingFraction = CGFloat(0.01)
    let rightPaddingFraction = CGFloat(0.01)
    let topPaddingFraction = CGFloat(0.01)
    let bottomPaddingFraction = CGFloat(0.01)
    
    let paddingBetweenImages = CGFloat(3)
    
    // Button sizes
    let buttonHeight = CGFloat(41)
    let buttonWidth = CGFloat(41)
    
    
    // The spell for the window, and its (current) index in the array
    var spellIndex: Int = 0
    var spell = Spell() {
        didSet { setSpell(spell) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.bringSubviewToFront(scrollView)

        // We close the window on a swipe to the right
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
                case UISwipeGestureRecognizer.Direction.right:
                    main.filter()
                    main.saveCharacterProfile()
                    self.dismiss(animated: true, completion: nil)
                default:
                    break
            }
        }
    }
    
    func setSpell(_ spell: Spell) {
        
        // Set the attributed text on the name label
        //spellNameLabel.attributedText = nameText()
        spellNameLabel.text = spell.name
        self.view.bringSubviewToFront(spellNameLabel)
        
        // Do the same for the body of the spell text
        spellTextLabel.attributedText = spellText()
        self.view.bringSubviewToFront(spellTextLabel)
        
        // Set the view dimensions
        setDimensions()
        
        // Get the character profile
        let characterProfile = main.characterProfile
        
        // Set the button images
        // First, the favorite button
        let favoriteImage = characterProfile.isFavorite(spell) ? SpellWindowController.isFavoriteImage : SpellWindowController.notFavoriteImage
        favoriteButton.setImage(favoriteImage, for: .normal)
        favoriteButton.imageView?.contentMode = .scaleAspectFit
        self.view.bringSubviewToFront(favoriteButton)
        
        // Next, the prepared button
        let preparedImage = characterProfile.isPrepared(spell) ? SpellWindowController.isPreparedImage : SpellWindowController.notPreparedImage
        preparedButton.setImage(preparedImage, for: .normal)
        preparedButton.imageView?.contentMode = .scaleAspectFit
        self.view.bringSubviewToFront(preparedButton)
        
        // Finally, the known button
        let knownImage = characterProfile.isKnown(spell) ? SpellWindowController.isKnownImage : SpellWindowController.notKnownImage
        knownButton.setImage(knownImage, for: .normal)
        knownButton.imageView?.contentMode = .scaleAspectFit
        self.view.bringSubviewToFront(knownButton)
        
        // Set the button functions
        favoriteButton.addTarget(self, action: #selector(favoriteButtonPressed), for: UIControl.Event.touchUpInside)
        preparedButton.addTarget(self, action: #selector(preparedButtonPressed), for: UIControl.Event.touchUpInside)
        knownButton.addTarget(self, action: #selector(knownButtonPressed), for: UIControl.Event.touchUpInside)
    }
    
    
    func nameText() -> NSMutableAttributedString {
        return NSMutableAttributedString(string: spell.name, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: SpellWindowController.nameSize)])
    }
    
    // Create the text <b>Name: </b> Text for a single property
    func propertyText(name: String, text: String, addLine: Bool = false) -> NSMutableAttributedString {
        let toadd = addLine ? ":\n" : ": "
        let boldStr = name + toadd
        let fontSize =  SpellWindowController.fontSize
        let font = UIFont.systemFont(ofSize: fontSize)
        let boldFontAttribute: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: font.pointSize)]
         let attributedName = NSMutableAttributedString(string: boldStr, attributes: boldFontAttribute)
        let attributedText = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.font: font])
        let combined = NSMutableAttributedString()
        combined.append(attributedName)
        combined.append(attributedText)
        return combined
    }
    
    func schoolLevelText(_ s: Spell) -> NSMutableAttributedString {
        let font = UIFont.systemFont(ofSize: SpellWindowController.schoolLevelFontSize)
        let italicFontAttribute : [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont.italicSystemFont(ofSize: font.pointSize)]
        
        var text = String(s.level)
        switch (s.level) {
        case 0:
            text = s.school.name() + " cantrip"
            return NSMutableAttributedString(string: text, attributes: italicFontAttribute)
        case 1:
            text.append("st-level ")
            break
        case 2:
            text.append("nd-level ")
            break
        case 3:
            text.append("rd-level ")
            break
        default:
            text.append("th-level ")
        }
        text = text + s.school.name().lowercased()
        if s.ritual {
            text = text + " (ritual)"
        }
        return NSMutableAttributedString(string: text, attributes: italicFontAttribute)
    }
    
    
    func spellText() -> NSMutableAttributedString {
        
        // We go through each property one by one, create the relevant text, then join them together
        // Note that the spell name gets its own text field
        let schoolText = schoolLevelText(spell)
        let castingTimeText = propertyText(name: "Casting time", text: spell.castingTime)
        let durationText = propertyText(name: "Duration", text: spell.duration.string())
        let sourcebookCode = Spellbook.sourcebookCodes[spell.sourcebook.rawValue].uppercased()
        let locationText = propertyText(name: "Location", text: sourcebookCode + " " + String(spell.page))
        let componentsText = propertyText(name: "Components", text: spell.componentsString())
        let materialsText = propertyText(name: "Materials", text: spell.material)
        let rangeText = propertyText(name: "Range", text: spell.range.string())
        let concentrationText = propertyText(name: "Concentration", text: bool_to_yn(yn: spell.concentration))
        let classesText = propertyText(name: "Classes", text: spell.classesString())
        let descriptionText = propertyText(name: "Description", text: spell.description, addLine: true)
        let higherLevelText = propertyText(name: "Higher level", text: spell.higherLevel, addLine: true)
        
        // Now combine everything together
        let spellText = NSMutableAttributedString()
        let attrNewline = NSAttributedString(string: "\n")
        spellText.append(schoolText)
        spellText.append(attrNewline)
        //spellText.append(attrNewline)
        spellText.append(locationText)
        spellText.append(attrNewline)
        spellText.append(concentrationText)
        spellText.append(attrNewline)
        spellText.append(castingTimeText)
        spellText.append(attrNewline)
        spellText.append(rangeText)
        spellText.append(attrNewline)
        spellText.append(componentsText)
        spellText.append(attrNewline)
        if spell.components[2] {
            spellText.append(materialsText)
            spellText.append(attrNewline)
        }
        spellText.append(durationText)
        spellText.append(attrNewline)
        spellText.append(classesText)
        spellText.append(attrNewline)
        spellText.append(descriptionText)
        spellText.append(attrNewline)
        if spell.higherLevel != "" {
            spellText.append(higherLevelText)
        }
        return spellText
    }
    
    func setDimensions() {
        
        // Screen dimensions
        let screenRect = view.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        
        // Get the padding sizes
        let leftPadding = max(min(leftPaddingFraction * screenWidth, maxHorizPadding), minHorizPadding)
        let rightPadding = max(min(rightPaddingFraction * screenWidth, maxHorizPadding), minHorizPadding)
        let topPadding = max(min(topPaddingFraction * screenHeight, maxTopPadding), minTopPadding)
        let bottomPadding = max(min(bottomPaddingFraction * screenHeight, maxTopPadding), minBotPadding)
        
        // Account for padding
        let usableHeight = screenHeight - topPadding - bottomPadding
        let usableWidth = screenWidth - leftPadding - rightPadding
        
        // Set the element dimensions
        // First, the size of the UIScrollView
        scrollView.frame = CGRect(x: leftPadding, y: topPadding, width: usableWidth, height: usableHeight)
        
        // Get the scroll view's dimensions
        let scrollRect = scrollView.bounds
        let scrollWidth = scrollRect.size.width
        //let scrollHeight = scrollRect.size.height
        
        // Set the dimensions of the subviews
        
        // First the name label
        let nameLabelWidth = nameLabelFraction * scrollWidth
        spellNameLabel.frame.origin.x = 0
        spellNameLabel.frame.origin.y = 0
        spellNameLabel.frame.size.width = nameLabelWidth
        spellNameLabel.sizeToFit()
        
        // Then the buttons
        //let buttonWidth = scrollWidth - nameLabelWidth
        //let buttonHeight = buttonWidth
        let nameLabelHeight = spellNameLabel.frame.size.height
        favoriteButton.frame = CGRect(x: nameLabelWidth, y: 0, width: buttonWidth, height: buttonHeight)
        preparedButton.frame = CGRect(x: nameLabelWidth, y: buttonHeight + paddingBetweenImages, width: buttonWidth, height: buttonHeight)
        knownButton.frame = CGRect(x: nameLabelWidth, y: 2 * ( buttonHeight + paddingBetweenImages), width: buttonWidth, height: buttonHeight)
        
        
        // Finally, the spell text
        spellTextLabel.frame.origin.x = 0
        spellTextLabel.frame.origin.y = spellNameLabel.frame.size.height
        spellTextLabel.frame.size.width = scrollWidth
        spellTextLabel.sizeToFit()
        
        // We need to tell the scroll view how large its contents are
        scrollView.contentSize = CGSize(width: scrollWidth, height: nameLabelHeight + spellTextLabel.frame.size.height)
        
    }
    
    @objc func favoriteButtonPressed() {
        let profile = main.characterProfile
        let fav = !profile.isFavorite(spell)
        profile.setFavorite(s: spell, fav: fav)
        let favoriteImage = fav ? SpellWindowController.isFavoriteImage : SpellWindowController.notFavoriteImage
        favoriteButton.setImage(favoriteImage, for: .normal)
        favoriteButton.imageView?.contentMode = .scaleAspectFit
        main.saveCharacterProfile()
    }
    
    @objc func preparedButtonPressed() {
        let profile = main.characterProfile
        let prep = !profile.isPrepared(spell)
        profile.setPrepared(s: spell, prep: prep)
        let preparedImage = prep ? SpellWindowController.isPreparedImage : SpellWindowController.notPreparedImage
        preparedButton.setImage(preparedImage, for: .normal)
        preparedButton.imageView?.contentMode = .scaleAspectFit
        main.saveCharacterProfile()
    }
    
    @objc func knownButtonPressed() {
        let profile = main.characterProfile
        let known = !profile.isKnown(spell)
        profile.setKnown(s: spell, known: known)
        let knownImage = known ? SpellWindowController.isKnownImage : SpellWindowController.notKnownImage
        knownButton.setImage(knownImage, for: .normal)
        knownButton.imageView?.contentMode = .scaleAspectFit
        main.saveCharacterProfile()
    }

}
