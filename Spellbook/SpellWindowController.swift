//
//  SpellWindowController.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 11/30/18.
//  Copyright © 2018 Jonathan Carifio. All rights reserved.
//

import UIKit

class SpellWindowController: UIViewController {
    
    // Font sizes
    static let nameSize = CGFloat(30)
    static let fontSize = CGFloat(15)
    
    @IBOutlet var spellTextLabel: UITextView!
    
    // Extreme padding amounts
    let maxHorizPadding = CGFloat(5)
    let maxTopPadding = CGFloat(12)
    let maxBotPadding = CGFloat(3)
    let minHorizPadding = CGFloat(1)
    let minTopPadding = CGFloat(10)
    let minBotPadding = CGFloat(1)
    
    // Padding amounts
    let leftPaddingFraction = CGFloat(0.01)
    let rightPaddingFraction = CGFloat(0.01)
    let topPaddingFraction = CGFloat(0.01)
    let bottomPaddingFraction = CGFloat(0.01)
    
    
    // The spell for the window
    var spell = Spell() {
        didSet {
            let allText = NSMutableAttributedString()
            allText.append(nameText())
            allText.append(NSAttributedString(string: "\n"))
            allText.append(spellText())
            spellTextLabel.attributedText = allText
            self.view.bringSubviewToFront(spellTextLabel)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // We close the window on a swipe to the right
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeRight)
        
        // Do any additional setup after loading the view.
        setDimensions()
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
                case UISwipeGestureRecognizer.Direction.right:
                    self.dismiss(animated: true, completion: nil)
                default:
                    break
            }
        }
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
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
         let attributedName = NSMutableAttributedString(string: boldStr, attributes: boldFontAttribute)
        let attributedText = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.font: font])
        let combined = NSMutableAttributedString()
        combined.append(attributedName)
        combined.append(attributedText)
        return combined
    }
    
    
    func spellText() -> NSMutableAttributedString {
        
        // We go through each property one by one, create the relevant text, then join them together
        // Note that the spell name gets its own text field
        let schoolText = propertyText(name: "School", text: Spellbook.schoolNames[spell.school.rawValue])
        let levelText = propertyText(name: "Level", text: String(spell.level))
        let castingTimeText = propertyText(name: "Casting time", text: spell.castingTime)
        let durationText = propertyText(name: "Duration", text: spell.duration)
        let locationText = propertyText(name: "Location", text: "PHB " + String(spell.page))
        let componentsText = propertyText(name: "Components", text: spell.componentsString())
        let materialsText = propertyText(name: "Materials", text: spell.material)
        let rangeText = propertyText(name: "Range", text: spell.range)
        let ritualText = propertyText(name: "Ritual", text: bool_to_yn(yn: spell.ritual))
        let concentrationText = propertyText(name: "Concentration", text: bool_to_yn(yn: spell.concentration))
        let classesText = propertyText(name: "Classes", text: spell.classesString())
        let descriptionText = propertyText(name: "Description", text: spell.description, addLine: true)
        let higherLevelText = propertyText(name: "Higher level", text: spell.higherLevel, addLine: true)
        
        // Now combine everything together
        let spellText = NSMutableAttributedString()
        let attrNewline = NSAttributedString(string: "\n")
        spellText.append(schoolText)
        spellText.append(attrNewline)
        spellText.append(levelText)
        spellText.append(attrNewline)
        spellText.append(castingTimeText)
        spellText.append(attrNewline)
        spellText.append(durationText)
        spellText.append(attrNewline)
        spellText.append(locationText)
        spellText.append(attrNewline)
        spellText.append(componentsText)
        spellText.append(attrNewline)
        if spell.components[2] {
            spellText.append(materialsText)
            spellText.append(attrNewline)
        }
        spellText.append(rangeText)
        spellText.append(attrNewline)
        spellText.append(ritualText)
        spellText.append(attrNewline)
        spellText.append(concentrationText)
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
        
        // Set the element sizes
        let spellTextHeight = usableHeight
        spellTextLabel.frame = CGRect(x: leftPadding, y: topPadding, width: usableWidth, height: spellTextHeight)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
