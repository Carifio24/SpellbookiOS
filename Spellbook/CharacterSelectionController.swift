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
        //setDimensions()
        
        // Set this as the data source and delegate for the table
        tableView.delegate = self
        tableView.dataSource = self
        
        // Set the cell height
        tableView.estimatedRowHeight = CGFloat(40)
        tableView.rowHeight = UITableView.automaticDimension
        
        // Set the table cell type
        //tableView.register(CharacterSelectionCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        // Set the button function
        newCharacterButton.addTarget(self, action: #selector(newCharacterButtonPressed), for: UIControl.Event.touchUpInside)
        
        // Load the data
        print("About to load data")
        tableView.reloadData()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Turn off scrolling if the content height is less than the table's height
        print(tableView.contentSize.height)
        print(tableView.frame.size.height)
        tableView.isScrollEnabled = tableView.contentSize.height > tableView.frame.size.height
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
        cell.deleteButton.addTarget(self, action: #selector(deleteButtonPressed(sender:)), for: UIControl.Event.touchUpInside)
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.setImage(CharacterSelectionCell.deleteIcon, for: UIControl.State.normal)
        let name = characters[indexPath.row]
        cell.nameLabel.text = name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Pressed at \(indexPath.row)")
        print("Name is \(characters[indexPath.row])")
        let name = characters[indexPath.row]
        do {
            try main.loadCharacterProfile(name: name, initialLoad: false)
            Controllers.revealController.view.makeToast("Character selected: " + name, duration: Constants.toastDuration)
        } catch {
            Controllers.revealController.view.makeToast("Error loading character profile: " + name, duration: Constants.toastDuration)
        }
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
        let maxPopupHeight = CGFloat(170)
        let maxPopupWidth = CGFloat(350)
        let height = popupHeight <= maxPopupHeight ? popupHeight : maxPopupHeight
        let width = popupWidth <= maxPopupWidth ? popupWidth : maxPopupWidth
        
        let popupVC = PopupViewController(contentController: controller, popupWidth: width, popupHeight: height)
        if mustComplete {
            controller.cancelButton.isHidden = true
            popupVC.canTapOutsideToDismiss = false
            self.present(popupVC, animated: true)
        }
        self.present(popupVC, animated: true)
    }
    
    @objc func createDeletionPrompt(name: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "deletePrompt") as! DeletionPromptController
        controller.main = main
        controller.name = name
        
        let screenRect = UIScreen.main.bounds
        let popupWidth = CGFloat(0.8 * screenRect.size.width)
        let popupHeight = CGFloat(0.25 * screenRect.size.height)
        let maxPopupHeight = CGFloat(105)
        let maxPopupWidth = CGFloat(350)
        let height = popupHeight <= maxPopupHeight ? popupHeight : maxPopupHeight
        let width = popupWidth <= maxPopupWidth ? popupWidth : maxPopupWidth
        print("Popup height and width are \(popupHeight), \(popupWidth)")
        print("The screen heights are \(SizeUtils.screenHeight), \(SizeUtils.screenWidth)")
        print("Deletion prompt will have width \(width), height \(height)")
        let popupVC = PopupViewController(contentController: controller, popupWidth: width, popupHeight: height)
        self.present(popupVC, animated: true)
    }
    
    
    func updateCharacterTable() {
        characters = main.characterList()
        tableView.reloadData()
        print(tableView.contentSize.height)
        print(tableView.frame.size.height)
        tableView.isScrollEnabled = tableView.contentSize.height > tableView.frame.size.height
    }
    
    func dismissOperations() {
        print("In dismissOperations()")
        main.selectionWindow = nil
    }
    
    func pressNewCharacterButton() {
        newCharacterButton.sendActions(for: UIControl.Event.touchUpInside)
    }
    
    @objc func deleteButtonPressed(sender: UIButton) {
        let buttonOriginInTable = sender.convert(CGPoint.zero, to: tableView)
        let indexPath = tableView.indexPathForRow(at: buttonOriginInTable)
        if (indexPath == nil) { return }
        let name = characters[indexPath!.row]
        createDeletionPrompt(name: name)
    }

    
}
