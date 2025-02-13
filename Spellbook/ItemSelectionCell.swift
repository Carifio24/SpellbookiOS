//
//  CharacterSelectionCell.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 4/22/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import UIKit

class ItemSelectionCell: UITableViewCell {
    
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var pullDownButton: UIButton!
    
    static let iconSize = CGFloat(35)
    
    let name: String? = nil
    let delegate: NamedItemEventDelegate? = nil
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setup()
    }
    
    func setup() {
        Bundle.main.loadNibNamed("ItemSelectionCell", owner: self, options: nil)
        print("Item selection cell setup")
        self.contentView.backgroundColor = UIColor.clear
        self.addSubview(rootView)
        setupCommands()
    }
    
    @IBAction func onPress(sender: UIButton) {
       print("Pressed!")
    }
    
    private func setupCommands() {
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
