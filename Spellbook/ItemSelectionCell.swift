//
//  CharacterSelectionCell.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 4/22/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import UIKit

class ItemSelectionCell: UITableViewCell {
    
    
    static let iconSize = CGFloat(35)
    static let deleteIcon = UIImage(named: "trash_icon.png")?.withRenderingMode(.alwaysOriginal).resized(width: ItemSelectionCell.iconSize, height: ItemSelectionCell.iconSize)
    static let clipboardIcon = UIImage(named: "clipboard_icon.png")?.withRenderingMode(.alwaysOriginal).resized(width: ItemSelectionCell.iconSize, height: ItemSelectionCell.iconSize)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setup()
    }
    
    func setup() {
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
