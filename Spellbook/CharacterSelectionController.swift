//
//  CharacterSelectionController.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 4/17/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import UIKit
import ReSwift

class CharacterSelectionController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var selectionTitle: UILabel!
    @IBOutlet weak var selectionMessage: UILabel!
    @IBOutlet weak var newCharacterButton: UIButton!
    @IBOutlet weak var importCharacterButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundView: UIImageView!
    
    private let cellReuseIdentifier = "characterCell"
    
    var height = CGFloat(0)
    var width = CGFloat(0)
    var characters: [String] = []
    let main: ViewController = Controllers.mainController
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self) {
            $0.select {
                $0.profileNameList
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the current characters list
        characters = store.state.profileNameList
        //print("There are \(characters.count) characters")
        
        // Set the view dimensions
        //setDimensions()
        
        // Set this as the data source and delegate for the table
        tableView.delegate = self
        tableView.dataSource = self
        
        // Set the cell height
        tableView.estimatedRowHeight = CGFloat(40)
        tableView.rowHeight = UITableView.automaticDimension
        
        // Set the label fonts
        for label in [ selectionTitle, selectionMessage ] {
            label?.textColor = defaultFontColor
        }
        
        // Set the table cell type
        //tableView.register(CharacterSelectionCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        // Set the button functions
        newCharacterButton.addTarget(self, action: #selector(newCharacterButtonPressed), for: UIControl.Event.touchUpInside)
        importCharacterButton.addTarget(self, action: #selector(importCharacterButtonPressed), for: UIControl.Event.touchUpInside)
        
        // Load the data
        //print("About to load data")
        tableView.reloadData()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Turn off scrolling if the content height is less than the table's height
        //print(tableView.contentSize.height)
        //print(tableView.frame.size.height)
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

        let titleX = CGFloat(width / 2)
        let titleY = view.frame.origin.y + topPadding
        selectionTitle.center.x = titleX
        selectionTitle.frame.origin.y = titleY
        selectionTitle.sizeToFit()
        
        let messageX = CGFloat(width / 2)
        let messageY = titleY + selectionTitle.frame.height
        selectionMessage.center.x = messageX
        selectionMessage.frame.origin.y = messageY
        selectionTitle.sizeToFit()
        
        let newButtonX = CGFloat(width / 2)
        let newButtonY = messageY + selectionMessage.frame.height
        newCharacterButton.contentHorizontalAlignment = .center
        newCharacterButton.center.x = newButtonX
        newCharacterButton.frame.origin.y = newButtonY
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
        cell.pencilButton.addTarget(self, action: #selector(pencilButtonPressed(sender:)), for: UIControl.Event.touchUpInside)
        cell.clipboardButton.addTarget(self, action: #selector(clipboardButtonPressed(sender:)), for: UIControl.Event.touchUpInside)
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.setImage(CharacterSelectionCell.deleteIcon, for: UIControl.State.normal)
        cell.pencilButton.tag = indexPath.row
        cell.pencilButton.setImage(CharacterSelectionCell.pencilIcon, for: UIControl.State.normal)
        cell.clipboardButton.tag = indexPath.row
        cell.clipboardButton.setImage(CharacterSelectionCell.clipboardIcon, for: UIControl.State.normal)
        let name = characters[indexPath.row]
        cell.nameLabel.text = name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let name = characters[indexPath.row]
        store.dispatch(SwitchProfileByNameAction(name: name))
        self.dismiss(animated: true, completion: dismissOperations)
    }
    
    @objc func newCharacterButtonPressed() {
        let mustComplete = (store.state.profileNameList.count == 0)
        displayNewCharacterWindow(mustComplete: mustComplete)
    }
    
    @objc func importCharacterButtonPressed() {
        displayImportCharacterWindow()
    }
    
    private func createPopup(_ controller: UIViewController) -> PopupViewController {
        let screenRect = UIScreen.main.bounds
        let popupWidth = CGFloat(0.8 * screenRect.size.width)
        let popupHeight = CGFloat(0.25 * screenRect.size.height)
        let maxPopupHeight = CGFloat(170)
        let maxPopupWidth = CGFloat(350)
        let height = popupHeight <= maxPopupHeight ? popupHeight : maxPopupHeight
        let width = popupWidth <= maxPopupWidth ? popupWidth : maxPopupWidth
        
        return PopupViewController(contentController: controller, popupWidth: width, popupHeight: height)
    }
    
    func displayNewCharacterWindow(mustComplete: Bool=false) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "characterCreation") as! CharacterCreationController
        
        let popupVC = createPopup(controller)
        if mustComplete {
            controller.cancelButton.isHidden = true
            popupVC.canTapOutsideToDismiss = false
        }
        self.present(popupVC, animated: true)
    }
    
    func displayImportCharacterWindow() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "importCharacter") as! ImportCharacterController
        
        let popupVC = createPopup(controller)
        self.present(popupVC, animated: true)
    }
    
    @objc func displayRenameCharacterWindow(name: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "renameCharacter") as! RenameCharacterController
        controller.name = name
        
        let popupVC = createPopup(controller)
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
        let popupVC = PopupViewController(contentController: controller, popupWidth: width, popupHeight: height)
        self.present(popupVC, animated: true)
    }
    
    @objc func copyProfileJSONToClipboard(name: String) {
        let location = SerializationUtils.profileLocation(name: name)
        if var profileText = try? String(contentsOf: location) {
            do {
                fixEscapeCharacters(&profileText)
                let pasteboard = UIPasteboard.general
                pasteboard.string = profileText
                Toast.makeToast("Copied JSON for \(name)")
            }
        } else {
            Toast.makeToast("Error copying JSON for \(name)")
        }
    }

    func dismissOperations() {
        //print("In dismissOperations()")
        main.selectionWindow = nil
    }
    
    func pressNewCharacterButton() {
        newCharacterButton.sendActions(for: UIControl.Event.touchUpInside)
    }
    
    func indexPathForItem(item: UIView) -> IndexPath? {
        let origin = item.convert(CGPoint.zero, to: tableView)
        return tableView.indexPathForRow(at: origin)
    }

    @objc func deleteButtonPressed(sender: UIButton) {
        guard let indexPath = indexPathForItem(item: sender) else { return }
        let name = characters[indexPath.row]
        createDeletionPrompt(name: name)
    }
    
    @objc func pencilButtonPressed(sender: UIButton) {
        guard let indexPath = indexPathForItem(item: sender) else { return }
        let name = characters[indexPath.row]
        displayRenameCharacterWindow(name: name)
    }

    @objc func clipboardButtonPressed(sender: UIButton) {
        guard let indexPath = indexPathForItem(item: sender) else { return }
        let name = characters[indexPath.row]
        copyProfileJSONToClipboard(name: name)
    }
}

// MARK: StoreSubscriber
extension CharacterSelectionController: StoreSubscriber {
    func newState(state characterNames: [String]) {
        // Refresh the table
        characters = characterNames
        tableView.reloadData()
        tableView.isScrollEnabled = tableView.contentSize.height > tableView.frame.size.height
    }
}
