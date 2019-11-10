//
//  CharacterSelectionController.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 4/17/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import UIKit

class CharacterSelectionController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var selectionTitle: UILabel!
    @IBOutlet weak var selectionMessage: UILabel!
    @IBOutlet weak var newCharacterButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundView: UIImageView!
    
    private let cellReuseIdentifier = "characterCell"
    
    var height = CGFloat(0)
    var width = CGFloat(0)
    var characters: [String] = []
    let main: ViewController = Controllers.mainController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the current characters list
        characters = main.characterList()
        print("There are \(characters.count) characters")
        
        // Set the view dimensions
        setDimensions()
        
        // Set this as the data source and delegate for the table
        tableView.delegate = self
        tableView.dataSource = self
        
        // Set the table cell type
        tableView.register(CharacterSelectionCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.separatorStyle = .none
        
        // Set the button function
        newCharacterButton.addTarget(self, action: #selector(newCharacterButtonPressed), for: UIControl.Event.touchUpInside)
        
        // Load the data
        print("About to load data")
        tableView.reloadData()
        
    }
    
    func setDimensions() {

        let leftPadding = CGFloat(3)
        let rightPadding = CGFloat(3)
        let topPadding = CGFloat(3)
        let bottomPadding = CGFloat(3)

        let usableWidth = width - leftPadding - rightPadding
        let usableHeight = height - topPadding - bottomPadding
        
        backgroundView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        print("Popup type: CharacterSelectionController")
        print("Popup width: \(width)")
        print("Popup height: \(height)")

        let titleX = CGFloat(width / 2)
        let titleY = view.frame.origin.y + topPadding
        selectionTitle.center.x = titleX
        selectionTitle.frame.origin.y = titleY
        selectionTitle.sizeToFit()
        //selectionTitle.backgroundColor = UIColor.red
        
        let messageX = CGFloat(width / 2)
        let messageY = titleY + selectionTitle.frame.height
        selectionMessage.center.x = messageX
        selectionMessage.frame.origin.y = messageY
        selectionTitle.sizeToFit()
        //selectionMessage.backgroundColor = UIColor.blue
        
        let newButtonX = CGFloat(width / 2)
        let newButtonY = messageY + selectionMessage.frame.height
        newCharacterButton.contentHorizontalAlignment = .center
        newCharacterButton.center.x = newButtonX
        newCharacterButton.frame.origin.y = newButtonY
        //newCharacterButton.backgroundColor = UIColor.green
        newCharacterButton.sizeToFit()

        let tableX = leftPadding
        let tableY = newButtonY + newCharacterButton.frame.height
        let tableWidth = usableWidth
        let tableHeight = usableHeight - (tableY - topPadding)
        self.view.bringSubviewToFront(tableView)
        tableView.backgroundColor = UIColor.clear
        tableView.frame = CGRect(x: tableX, y: tableY, width: tableWidth, height: tableHeight)

    }
    
    // For conforming to the table delegate and data source protocols
    func tableView(_ tableView: UITableView, numberOfRowsInSection: Int) -> Int {
        return characters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! CharacterSelectionCell
        let name = characters[indexPath.row]
        cell.name = name
        cell.width = width
        cell.iconButton.tag = indexPath.row
        cell.nameLabel.frame = CGRect(x: 0, y: 0, width: width, height: CharacterSelectionCell.cellHeight)
        let iconX = CGFloat(width - CharacterSelectionCell.iconWidth)
        let iconY = CGFloat(0.5 * (CharacterSelectionCell.cellHeight - CharacterSelectionCell.iconHeight) )
        cell.iconButton.frame = CGRect(x: iconX, y: iconY, width: CharacterSelectionCell.iconWidth, height: CharacterSelectionCell.iconHeight)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Pressed at \(indexPath.row)")
        print("Name is \(characters[indexPath.row])")
        let name = characters[indexPath.row]
        main.loadCharacterProfile(name: name)
        Controllers.revealController.view.makeToast("Character selected: " + name, duration: Constants.toastDuration)
        self.dismiss(animated: true, completion: dismissOperations)
    }
    
    @objc func newCharacterButtonPressed() {
        let mustComplete = (main.characterList().count == 0)
        print("Pressed new character button, mustComplete: \(mustComplete)")
        displayNewCharacterWindow(mustComplete: mustComplete)
    }
    
    func displayNewCharacterWindow(mustComplete: Bool=false) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "characterCreation") as! CharacterCreationController
        
        let screenRect = UIScreen.main.bounds
        let popupWidth = CGFloat(0.8 * screenRect.size.width)
        let popupHeight = CGFloat(0.25 * screenRect.size.height)
        controller.width = popupWidth
        controller.height = popupHeight
        let popupVC = PopupViewController(contentController: controller, popupWidth: popupWidth, popupHeight: popupHeight)
        if mustComplete {
            controller.cancelButton.isHidden = true
            popupVC.canTapOutsideToDismiss = false
            self.present(popupVC, animated: true)
        }
        self.present(popupVC, animated: true)
    }
    
    func createDeletionPrompt(name: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "deletePrompt") as! DeletionPromptController
        controller.main = main
        controller.name = name
        
        let screenRect = UIScreen.main.bounds
        let popupWidth = CGFloat(0.8 * screenRect.size.width)
        let popupHeight = CGFloat(0.25 * screenRect.size.height)
        controller.width = popupWidth
        controller.height = popupHeight
        let popupVC = PopupViewController(contentController: controller, popupWidth: popupWidth, popupHeight: popupHeight)
        self.present(popupVC, animated: true)
    }
    
    
    func updateCharacterTable() {
        characters = main.characterList()
        tableView.reloadData()
    }
    
    func dismissOperations() {
        print("In dismissOperations()")
        main.selectionWindow = nil
    }
    
    func pressNewCharacterButton() {
        newCharacterButton.sendActions(for: UIControl.Event.touchUpInside)
    }

    
}
