//
//  CharacterCreationController.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 4/23/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import UIKit

class CharacterCreationController: UIViewController {

    
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var creationTitle: UILabel!
    @IBOutlet weak var creationMessage: UILabel!
    @IBOutlet weak var nameEntry: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    
    var height = CGFloat(0)
    var width = CGFloat(0)
    let buttonWidth = CGFloat(75)
    let buttonHeight = CGFloat(40)
    let main = Controllers.mainController
    private var cancelable = false
    
    private static let emptyNameMessage = "The character name cannot be empty"
    private static let illegalCharacterMessage = "The name contains an illegal character"
    private static let duplicateNameMessage = "A character with this name already exists"
    private static let illegalCharacters = ["\\", "/", "."]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("In viewDidLoad()")
        setLayout()
        print("Finished setting layout")
        setButtonFunctions()
        print("Finished setting button functions")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("Starting viewDidAppear")
        super.viewDidAppear(animated)
        print("Finished viewDidAppear")
    }
    
    func setLayout() {
        
        let leftPadding = CGFloat(3)
        let rightPadding = CGFloat(3)
        let topPadding = CGFloat(3)
        let bottomPadding = CGFloat(3)
        
        let usableWidth = width - leftPadding - rightPadding
        // let usableHeight = height - topPadding - bottomPadding
        
        self.view.sendSubviewToBack(backgroundView)
        backgroundView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        print("Popup type: DeletionPromptController")
        print("Popup width: \(width)")
        print("Popup height: \(height)")
        
        let titleX = CGFloat(width / 2)
        let titleY = view.frame.origin.y + topPadding
        creationTitle.center.x = titleX
        creationTitle.frame.origin.y = titleY
        creationTitle.sizeToFit()
        
        let messageX = CGFloat(width / 2)
        let messageY = titleY + creationTitle.frame.height
        creationMessage.center.x = messageX
        print("creationMessageX is \(messageX)")
        creationMessage.frame.origin.y = messageY
        creationMessage.sizeToFit()
        
        let entryY = messageY + creationMessage.frame.height
        nameEntry.frame.origin = CGPoint(x: leftPadding, y: entryY)
        nameEntry.frame.size.width = usableWidth
        
        let cancelButtonX = CGFloat(width - rightPadding - 2 * buttonWidth)
        let buttonsY = height - bottomPadding - buttonHeight
        cancelButton.frame = CGRect(x: cancelButtonX, y: buttonsY, width: buttonWidth, height: buttonHeight)
        print(buttonsY)
        print(cancelButtonX)
        
        let createButtonX = CGFloat(cancelButtonX + buttonWidth)
        createButton.frame = CGRect(x: createButtonX, y: buttonsY, width: buttonWidth, height: buttonHeight)
        print(createButtonX)
        
        if main.characterList().count == 0 {
            cancelButton.isHidden = true
            cancelable = false
        }
        
    }
    
    @objc func createButtonPressed() {
        let name = nameEntry.text!
        
        let characters = main.characterList()
        let nChars = characters.count
        
        // Reject an empty name
        if name.count == 0 {
            creationMessage.text = CharacterCreationController.emptyNameMessage
            creationMessage.textColor = UIColor.red
            return
        }
        
        // Reject a name that already exists
        if characters.contains(name) {
            creationMessage.text = CharacterCreationController.duplicateNameMessage
            creationMessage.textColor = UIColor.red
            return
        }
        
        // Reject a name that contains an illegal character
        for c in CharacterCreationController.illegalCharacters {
            if name.contains(c) {
                creationMessage.text = CharacterCreationController.illegalCharacterMessage
                creationMessage.textColor = UIColor.red
                return
            }
        }
        
        // Create the new character profile
        let profile = CharacterProfile(name: name)
        let charFile: String = profile.name() + ".json"
        let profileLocation = main.profilesDirectory.appendingPathComponent(charFile)
        profile.save(filename: profileLocation)
        
        // Set it as the current profile if there are no others
        if nChars == 0 {
            main.setCharacterProfile(cp: profile)
        }
        
        // Update the character selection window, if one is open
        main.updateSelectionList()
        
        // Toast message
        Controllers.revealController.view.makeToast("Character created: " + name, duration: Constants.toastDuration)
        
        // Dismiss this window
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @objc func cancelButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setButtonFunctions() {
        
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: UIControl.Event.touchUpInside)
        createButton.addTarget(self, action: #selector(createButtonPressed), for: UIControl.Event.touchUpInside)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if (touch?.view != nameEntry) {
            nameEntry.resignFirstResponder()
        }
        if (touch?.view == self.view) && cancelable {
            self.dismiss(animated: true, completion: nil)
        }
    }

}
