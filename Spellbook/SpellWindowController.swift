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
    let main = Controllers.mainController
    
    // How much of the horizontal width goes to the name label
    // The rest is for the favoriting button
    static let nameLabelFraction = CGFloat(0.87)
    static let buttonFraction = 1 - SpellWindowController.nameLabelFraction
    static let imageWidth = UIScreen.main.bounds.width * SpellWindowController.buttonFraction
    static let imageHeight = UIScreen.main.bounds.width * SpellWindowController.buttonFraction
    
    // Font sizes
    static let nameSize = CGFloat(30)
    static let fontSize = CGFloat(15)
    static let schoolLevelFontSize = CGFloat(19)
    
    // Favorite/not favorite images
    static let isFavoriteImage = UIImage(named: "star_filled.png")?.withRenderingMode(.alwaysOriginal).resized(width: SpellWindowController.imageWidth, height: SpellWindowController.imageHeight)
    static let notFavoriteImage = UIImage(named: "star_empty.png")?.withRenderingMode(.alwaysOriginal).resized(width: SpellWindowController.imageWidth, height: SpellWindowController.imageHeight)
    static let isPreparedImage = UIImage(named: "wand_filled.png")?.withRenderingMode(.alwaysOriginal).resized(width: SpellWindowController.imageWidth, height: SpellWindowController.imageHeight)
    static let notPreparedImage = UIImage(named: "wand_empty.png")?.withRenderingMode(.alwaysOriginal).resized(width: SpellWindowController.imageWidth, height: SpellWindowController.imageHeight)
    static let isKnownImage = UIImage(named: "book_filled.png")?.withRenderingMode(.alwaysOriginal).resized(width: SpellWindowController.imageWidth, height: SpellWindowController.imageHeight)
    static let notKnownImage = UIImage(named: "book_empty.png")?.withRenderingMode(.alwaysOriginal).resized(width: SpellWindowController.imageWidth, height: SpellWindowController.imageHeight)
    

    
    // The scroll view and the content container
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    // The labels for displaying the spell info text
    @IBOutlet weak var spellNameLabel: UILabel!
    @IBOutlet weak var schoolLevelLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var concentrationLabel: UILabel!
    @IBOutlet weak var castingTimeLabel: UILabel!
    @IBOutlet weak var rangeLabel: UILabel!
    @IBOutlet weak var componentsLabel: UILabel!
    @IBOutlet weak var materialsLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var classesLabel: UILabel!
    @IBOutlet weak var expandedClassesLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var higherLevelLabel: UILabel!
    
    // The status buttons
    @IBOutlet weak var favoriteButton: ToggleButton!
    @IBOutlet weak var preparedButton: ToggleButton!
    @IBOutlet weak var knownButton: ToggleButton!
    
    @IBOutlet weak var backgroundView: UIImageView!
    
    static let spellKey = "spell"
    static let spellIndexKey = "spellIndex"
    
    
    // The spell for the window, and its (current) index in the array
    var spellIndex: Int = 0
    var spell = Spell() {
        didSet { setSpell(spell) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // We close the window on a swipe to the right
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeRight)
        
        // Set the button images
        favoriteButton.setTrueImage(image: SpellWindowController.isFavoriteImage!)
        favoriteButton.setFalseImage(image: SpellWindowController.notFavoriteImage!)
        preparedButton.setTrueImage(image: SpellWindowController.isPreparedImage!)
        preparedButton.setFalseImage(image: SpellWindowController.notPreparedImage!)
        knownButton.setTrueImage(image: SpellWindowController.isKnownImage!)
        knownButton.setFalseImage(image: SpellWindowController.notKnownImage!)
        
        // Set the button callbacks
        favoriteButton.setCallback({
            self.main.characterProfile.toggleFavorite(self.spell)
            self.main.saveCharacterProfile()
        })
        preparedButton.setCallback({
            self.main.characterProfile.togglePrepared(self.spell)
            self.main.saveCharacterProfile()
        })
        knownButton.setCallback({
            self.main.characterProfile.toggleKnown(self.spell)
            self.main.saveCharacterProfile()
        })
        
        // Set the content view to fill the screen
        contentView.frame = UIScreen.main.bounds
        
        // Set the label fonts
        let labels = [ spellNameLabel, schoolLevelLabel, locationLabel, concentrationLabel, castingTimeLabel, rangeLabel, componentsLabel, materialsLabel, durationLabel, classesLabel, expandedClassesLabel, descriptionLabel, higherLevelLabel ]
        labels.forEach { $0!.textColor = defaultFontColor }
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // The content size of the scroll view is equal to the content view's size
        scrollView.contentSize = contentView.frame.size
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
                case UISwipeGestureRecognizer.Direction.right:
                    self.main.filter()
                    self.main.saveCharacterProfile()
                    self.dismiss(animated: true, completion: nil)
                    UIApplication.shared.setStatusBarTextColor(.dark)
                default:
                    break
            }
        }
    }
    
    func setSpell(_ spell: Spell) {
        
        // Set the attributed text on the name label
        spellNameLabel.text = spell.name
        
        // Do the same for the body of the spell text
        schoolLevelLabel.attributedText = schoolLevelText(spell)
        castingTimeLabel.attributedText = propertyText(name: "Casting time", text: spell.castingTime.string())
        durationLabel.attributedText = propertyText(name: "Duration", text: spell.duration.string())
        locationLabel.attributedText = propertyText(name: "Location", text: locationText(spell))
        componentsLabel.attributedText = propertyText(name: "Components", text: spell.componentsString())
        if !spell.materials.isEmpty {
            materialsLabel.attributedText = propertyText(name: "Materials", text: spell.materials)
        }
        rangeLabel.attributedText = propertyText(name: "Range", text: spell.range.string())
        concentrationLabel.attributedText = propertyText(name: "Concentration", text: bool_to_yn(yn: spell.concentration))
        classesLabel.attributedText = propertyText(name: "Classes", text: spell.classesString())
        if (main.characterProfile.getUseTCEExpandedLists() && spell.tashasExpandedClasses.count > 0) {
            expandedClassesLabel.attributedText = propertyText(name: "TCE Expanded Classes", text: spell.tashasExpandedClassesString())
        }
        descriptionLabel.attributedText = propertyText(name: "Description", text: spell.description, addLine: true)
        if !spell.higherLevel.isEmpty {
            higherLevelLabel.attributedText = propertyText(name: "Higher level", text: spell.higherLevel, addLine: true)
        }
        
        // Get the character profile
        let profile = main.characterProfile
        
        // Set the spell buttons to the correct state
        favoriteButton.set(profile.isFavorite(spell))
        preparedButton.set(profile.isPrepared(spell))
        knownButton.set(profile.isKnown(spell))
        
        // Set the scroll view content size
        scrollView.contentSize = self.view.frame.size
        //print("Scroll enabled: \(scrollView.isScrollEnabled)")
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
        
        let text = s.levelSchoolString()
        return NSMutableAttributedString(string: text, attributes: italicFontAttribute)
    }
    
    func locationText(_ s: Spell) -> String {
         return s.locations.map { $0.key.code.uppercased() + " " + String($0.value) }.joined(separator: ", ")
    }

}


extension SpellWindowController : UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FromRightPushAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FromRightDismissAnimator()
    }
}
