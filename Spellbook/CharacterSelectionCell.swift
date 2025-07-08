//
//  CharacterSelectionCell.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 4/22/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import UIKit

class CharacterSelectionCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var clipboardButton: UIButton!
    @IBOutlet weak var pencilButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    static let iconSize = CGFloat(35)
    static let deleteIcon = UIImage(named: "trash_icon.png")?.withRenderingMode(.alwaysOriginal).resized(width: CharacterSelectionCell.iconSize, height: CharacterSelectionCell.iconSize)
    static let pencilIcon = UIImage(named: "EditIcon")?.inverseImage(cgResult: true)?.withRenderingMode(.alwaysOriginal).resized(width: CharacterSelectionCell.iconSize * 0.9, height: CharacterSelectionCell.iconSize * 0.9)
    static let clipboardIcon = UIImage(named: "clipboard_icon.png")?.withRenderingMode(.alwaysOriginal).resized(width: CharacterSelectionCell.iconSize, height: CharacterSelectionCell.iconSize)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setup()
    }
    
    func setup() {
//        nameLabel.textColor = defaultFontColor
//        self.addSubview(nameLabel)
//        print("nameLabel height is \(nameLabel.frame.size.height)")
//        nameLabel.backgroundColor = UIColor.red
//        nameLabel.text = name
//        print("nameLabel height is \(nameLabel.frame.size.height)")
//        nameLabel.textColor = UIColor.black
//        nameLabel.font = nameFont

        //self.bringSubviewToFront(nameLabel)
        //self.addSubview(iconButton)
        //self.bringSubviewToFront(iconButton)
        
    }
    
//    @objc func deleteButtonPressed() {
//        print("Pressed delete icon on cell \(iconButton.tag)")
//        let table = parentTable()
//        let selectionController = table.dataSource as! CharacterSelectionController
//        let mainTable = selectionController.mainTable
//        let characters = mainTable?.characterList()
//        mainTable?.deleteCharacterProfile(name: characters![iconButton.tag])
//    }
    
    func parentTable() -> UITableView {
        var view = self.superview
        while (view != nil && view?.isKind(of: UITableView.self) == false) {
            view = view!.superview
        }
        return view as! UITableView
    }
    
}
