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
    
    @IBOutlet weak var characterTable: UITableView!
    
    private let cellReuseIdentifier = "characterCell"
    
    var height = CGFloat(0)
    var width = CGFloat(0)
    var characters: [String] = []
    var mainTable: SpellTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the current characters list
        characters = mainTable!.characterList()
        
        // Set the view dimensions
        setDimensions()
        
        // Set the table cell type
        
    }
    
    func setDimensions() {

        let leftPadding = CGFloat(3)
        let rightPadding = CGFloat(3)
        let topPadding = CGFloat(3)
        let bottomPadding = CGFloat(3)

        let usableWidth = width - leftPadding - rightPadding
        let usableHeight = height - topPadding - bottomPadding

        let titleX = leftPadding + CGFloat(0.2 * usableWidth)
        let titleY = topPadding
        let titleWidth = CGFloat(0.6 * usableWidth)
        let titleHeight = CGFloat(0.25 * usableHeight)

        selectionTitle.frame = CGRect(x: titleX, y: titleY, width: titleWidth, height: titleHeight)

        let messageX = leftPadding + CGFloat(0.1 * usableWidth)
        let messageY = titleY + titleHeight
        let messageWidth = CGFloat(0.8 * usableWidth)
        let messageHeight = CGFloat(0.2 * usableHeight)
        selectionMessage.frame = CGRect(x: messageX, y: messageY, width: messageWidth, height: messageHeight)

        let tableX = leftPadding
        let tableY = messageY + messageHeight
        let tableWidth = usableWidth
        let tableHeight = usableHeight - titleHeight - messageHeight
        characterTable.frame = CGRect(x: tableX, y: tableY, width: tableWidth, height: tableHeight)

    }
    
    // For conforming to the table delegate and data source protocols
    func tableView(_ tableView: UITableView, numberOfRowsInSection: Int) -> Int {
        return characters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
}
