//
//  CharacterSelectionCell.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 4/22/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import UIKit

class CharacterSelectionCell: UITableViewCell {
    
    let nameFont = UIFont(name: "Cloister Black", size: 25)
    var width = CGFloat(0)
    let nameLabel = UILabel()
    let iconButton = UIButton()
    var name: String = String() {
        didSet {
            setup()
        }
    }
    
    static let cellHeight = CGFloat(40)
    static let iconWidth = CGFloat(0.9 * CharacterSelectionCell.cellHeight)
    static let iconHeight = CGFloat(0.9 * CharacterSelectionCell.cellHeight)
    static private let deleteIcon = UIImage(named: "trash_icon.png")?.withRenderingMode(.alwaysOriginal)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clear
        iconButton.addTarget(self, action: #selector(deleteButtonPressed), for: UIControl.Event.touchUpInside)
        setup()
        
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    func setup() {
        self.addSubview(nameLabel)
        nameLabel.backgroundColor = UIColor.clear
        nameLabel.text = name
        nameLabel.textColor = UIColor.black
        nameLabel.font = nameFont

        self.bringSubviewToFront(nameLabel)
        
        self.addSubview(iconButton)
        iconButton.setImage(CharacterSelectionCell.deleteIcon, for: UIControl.State.normal)
        iconButton.backgroundColor = UIColor.clear
        self.bringSubviewToFront(iconButton)
        
    }
    
//    @objc func deleteButtonPressed() {
//        print("Pressed delete icon on cell \(iconButton.tag)")
//        let table = parentTable()
//        let selectionController = table.dataSource as! CharacterSelectionController
//        let mainTable = selectionController.mainTable
//        let characters = mainTable?.characterList()
//        mainTable?.deleteCharacterProfile(name: characters![iconButton.tag])
//    }
    
    @objc func deleteButtonPressed() {
        print("Pressed delete icon on cell \(iconButton.tag)")
        let table = parentTable()
        let selectionController = table.dataSource as! CharacterSelectionController
        selectionController.createDeletionPrompt(name: name)
        
    }
    
    func parentTable() -> UITableView {
        var view = self.superview
        while (view != nil && view?.isKind(of: UITableView.self) == false) {
            view = view!.superview
        }
        return view as! UITableView
    }
    
}
