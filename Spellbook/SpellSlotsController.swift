//
//  SpellSlotsViewController.swift
//  Spellbook
//
//  Created by Mac Pro on 10/2/22.
//  Copyright © 2022 Jonathan Carifio. All rights reserved.
//

import UIKit

class SpellSlotsController: UITableViewController {
    
    static let backgroundImage = UIImage(named: "BookBackground.jpeg")?.withRenderingMode(.alwaysOriginal)
    
    let headerHeight = CGFloat(57)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.backgroundView = UIImageView(image:  InfoMenuViewController.backgroundImage)
        
        // The header for the table
        let titleLabel = UILabel()
        titleLabel.text = "Spell Slots"
        titleLabel.font = UIFont(name: "Cloister Black", size: CGFloat(50))
        titleLabel.textColor = defaultFontColor
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.frame.size.height = headerHeight
        tableView.tableHeaderView = titleLabel
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
